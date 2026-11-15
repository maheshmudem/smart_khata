import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Fails the build when a file imports across a layer boundary
/// (docs/engineering/architecture.md, "Dependency rule").
void main() {
  final sources = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
      .map(_Source.read)
      .toList();

  List<String> violations(
    bool Function(_Source source) inScope,
    bool Function(String import) isForbidden,
  ) => [
    for (final source in sources.where(inScope))
      for (final import in source.imports.where(isForbidden))
        '${source.path} imports $import',
  ];

  test('there is source to check', () {
    expect(sources.length, greaterThan(20));
  });

  test('domain code is plain Dart: no Flutter, Drift, BLoC or plugins', () {
    const forbidden = [
      'package:flutter/',
      'package:flutter_bloc/',
      'package:bloc',
      'package:drift',
      'package:go_router/',
      'package:get_it/',
      'package:path_provider/',
      'dart:ui',
      'dart:io',
    ];
    expect(
      violations(
        (s) => s.path.contains('/domain/'),
        (i) => forbidden.any(i.startsWith),
      ),
      isEmpty,
    );
  });

  test('domain code does not reach into data or presentation', () {
    expect(
      violations(
        (s) => s.path.contains('/domain/'),
        (i) =>
            i.contains('/data/') ||
            i.contains('/presentation/') ||
            i.contains('/core/database/') ||
            i.contains('/core/widgets/'),
      ),
      isEmpty,
    );
  });

  test('presentation and widgets never touch the database or Drift', () {
    expect(
      violations(
        (s) =>
            s.path.contains('/presentation/') ||
            s.path.contains('/core/widgets/') ||
            s.path.contains('/app/router/'),
        (i) =>
            i.startsWith('package:drift') ||
            i.contains('/core/database/') ||
            i.contains('/data/'),
      ),
      isEmpty,
    );
  });

  test('money and date code is plain Dart', () {
    expect(
      violations(
        (s) =>
            s.path.contains('/core/money/') ||
            s.path.contains('/core/date_time/'),
        (i) => i.startsWith('package:flutter') || i.startsWith('package:drift'),
      ),
      isEmpty,
    );
  });

  test('core does not depend on features or the app layer', () {
    expect(
      violations(
        (s) => s.path.startsWith('lib/core/'),
        (i) =>
            i.startsWith('package:smart_khata/features/') ||
            // LanguageOptions is the one widget that needs no app state.
            i.startsWith('package:smart_khata/app/'),
      ),
      isEmpty,
    );
  });

  test('only composition roots use the service locator', () {
    const allowed = ['lib/app/di/', 'lib/bootstrap.dart', 'lib/app/router/'];
    expect(
      violations(
        (s) => !allowed.any(s.path.startsWith),
        (i) =>
            i.startsWith('package:get_it/') || i.endsWith('/di/injection.dart'),
      ),
      isEmpty,
    );
  });

  test('money never goes through double', () {
    final offenders = [
      for (final source in sources.where(
        (s) => s.path.contains('/core/money/'),
      ))
        if (RegExp(
          r'\bdouble\b|\bnum\b|toDouble|parseDouble',
        ).hasMatch(source.code))
          source.path,
    ];
    expect(offenders, isEmpty);
  });

  test('nothing prints or calls DateTime.now outside the clock', () {
    final offenders = [
      for (final source in sources)
        if (!source.path.endsWith('core/date_time/clock.dart') &&
            RegExp(
              r'\bprint\(|debugPrint\(|DateTime\.now\(',
            ).hasMatch(source.code))
          source.path,
    ];
    expect(offenders, isEmpty);
  });

  test('screens show no hard-coded text (FR-SET-002, SK-1201)', () {
    // A string literal with two or more letters in a row, given straight
    // to something that shows text. Translated text comes from l10n.
    final shown = RegExp(
      r'''(?:Text\(|label:|title:|tooltip:|hintText:|helperText:|'''
      r'''labelText:|message:|semanticLabel:)\s*(?:const\s+)?'''
      r'''(?:Text\(\s*)?['"][^'"$]*[A-Za-z]{2}''',
    );
    // Developer-only screens that are not translated on purpose.
    const allowed = [
      'lib/features/gallery/',
      'lib/features/settings/presentation/pages/more_page.dart',
    ];
    final offenders = [
      for (final source in sources.where(
        (s) =>
            (s.path.contains('/presentation/') ||
                s.path.contains('/core/widgets/') ||
                s.path.contains('/app/router/') ||
                s.path.endsWith('lib/app/app.dart')) &&
            !s.path.contains('/l10n/') &&
            !allowed.any(s.path.startsWith),
      ))
        for (final match in shown.allMatches(source.code))
          '${source.path}: ${match.group(0)}',
    ];
    expect(offenders, isEmpty);
  });

  test('the one untranslated screen entry is the debug gallery link', () {
    final more = sources.singleWhere(
      (s) => s.path.endsWith('pages/more_page.dart'),
    );
    final literals = RegExp(
      r'''Text\(\s*['"]([^'"]*[A-Za-z]{2}[^'"]*)['"]''',
    ).allMatches(more.code).map((m) => m.group(1)).toList();
    expect(literals, ['Widget gallery (debug)']);
    expect(more.code, contains('if (kDebugMode)'));
  });
}

class _Source {
  _Source(this.path, this.code, this.imports);

  factory _Source.read(File file) {
    final text = file.readAsStringSync();
    // Strip comments so that words in documentation do not count.
    final code = const LineSplitter()
        .convert(text)
        .map((line) => line.replaceFirst(RegExp(r'\s*//.*$'), ''))
        .join('\n');
    final imports = RegExp(
      r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
      multiLine: true,
    ).allMatches(code).map((m) => m.group(1)!).toList();
    return _Source(file.path.replaceAll(r'\', '/'), code, imports);
  }

  final String path;
  final String code;
  final List<String> imports;
}
