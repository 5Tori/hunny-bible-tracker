import 'package:flutter/material.dart';

import '../../../core/auth/auth_repository.dart';
import '../../../core/auth/neon_auth_models.dart';
import '../../../core/theme/app_theme.dart';

Future<void> showNeonAuthSheet({
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
    builder: (ctx) => _NeonAuthSheetBody(
      authRepository: authRepository,
      onAuthSuccess: onAuthSuccess,
    ),
  );
}

class _NeonAuthSheetBody extends StatefulWidget {
  const _NeonAuthSheetBody({
    required this.authRepository,
    required this.onAuthSuccess,
  });

  final AuthRepository authRepository;
  final Future<void> Function({required bool createdNewAccount}) onAuthSuccess;

  @override
  State<_NeonAuthSheetBody> createState() => _NeonAuthSheetBodyState();
}

class _NeonAuthSheetBodyState extends State<_NeonAuthSheetBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs =
      TabController(length: 2, vsync: this, initialIndex: 0);

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _tabs.dispose();
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submitSignIn() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.authRepository.signInEmail(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      await widget.onAuthSuccess(createdNewAccount: false);
    } on NeonAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitSignUp() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final name = _name.text.trim().isEmpty
          ? _email.text.trim().split('@').first
          : _name.text.trim();
      await widget.authRepository.signUpEmail(
        name: name,
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      await widget.onAuthSuccess(createdNewAccount: true);
    } on NeonAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final maxH = (MediaQuery.sizeOf(context).height * 0.5).clamp(280.0, 420.0);

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: maxH + bottom,
        child: ColoredBox(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sign in',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Neon Auth · email and password. Same account you use in the Neon console.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mutedInk,
                        height: 1.35,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              TabBar(
                controller: _tabs,
                labelColor: AppTheme.ink,
                unselectedLabelColor: AppTheme.mutedInk,
                tabs: const [
                  Tab(text: 'Sign in'),
                  Tab(text: 'Create account'),
                ],
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text(
                    _error!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.red.shade800),
                  ),
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _buildForm(onSubmit: _submitSignIn, showName: false),
                    _buildForm(onSubmit: _submitSignUp, showName: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm({
    required VoidCallback onSubmit,
    required bool showName,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      children: [
        if (showName) ...[
          TextField(
            controller: _name,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _password,
          obscureText: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Password (8+ characters)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _submitting ? null : onSubmit,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.ink,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: _submitting
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(showName ? 'Create account' : 'Sign in'),
        ),
      ],
    );
  }
}
