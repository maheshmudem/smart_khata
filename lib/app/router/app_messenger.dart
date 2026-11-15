import 'package:flutter/material.dart';

/// The app-wide snackbar host, and the navigator observer that clears it.
///
/// A "saved" message is shown on the page the owner returns to. If they
/// open the next form straight away, the message must not sit on top of
/// that form's Save button, so it is removed whenever a new page opens.
abstract final class AppMessenger {
  static final GlobalKey<ScaffoldMessengerState> key =
      GlobalKey<ScaffoldMessengerState>();

  static final NavigatorObserver observer = _ClearSnackBarOnPush();
}

class _ClearSnackBarOnPush extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Only for full pages: a dialog or sheet opening must not swallow a
    // message that explains what just happened.
    if (route is PageRoute && previousRoute != null) {
      // The router reports a push while widgets are being built, when the
      // messenger may not rebuild; clear it right after this frame.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => AppMessenger.key.currentState?.removeCurrentSnackBar(),
      );
    }
  }
}
