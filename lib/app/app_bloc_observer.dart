import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/logging/app_logger.dart';

/// Logs errors thrown inside any BLoC or cubit.
///
/// Only the BLoC's type is recorded. States and events are never logged:
/// they carry names, amounts and balances.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver(this._logger);

  final AppLogger _logger;

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.error(
      'bloc error in ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
