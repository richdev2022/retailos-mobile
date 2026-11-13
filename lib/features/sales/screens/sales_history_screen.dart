import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/paginated_list_screen.dart';

class SalesHistoryScreen extends PaginatedListScreen<Map<String, dynamic>> {
  const SalesHistoryScreen({super.key});

  @override
  String get title => 'Sales';
  @override
  String get searchHint => 'Search by receipt number...';
  @override
  String get endpoint => '/sales';

  @override
  Map<String, dynamic> itemFromJson(Map<String, dynamic> json) => json;

  @override
  Widget buildListItem(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final receiptNo = item['receiptNo'] as String? ?? '';
    final totalMinor = item['totalMinor']?.toString() ?? '0';
    final total = (BigInt.tryParse(totalMinor) ?? BigInt.zero) / BigInt.from(100);
    final status = item['status'] as String? ?? '';
    final saleDate = DateTime.tryParse(item['saleDate']?.toString() ?? '') ?? DateTime.now();

    Color statusColor = theme.colorScheme.onSurfaceVariant;
    if (status == 'COMPLETED') statusColor = Colors.green;
    if (status == 'CANCELLED') statusColor = theme.colorScheme.error;
    if (status == 'REFUNDED') statusColor = Colors.orange;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.receipt_long, color: theme.colorScheme.primary),
        ),
        title: Text(receiptNo, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text('${_formatDate(saleDate)}  •  $status', style: theme.textTheme.bodySmall?.copyWith(color: statusColor)),
        trailing: Text('₦${total.toStringAsFixed(2)}', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }
}
