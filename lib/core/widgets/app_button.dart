import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Primary call-to-action button. Also exposes secondary, danger and loading
/// variants so call sites stay consistent with the design language.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.expand = true,
    this.size = AppButtonSize.md,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final AppButtonVariant variant;
  final bool expand;
  final AppButtonSize size;

  @override
  State<AppButton> createState() => _AppButtonState();
}

enum AppButtonVariant { primary, secondary, danger }

enum AppButtonSize { sm, md, lg }

class _AppButtonState extends State<AppButton> {
  bool _tapped = false;

  bool get _disabled => widget.onPressed == null || widget.isLoading;

  double get _height {
    switch (widget.size) {
      case AppButtonSize.sm:
        return 40;
      case AppButtonSize.md:
        return 52;
      case AppButtonSize.lg:
        return 56;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case AppButtonSize.sm:
        return 13;
      case AppButtonSize.md:
      case AppButtonSize.lg:
        return 15;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (widget.variant) {
      AppButtonVariant.primary => (AppTheme.primary, Colors.white, null),
      AppButtonVariant.secondary => (
          Colors.transparent,
          AppTheme.primary,
          Border.all(color: AppTheme.lightBorder, width: 1.2),
        ),
      AppButtonVariant.danger => (AppTheme.danger, Colors.white, null),
    };

    final effectiveBg = _disabled ? bg.withOpacity(0.5) : bg;

    return AnimatedScale(
      scale: _tapped ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 90),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: border,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            onTap: _disabled
                ? null
                : () {
                    setState(() => _tapped = true);
                    Future.microtask(() {
                      if (mounted) setState(() => _tapped = false);
                    });
                    widget.onPressed?.call();
                  },
            child: Container(
              height: _height,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(fg),
                      ),
                    )
                  : Row(
                      mainAxisSize:
                          widget.expand ? MainAxisSize.max : MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 18, color: fg),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            widget.label,
                            style: TextStyle(
                              color: fg,
                              fontSize: _fontSize,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.trailingIcon != null) ...[
                          const SizedBox(width: 8),
                          Icon(widget.trailingIcon, size: 18, color: fg),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact icon-only circular button.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      tooltip: tooltip,
      color: color ?? Theme.of(context).iconTheme.color,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
      ),
    );
  }
}
