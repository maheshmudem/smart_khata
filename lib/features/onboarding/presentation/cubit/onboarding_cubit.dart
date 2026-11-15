import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/features/settings/domain/settings_repository.dart';

/// Whether first-run setup is finished. The router listens to this and
/// keeps the owner in onboarding until it is `true`.
class OnboardingCubit extends Cubit<bool> {
  OnboardingCubit({
    required this._settings,
    required bool isComplete,
  }) : super(isComplete);

  final SettingsRepository _settings;

  /// Marks setup as finished. Returns `false`, and stays in onboarding,
  /// when the flag could not be saved.
  Future<bool> complete() async {
    if (state) return true;
    final result = await _settings.markOnboardingComplete();
    if (result is Err) return false;
    emit(true);
    return true;
  }
}
