import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/logging/app_logger.dart';

import '../../helpers/fakes.dart';

void main() {
  test('outside debug detail, an error is reduced to its type', () {
    // A database error's text carries statement parameters, i.e. customer
    // names and amounts.
    final error = StateError('INSERT ... parameters: Ravi Kumar, 180000');

    final release = AppLogger.describeError(error, verbose: false);
    expect(release, 'StateError');
    expect(release, isNot(contains('Ravi')));

    expect(AppLogger.describeError(error, verbose: true), contains('Ravi'));
    expect(AppLogger.describeError(null, verbose: false), isNull);
  });

  test('records level, message and stack trace', () {
    final logger = RecordingLogger();
    final stack = StackTrace.current;

    logger
      ..info('started')
      ..warning('slow query')
      ..error('write failed', error: StateError('x'), stackTrace: stack);

    expect(logger.records.map((r) => r.level), [
      LogLevel.info,
      LogLevel.warning,
      LogLevel.error,
    ]);
    expect(logger.records.last.message, 'write failed');
    expect(logger.records.last.stackTrace, stack);
  });
}
