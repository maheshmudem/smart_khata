// Coverage gate for the code that holds the rules and writes the records:
// lib/core (except UI and generated code) and every feature's domain and
// data layers (repositories, the allocation rebalancer, the backup codec,
// the app-lock store).
//
//   flutter test --coverage
//   dart run tool/check_coverage.dart [minimum-percent] [per-file-percent]
//
// Three checks:
//   1. All gated lines together reach the minimum (default 90%).
//   2. No gated file is below the per-file floor (default 70%), so a weak
//      file cannot hide behind well-covered ones.
//   3. Every gated file with code in it appears in the report. A file no
//      test loads is missing from lcov, which would otherwise read as
//      "nothing to cover".
//
// A build tool, so writing to stdout is intended.
// ignore_for_file: avoid_print
import 'dart:io';

const _defaultMinimum = 90.0;
const _defaultFileFloor = 70.0;

String _normalize(String path) => path.replaceAll(r'\', '/');

bool _isGated(String path) {
  final p = _normalize(path);
  if (p.endsWith('.g.dart')) return false;
  if (p.contains('/domain/') || p.contains('/data/')) return true;
  if (!p.startsWith('lib/core/')) return false;
  // Widgets and theme are covered by widget tests, not by this gate.
  return !p.startsWith('lib/core/widgets/') && !p.startsWith('lib/core/theme/');
}

/// Whether a source file has anything a test could run: a body, a
/// getter, an initialiser. Pure declarations (interfaces, enums without
/// members) produce no coverage lines and are left out.
bool _hasCode(File file) {
  final text = file.readAsStringSync();
  return RegExp(r'=>|\)\s*(async\s*)?\{').hasMatch(text);
}

void main(List<String> args) {
  final minimum = args.isEmpty ? _defaultMinimum : double.parse(args.first);
  final fileFloor = args.length < 2 ? _defaultFileFloor : double.parse(args[1]);
  final report = File('coverage/lcov.info');
  if (!report.existsSync()) {
    stderr.writeln(
      'coverage/lcov.info not found. Run: flutter test --coverage',
    );
    exit(2);
  }

  final perFile = <String, (int hit, int found)>{};
  String? current;
  var hit = 0;
  var found = 0;
  for (final line in report.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      current = _normalize(line.substring(3));
      hit = 0;
      found = 0;
    } else if (line.startsWith('DA:')) {
      found++;
      if (!line.endsWith(',0')) hit++;
    } else if (line == 'end_of_record' && current != null) {
      if (_isGated(current)) perFile[current] = (hit, found);
      current = null;
    }
  }

  var totalHit = 0;
  var totalFound = 0;
  final belowFloor = <String>[];
  final paths = perFile.keys.toList()..sort();
  for (final path in paths) {
    final (fileHit, fileFound) = perFile[path]!;
    totalHit += fileHit;
    totalFound += fileFound;
    final percent = fileFound == 0 ? 100.0 : fileHit * 100 / fileFound;
    print('${percent.toStringAsFixed(1).padLeft(6)}%  $path');
    if (percent < fileFloor) belowFloor.add(path);
  }

  final unloaded = [
    for (final entity in Directory('lib').listSync(recursive: true))
      if (entity is File &&
          entity.path.endsWith('.dart') &&
          _isGated(entity.path) &&
          !perFile.containsKey(_normalize(entity.path)) &&
          _hasCode(entity))
        _normalize(entity.path),
  ]..sort();

  if (totalFound == 0) {
    stderr.writeln('No gated files found in the coverage report.');
    exit(2);
  }
  final total = totalHit * 100 / totalFound;
  print(
    '\nGated coverage: ${total.toStringAsFixed(1)}% '
    '($totalHit/$totalFound lines), minimum ${minimum.toStringAsFixed(1)}%, '
    'per-file floor ${fileFloor.toStringAsFixed(1)}%',
  );

  var failed = false;
  if (total < minimum) {
    stderr.writeln('Coverage is below the minimum.');
    failed = true;
  }
  if (belowFloor.isNotEmpty) {
    stderr.writeln('Below the per-file floor:');
    belowFloor.forEach(stderr.writeln);
    failed = true;
  }
  if (unloaded.isNotEmpty) {
    stderr.writeln('Not loaded by any test (counted as uncovered):');
    unloaded.forEach(stderr.writeln);
    failed = true;
  }
  if (failed) exit(1);
}
