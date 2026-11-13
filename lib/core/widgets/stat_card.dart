import 'package:flutter/material.dart';

/// Trend direction for [StatCard] deltas.
enum StatDelta { up, down, none }

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.onTap,
    this.delta = StatDelta.none,
    this.deltaLabel,
    this.iconColor,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final Color? iconColor;
  final StatDelta delta;
  final String? deltaLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColorResolved = iconColor ?? theme.colorScheme.onSurfaceVariant;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(icon, size: 18, color: iconColorResolved),
                  if (deltaLabel != null)
                    _DeltaChip(delta: delta, label: deltaLabel!),
                ],
              ),
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: valueColor ?? theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.delta, required this.label});
  final StatDelta delta;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isUp = delta == StatDelta.up;
    final isDown = delta == StatDelta.down;
    final color = isUp ? Colors.green : isDown ? Colors.red : Colors.grey;
    final arrow = isUp ? '▲' : isDown ? '▼' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$arrow $label',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
