import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _readArb(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

Set<String> _messageKeys(Map<String, Object?> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

Set<String> _placeholders(String message) =>
    RegExp(r'\{(\w+)\}').allMatches(message).map((m) => m.group(1)!).toSet();

void main() {
  final en = _readArb('lib/l10n/app_en.arb');
  final te = _readArb('lib/l10n/app_te.arb');

  test('English and Telugu define exactly the same messages', () {
    expect(
      _messageKeys(te).difference(_messageKeys(en)),
      isEmpty,
      reason: 'only in Telugu',
    );
    expect(
      _messageKeys(en).difference(_messageKeys(te)),
      isEmpty,
      reason: 'missing from Telugu',
    );
  });

  test('no message is empty', () {
    for (final arb in [en, te]) {
      for (final key in _messageKeys(arb)) {
        expect((arb[key]! as String).trim(), isNotEmpty, reason: key);
      }
    }
  });

  test('each translation keeps the placeholders of its source', () {
    for (final key in _messageKeys(en)) {
      expect(
        _placeholders(te[key]! as String),
        _placeholders(en[key]! as String),
        reason: key,
      );
    }
  });

  test('Telugu is actually Telugu, apart from names kept in Latin script', () {
    const latinOnPurpose = {'languageEnglish', 'amountSemantics'};
    final teluguScript = RegExp('[ఀ-౿]');
    for (final key in _messageKeys(te).difference(latinOnPurpose)) {
      expect(teluguScript.hasMatch(te[key]! as String), isTrue, reason: key);
    }
  });
}
