/// Facts about this build. `version` must equal the `version:` line of
/// `pubspec.yaml` without the build number; a test keeps the two in step.
abstract final class AppInfo {
  static const String version = '1.0.0';

  /// How owners reach support. `null` until a real contact exists; the
  /// Help page then shows no contact at all (WF-083, open decision 5).
  static const String? supportContact = null;
}
