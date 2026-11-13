import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';

/// Accept-invitation screen. Reached via a deep link carrying a `token`
/// query param. Calls the backend accept endpoint then refreshes the session.
class AcceptInvitationScreen extends ConsumerStatefulWidget {
  const AcceptInvitationScreen({super.key, this.token});

  final String? token;

  @override
  ConsumerState<AcceptInvitationScreen> createState() =>
      _AcceptInvitationScreenState();
}

class _AcceptInvitationScreenState extends ConsumerState<AcceptInvitationScreen> {
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _accept());
  }

  Future<void> _accept() async {
    final token = widget.token;
    if (token == null || token.isEmpty) {
      setState(() {
        _busy = false;
        _error = 'This invitation link is missing a token.';
      });
      return;
    }
    try {
      await ref.read(authNotifierProvider.notifier).acceptInvitation(token);
      if (!mounted) return;
      context.go('/home');
    } on ApiError catch (e) {
      setState(() {
        _busy = false;
        _error = e.message;
      });
    } catch (_) {
      setState(() {
        _busy = false;
        _error = 'We could not accept this invitation. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _busy
            ? const LoadingIndicator(message: 'Accepting invitation…')
            : _error != null
                ? ErrorView(
                    title: 'Invitation failed',
                    message: _error!,
                    onRetry: () {
                      setState(() {
                        _busy = true;
                        _error = null;
                      });
                      _accept();
                    },
                  )
                : const SizedBox.shrink(),
      ),
    );
  }
}
