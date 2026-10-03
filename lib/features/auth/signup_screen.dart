import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/validators.dart';
import '../../data/providers.dart';
import '../../domain/brand.dart';
import '../../shared/widgets.dart';
import '../legal/legal_screen.dart';
import 'google_continue_button.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final emailError = validateEmail(_email.text);
    final passwordError = validatePassword(_password.text);
    if (emailError != null || passwordError != null) {
      setState(() => _error = emailError ?? passwordError);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    final result = await ref.read(authRepositoryProvider).signUpWithEmail(
          email: _email.text,
          password: _password.text,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    result.when(
      ok: (response) {
        if (response.session == null) {
          setState(() {
            _busy = false;
            _info = 'Check your email to confirm the account, then sign in.';
          });
          return;
        }
        context.go('/app');
      },
      err: (message) => setState(() {
        _busy = false;
        _error = message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          children: [
            const BrandMark(size: 64),
            const SizedBox(height: 20),
            Text('Create account', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(
              'Same ShotKit account as the web studio.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppBrand.slate,
                  ),
            ),
            const SizedBox(height: 36),
            if (_error != null) ...[
              ErrorBanner(_error!),
              const SizedBox(height: 16),
            ],
            if (_info != null) ...[
              Text(_info!),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: Text(_busy ? 'Creating…' : 'Create account'),
            ),
            const SizedBox(height: 12),
            GoogleContinueButton(
              busy: _busy,
              onSignedIn: () => context.go('/app'),
              onError: (message) => setState(() => _error = message),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Already have an account? Sign in'),
            ),
            const SizedBox(height: 8),
            const LegalLinks(),
          ],
        ),
      ),
    );
  }
}
