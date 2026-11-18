/// Cleaning rules for names and phone numbers typed by the owner.
///
/// What the owner typed is stored as typed (tidied of extra spaces); the
/// normalised forms are stored beside it only for search and duplicate
/// detection (schema 3.2).
abstract final class ContactText {
  static final RegExp _spaces = RegExp(r'\s+');
  static final RegExp _nonDigits = RegExp(r'\D');

  /// Trims and collapses runs of whitespace to one space.
  static String tidy(String text) => text.trim().replaceAll(_spaces, ' ');

  /// [tidy], or `null` when nothing is left.
  static String? optional(String? text) {
    if (text == null) return null;
    final tidied = tidy(text);
    return tidied.isEmpty ? null : tidied;
  }

  /// The search form of a name: tidied and lower-case.
  static String searchKey(String text) => tidy(text).toLowerCase();

  /// The ten-digit Indian mobile number in [input], or `null` when it is not
  /// one. Accepts spaces, dashes, a `+91` / `91` prefix or a leading `0`.
  ///
  /// The first digit is not checked: shared shop and landline-style numbers
  /// are common and a stricter rule would reject real numbers.
  static String? normalizePhone(String input) {
    var digits = input.replaceAll(_nonDigits, '');
    if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    } else if (digits.length == 11 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return digits.length == 10 ? digits : null;
  }

  /// A stored ten-digit number written the way people read it:
  /// `98765 43210`, joined by a no-break space so a number never splits
  /// across two lines. Anything else is returned unchanged.
  static String displayPhone(String phone) => phone.length == 10
      ? '${phone.substring(0, 5)} ${phone.substring(5)}'
      : phone;

  /// Only the digits of [input], for matching a partly typed phone search.
  static String digitsOf(String input) => input.replaceAll(_nonDigits, '');
}
