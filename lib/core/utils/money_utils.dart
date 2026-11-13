import 'package:intl/intl.dart';

/// Money helpers. All monetary values in RetailOS are stored and computed as
/// [int] minor units (kobo for NGN: 1 naira = 100 kobo). Never use double.
class MoneyUtils {
  MoneyUtils._();

  /// Format a minor-units amount into a localized currency string.
  ///
  /// Example:
  ///   formatMinor(125050, 'NGN')  -> "₦1,250.50"
  ///   formatMinor(125050, 'USD')  -> "$1,250.50"
  ///   formatMinor(125050, 'KES')  -> "KES 1,250.50"
  static String formatMinor(int minor, String currency) {
    if (minor == 0) return '${_symbol(currency)}0.00';

    final major = toMajor(minor);
    final symbol = _symbol(currency);
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final formatted = formatter.format(major.abs());

    final sign = minor < 0 ? '-' : '';
    if (currency == 'NGN' || currency == 'USD' || currency == 'GBP') {
      return '$sign$symbol$formatted';
    }
    return '$sign$symbol $formatted';
  }

  /// Format without decimals (rounded to major units). Useful for compact
  /// stat cards. Example: formatMinorCompact(125050, 'NGN') -> "₦1,250".
  static String formatMinorCompact(int minor, String currency) {
    final major = toMajor(minor);
    final symbol = _symbol(currency);
    final formatter = NumberFormat('#,##0', 'en_US');
    final formatted = formatter.format(major.abs());
    final sign = minor < 0 ? '-' : '';
    if (currency == 'NGN' || currency == 'USD' || currency == 'GBP') {
      return '$sign$symbol$formatted';
    }
    return '$sign$symbol $formatted';
  }

  /// Convert minor units to a major-units double for display only.
  /// Do NOT use the result for arithmetic — keep money as int.
  static double toMajor(int minor) => minor / 100.0;

  /// Parse a decimal string ("1250.50") to minor units (125050).
  /// Handles commas and stray whitespace. Returns 0 on parse failure.
  static int toMinor(String decimalString) {
    final cleaned = decimalString
        .replaceAll(RegExp(r'[^0-9.\-]'), '')
        .trim();
    if (cleaned.isEmpty) return 0;
    final value = double.tryParse(cleaned);
    if (value == null) return 0;
    return (value * 100).round();
  }

  static String _symbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'NGN':
        return '₦';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      case 'GHS':
        return '₵';
      case 'KES':
        return 'KES';
      case 'ZAR':
        return 'R';
      default:
        return currency;
    }
  }
}
