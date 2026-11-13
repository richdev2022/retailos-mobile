import 'package:intl/intl.dart';

/// Display formatters. All input [DateTime]s are assumed to be UTC (as they
/// arrive from the API); outputs are localized to the device timezone.
class Formatters {
  Formatters._();

  static final DateFormat _date = DateFormat('d MMM yyyy');
  static final DateFormat _dateTime = DateFormat('d MMM yyyy, h:mm a');
  static final DateFormat _time = DateFormat('h:mm a');
  static final DateFormat _receiptDate = DateFormat('dd MMM yyyy, HH:mm');

  /// "12 Nov 2025"
  static String formatDate(DateTime? date) {
    if (date == null) return '—';
    return _date.format(date.toLocal());
  }

  /// "12 Nov 2025, 3:45 PM"
  static String formatDateTime(DateTime? date) {
    if (date == null) return '—';
    return _dateTime.format(date.toLocal());
  }

  /// "3:45 PM"
  static String formatTime(DateTime? date) {
    if (date == null) return '—';
    return _time.format(date.toLocal());
  }

  /// Compact receipt-friendly timestamp: "12 Nov 2025, 15:45"
  static String formatReceiptTimestamp(DateTime? date) {
    if (date == null) return '—';
    return _receiptDate.format(date.toLocal());
  }

  /// Relative time: "just now", "5m ago", "2h ago", "3d ago", else a date.
  static String formatRelative(DateTime? date, {DateTime? now}) {
    if (date == null) return '—';
    final reference = (now ?? DateTime.now());
    final diff = reference.difference(date.toLocal());

    if (diff.isNegative) return 'just now';
    if (diff.inSeconds < 45) return 'just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '${m}m ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '${h}h ago';
    }
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return '${d}d ago';
    }
    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      return '${w}w ago';
    }
    return formatDate(date);
  }

  /// Format a receipt number for display, padding to a fixed width.
  /// Accepts either a bare integer (123 -> "ROS-000123") or a pre-formatted
  /// string ("ROS-123" -> "ROS-000123") — returns the input untouched if it
  /// can't be parsed.
  static String formatReceiptNo(String? input) {
    if (input == null || input.isEmpty) return '—';
    // Already has a prefix.
    if (input.contains('-')) {
      final parts = input.split('-');
      if (parts.length == 2) {
        final n = int.tryParse(parts[1]);
        if (n != null) return '${parts[0]}-${n.toString().padLeft(6, '0')}';
      }
      return input;
    }
    final n = int.tryParse(input);
    if (n == null) return input;
    return 'ROS-${n.toString().padLeft(6, '0')}';
  }
}
