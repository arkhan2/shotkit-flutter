import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/validators.dart';
import '../../data/providers.dart';
import '../../domain/brand.dart';
import '../../shared/widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

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
    });
    final result = await ref.read(authRepositoryProvider).signInWithEmail(
          email: _email.text,
          password: _password.text,
        );
    if (!mounted) return;
    result.when(
      ok: (_) => context.go('/app'),
      err: (message) => setState(() {
        _busy = false;
        _error = message;
      }),
    );
  }

  Future<void> _google() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(authRepositoryProvider).signInWithGoogle();
    if (!mounted) return;
    setState(() => _busy = false);
    result.when(ok: (_) {}, err: (message) => setState(() => _error = message));
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
            Text(AppBrand.name, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(
              'App Store and Google Play screenshots, made fast.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppBrand.slate,
                  ),
            ),
            const SizedBox(height: 36),
            if (_error != null) ...[
              ErrorBanner(_error!),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _busy ? null : _submit(),
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: Text(_busy ? 'Signing in…' : 'Sign in'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _busy ? null : _google,
              child: const Text('Continue with Google'),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go('/signup'),
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
