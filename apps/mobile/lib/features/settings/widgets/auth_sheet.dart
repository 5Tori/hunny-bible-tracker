import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/auth/auth_models.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/theme/app_theme.dart';

Future<void> showAuthSheet({
  required BuildContext context,
  required AuthRepository authRepository,
  required Future<void> Function({required bool createdNewAccount})
      onAuthSuccess,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _AuthSheetBody(
      authRepository: authRepository,
      onAuthSuccess: onAuthSuccess,
    ),
  );
}

class _AuthSheetBody extends StatefulWidget {
  const _AuthSheetBody({
    required this.authRepository,
    required this.onAuthSuccess,
  });

  final AuthRepository authRepository;
  final Future<void> Function({required bool createdNewAccount}) onAuthSuccess;

  @override
  State<_AuthSheetBody> createState() => _AuthSheetBodyState();
}

class _AuthSheetBodyState extends State<_AuthSheetBody> {
  bool _submitting = false;
  String? _error;

  Future<void> _submitGoogle() async {
    if (!widget.authRepository.isGoogleSignInConfigured) {
      setState(() {
        _error = 'Add GOOGLE_WEB_CLIENT_ID at build time for Google Sign-In.';
      });
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final session = await widget.authRepository.signInWithGoogle();
      if (!mounted) return;
      Navigator.of(context).pop();
      await widget.onAuthSuccess(
        createdNewAccount: session.createdNewAccount,
      );
    } on AppAuthException catch (e) {
      if (e.code == 'cancelled') {
        setState(() => _error = null);
      } else {
        setState(() => _error = e.message);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: ColoredBox(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Sign in',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Continue with your Google account.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mutedInk,
                        height: 1.35,
                      ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.red.shade800),
                  ),
                ],
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: _submitting ? null : _submitGoogle,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.ink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppTheme.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/brand/google_g.svg',
                              width: 22,
                              height: 22,
                            ),
                            const SizedBox(width: 12),
                            const Text('Continue with Google'),
                          ],
                        ),
                ),
                if (!widget.authRepository.isGoogleSignInConfigured) ...[
                  const SizedBox(height: 10),
                  Text(
                    'For Google, add GOOGLE_WEB_CLIENT_ID to the define file.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.mutedInk,
                          fontSize: 11,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
