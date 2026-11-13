import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_button.dart';

/// Reusable error view with an icon, message and a retry button.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.compact = false,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Padding(
      padding: EdgeInsets.all(compact ? 16 : 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: compact ? 56 : 80,
            height: compact ? 56 : 80,
            decoration: BoxDecoration(
              color: AppTheme.dangerLight.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: compact ? 24 : 36,
              color: AppTheme.danger,
            ),
          ),
          SizedBox(height: compact ? 10 : 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isLight
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(height: compact ? 14 : 22),
            AppButton(
              label: 'Try again',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
              expand: false,
              size: AppButtonSize.sm,
            ),
          ],
        ],
      ),
    );
  }
}
