/// Normalised forms used for search and duplicate detection
/// (FR-PAR-003, FR-PAR-004). What the owner typed is stored unchanged
/// alongside.
abstract final class TextNormalizer {
  static final RegExp _whitespace = RegExp(r'\s+');
  static final RegExp _nonDigits = RegExp(r'\D');

  /// Trims and collapses inner whitespace; keeps the owner's spelling.
  static String clean(String input) =>
      input.trim().replaceAll(_whitespace, ' ');

  /// [clean] returning `null` for blank text, for optional fields.
  static String? cleanOrNull(String? input) {
    if (input == null) return null;
    final cleaned = clean(input);
    return cleaned.isEmpty ? null : cleaned;
  }

  /// Search form of a name: cleaned and lower-cased. Telugu has no case,
  /// so Telugu names pass through unchanged apart from whitespace.
  static String name(String input) => clean(input).toLowerCase();

  /// Search form of a phone number: digits only, without the `+91` country
  /// code or a leading trunk `0`. Returns `null` when there are no digits.
  static String? phone(String? input) {
    if (input == null) return null;
    var digits = input.replaceAll(_nonDigits, '');
    if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    } else if (digits.length == 11 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return digits.isEmpty ? null : digits;
  }

  /// Whether [input] is a ten-digit Indian number once normalised.
  static bool isValidPhone(String input) => phone(input)?.length == 10;
}
