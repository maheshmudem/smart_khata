import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_khata/core/export/share_service.dart';

/// [ShareService] on the device: the native share sheet through
/// `share_plus`. Files are written to the app's private cache directory
/// first; the owner decides where they go from the sheet.
final class PlatformShareService implements ShareService {
  const PlatformShareService();

  @override
  Future<void> shareText(String text, {String? subject}) async {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }

  @override
  Future<void> shareFile({
    required String fileName,
    required String content,
    required String mimeType,
    String? subject,
  }) async {
    final directory = await getTemporaryDirectory();
    // Only the base name is used, so a name can never point outside the
    // cache directory.
    final file = File(p.join(directory.path, p.basename(fileName)));
    // UTF-8 is the default encoding.
    await file.writeAsString(content, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: mimeType)],
        subject: subject,
      ),
    );
  }
}
