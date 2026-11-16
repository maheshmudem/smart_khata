import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/features/backup/domain/backup.dart';

/// How hard the passphrase is stretched. Stored in each file's header so
/// a file made with other values can still be opened.
class KdfParams {
  const KdfParams({
    required this.memoryKib,
    required this.iterations,
    required this.parallelism,
  });

  /// Argon2id at the OWASP-recommended minimum (19 MiB, 2 passes, 1 lane).
  static const KdfParams standard = KdfParams(
    memoryKib: 19456,
    iterations: 2,
    parallelism: 1,
  );

  final int memoryKib;
  final int iterations;
  final int parallelism;

  /// The most a file may ask for: 64 MiB and 4 passes, a little over
  /// three times the standard cost. Key stretching runs in Dart, so a
  /// header asking for a gigabyte would get the app killed on a small
  /// phone.
  static const int maxMemoryKib = 64 * 1024;
  static const int maxIterations = 4;

  /// Refuses values a crafted file could use to exhaust the phone.
  bool get isSane =>
      memoryKib >= 8 &&
      memoryKib <= maxMemoryKib &&
      iterations >= 1 &&
      iterations <= maxIterations &&
      parallelism >= 1 &&
      parallelism <= 8;
}

/// The decrypted contents of a backup file.
class BackupContents {
  const BackupContents({required this.manifest, required this.database});

  final BackupManifest manifest;
  final Uint8List database;
}

/// The `.skbak` file format, version 1 (ADR-026).
///
/// ```text
/// offset  size  field
///      0     5  magic "SKBAK"
///      5     1  format version (1)
///      6     1  key derivation: 1 = Argon2id
///      7     4  Argon2id memory in KiB, big-endian
///     11     4  Argon2id iterations, big-endian
///     15     1  Argon2id parallelism
///     16    16  salt
///     32    24  nonce
///     56     n  ciphertext
///   56+n    16  Poly1305 tag
/// ```
///
/// The key is Argon2id(passphrase, salt). The ciphertext is
/// XChaCha20-Poly1305 over `manifest length (4 bytes) | manifest JSON |
/// SQLite database`, with the 56 header bytes as associated data, so a
/// change to any byte of the file, header included, fails authentication.
///
/// Both primitives come from the `cryptography` package; nothing here is
/// a home-made cipher. Only the header is readable without the
/// passphrase and it holds no shop data.
abstract final class BackupCodec {
  static const List<int> magic = [0x53, 0x4B, 0x42, 0x41, 0x4B]; // SKBAK
  static const int formatVersion = 1;
  static const int kdfArgon2id = 1;
  static const int saltLength = 16;
  static const int nonceLength = 24;
  static const int headerLength = 56;
  static const int tagLength = 16;
  static const int keyLength = 32;

  /// Larger files are refused before any work is done.
  static const int maxFileBytes = 256 * 1024 * 1024;

  static Future<Uint8List> seal({
    required BackupManifest manifest,
    required Uint8List database,
    required String passphrase,
    required List<int> salt,
    required List<int> nonce,
    KdfParams params = KdfParams.standard,
  }) async {
    assert(salt.length == saltLength, 'salt length');
    assert(nonce.length == nonceLength, 'nonce length');

    final header = BytesBuilder(copy: false)
      ..add(magic)
      ..addByte(formatVersion)
      ..addByte(kdfArgon2id)
      ..add(_uint32(params.memoryKib))
      ..add(_uint32(params.iterations))
      ..addByte(params.parallelism)
      ..add(salt)
      ..add(nonce);
    final headerBytes = header.toBytes();

    final manifestBytes = utf8.encode(jsonEncode(manifest.toJson()));
    final clear = BytesBuilder(copy: false)
      ..add(_uint32(manifestBytes.length))
      ..add(manifestBytes)
      ..add(database);

    final box = await Xchacha20.poly1305Aead().encrypt(
      clear.toBytes(),
      secretKey: await _key(passphrase, salt, params),
      nonce: nonce,
      aad: headerBytes,
    );
    return (BytesBuilder(copy: false)
          ..add(headerBytes)
          ..add(box.cipherText)
          ..add(box.mac.bytes))
        .toBytes();
  }

  /// Decrypts a backup file. Throws [FailureException] with a
  /// [BackupFailure] saying which kind of problem it was.
  static Future<BackupContents> open(Uint8List file, String passphrase) async {
    if (file.length > maxFileBytes) throw _failure(BackupError.tooLarge);
    if (file.length < headerLength + tagLength + 4 ||
        !_startsWith(file, magic)) {
      throw _failure(BackupError.notABackup);
    }
    if (file[5] != formatVersion || file[6] != kdfArgon2id) {
      throw _failure(BackupError.newerVersion);
    }
    final view = ByteData.sublistView(file);
    final params = KdfParams(
      memoryKib: view.getUint32(7),
      iterations: view.getUint32(11),
      parallelism: file[15],
    );
    if (!params.isSane) throw _failure(BackupError.notABackup);

    final salt = file.sublist(16, 32);
    final nonce = file.sublist(32, headerLength);
    final List<int> clear;
    try {
      clear = await Xchacha20.poly1305Aead().decrypt(
        SecretBox(
          Uint8List.sublistView(file, headerLength, file.length - tagLength),
          nonce: nonce,
          mac: Mac(file.sublist(file.length - tagLength)),
        ),
        secretKey: await _key(passphrase, salt, params),
        aad: Uint8List.sublistView(file, 0, headerLength),
      );
    } on SecretBoxAuthenticationError {
      throw _failure(BackupError.wrongPassphraseOrDamaged);
    }

    final bytes = clear is Uint8List ? clear : Uint8List.fromList(clear);
    try {
      final manifestLength = ByteData.sublistView(bytes).getUint32(0);
      if (manifestLength > bytes.length - 4) {
        throw const FormatException('manifest length');
      }
      final json = jsonDecode(
        utf8.decode(bytes.sublist(4, 4 + manifestLength)),
      );
      if (json is! Map<String, Object?>) {
        throw const FormatException('manifest');
      }
      return BackupContents(
        manifest: BackupManifest.fromJson(json),
        database: Uint8List.sublistView(bytes, 4 + manifestLength),
      );
    } on FormatException {
      throw _failure(BackupError.failedChecks);
    }
  }

  /// Lower-case hex SHA-256 of [bytes].
  static Future<String> sha256Hex(List<int> bytes) async {
    final hash = await Sha256().hash(bytes);
    return [
      for (final byte in hash.bytes) byte.toRadixString(16).padLeft(2, '0'),
    ].join();
  }

  static Future<SecretKey> _key(
    String passphrase,
    List<int> salt,
    KdfParams params,
  ) => Argon2id(
    parallelism: params.parallelism,
    memory: params.memoryKib,
    iterations: params.iterations,
    hashLength: keyLength,
  ).deriveKey(secretKey: SecretKey(utf8.encode(passphrase)), nonce: salt);

  static Uint8List _uint32(int value) =>
      (ByteData(4)..setUint32(0, value)).buffer.asUint8List();

  static bool _startsWith(Uint8List bytes, List<int> prefix) {
    for (var i = 0; i < prefix.length; i++) {
      if (bytes[i] != prefix[i]) return false;
    }
    return true;
  }

  static FailureException _failure(BackupError error) =>
      FailureException(BackupFailure(error));
}
