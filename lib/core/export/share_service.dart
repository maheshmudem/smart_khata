/// Hands text or a file to the Android share sheet (FR-REM-004, WF-052).
///
/// Opening the share sheet is all the app knows. It never learns whether
/// anything was sent, delivered or read, and never says so (ADR-012).
abstract interface class ShareService {
  /// Shares plain [text].
  Future<void> shareText(String text, {String? subject});

  /// Writes [content] to a temporary file named [fileName] and shares it.
  Future<void> shareFile({
    required String fileName,
    required String content,
    required String mimeType,
    String? subject,
  });
}
