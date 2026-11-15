import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_theme.dart';

/// A labelled text field with the app's validation presentation.
///
/// [errorText] comes from BLoC state, so the entered text survives a failed
/// validation or save.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.errorText,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.isRequired = false,
    this.autofocus = false,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool isRequired;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        errorText: errorText,
        helperText: helperText,
        counterText: '',
      ),
    );
  }
}

/// Amount entry in rupees and paise.
///
/// Opens the numeric keypad, accepts at most two decimal places and reports
/// the value as [Money] (integer paise). `null` means the field is empty or
/// not yet a valid amount. No `double` is involved at any point.
class MoneyAmountField extends StatefulWidget {
  const MoneyAmountField({
    required this.label,
    required this.onChanged,
    this.initialValue,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
    super.key,
  });

  final String label;
  final ValueChanged<Money?> onChanged;
  final Money? initialValue;
  final String? errorText;
  final bool enabled;
  final bool autofocus;
  final TextInputAction? textInputAction;

  @override
  State<MoneyAmountField> createState() => _MoneyAmountFieldState();
}

class _MoneyAmountFieldState extends State<MoneyAmountField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue == null
        ? ''
        : MoneyFormatter.toInputText(widget.initialValue!),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      textInputAction: widget.textInputAction,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: const [AmountInputFormatter()],
      style: AppTheme.amountStyle(theme.textTheme.headlineSmall),
      onChanged: (text) => widget.onChanged(Money.tryParse(text)),
      decoration: InputDecoration(
        labelText: '${widget.label} *',
        prefixText: '${MoneyFormatter.rupeeSymbol} ',
        prefixStyle: AppTheme.amountStyle(theme.textTheme.headlineSmall),
        errorText: widget.errorText,
      ),
    );
  }
}

/// Keeps amount input to digits with an optional two-digit decimal part and
/// a rupee part of at most nine digits. An edit that would break that is
/// rejected, leaving the previous text in place.
class AmountInputFormatter extends TextInputFormatter {
  const AmountInputFormatter();

  static final RegExp _allowed = RegExp(r'^\d{0,9}(\.\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => _allowed.hasMatch(newValue.text) ? newValue : oldValue;
}
