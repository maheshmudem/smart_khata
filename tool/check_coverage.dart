// Coverage gate for the code that holds the rules: lib/core (except UI
// and generated code) and every feature's domain layer.
//
//   flutter test --coverage
//   dart run tool/check_coverage.dart [minimum-percent]
//
// A build tool, so writing to stdout is intended.
// ignore_for_file: avoid_print
import 'dart:io';

const _defaultMinimum = 90.0;

bool _isGated(String path) {
  final p = path.replaceAll(r'\', '/');
  if (p.endsWith('.g.dart')) return false;
  if (p.contains('/domain/')) return true;
  if (!p.startsWith('lib/core/')) return false;
  // Widgets and theme are covered by widget tests, not by this gate.
  return !p.startsWith('lib/core/widgets/') && !p.startsWith('lib/core/theme/');
}

void main(List<String> args) {
  final minimum = args.isEmpty ? _defaultMinimum : double.parse(args.first);
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
      current = line.substring(3);
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
  final paths = perFile.keys.toList()..sort();
  for (final path in paths) {
    final (fileHit, fileFound) = perFile[path]!;
    totalHit += fileHit;
    totalFound += fileFound;
    final percent = fileFound == 0 ? 100.0 : fileHit * 100 / fileFound;
    print('${percent.toStringAsFixed(1).padLeft(6)}%  $path');
  }

  if (totalFound == 0) {
    stderr.writeln('No gated files found in the coverage report.');
    exit(2);
  }
  final total = totalHit * 100 / totalFound;
  print(
    '\nGated coverage: ${total.toStringAsFixed(1)}% '
    '($totalHit/$totalFound lines), minimum ${minimum.toStringAsFixed(1)}%',
  );
  if (total < minimum) {
    stderr.writeln('Coverage is below the minimum.');
    exit(1);
  }
}
