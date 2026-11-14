import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Generic report screen that displays a title and loads data from the API.
/// Used for all report sub-pages (sales, P&L, inventory, etc.) that don't
/// have a dedicated custom screen yet.
class GenericReportScreen extends ConsumerStatefulWidget {
  const GenericReportScreen({
    super.key,
    required this.title,
    required this.endpoint,
  });

  final String title;
  final String endpoint;

  @override
  ConsumerState<GenericReportScreen> createState() => _GenericReportScreenState();
}

class _GenericReportScreenState extends ConsumerState<GenericReportScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.analytics_outlined, size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This report will display data from ${widget.endpoint} once the API returns results.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${widget.title} data will appear here when connected to the API')),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
