import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/env.dart';
import '../core/result.dart';
import '../domain/brand.dart';

class AuthRepository {
  AuthRepository(this._client, this._env);

  final SupabaseClient _client;
  final AppEnv _env;

  User? get currentUser => _client.auth.currentUser;
  Session? get session => _client.auth.currentSession;

  Future<Result<AuthResponse>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.session == null) {
        return const Err(
          'Signed in, but the account still needs email confirmation.',
        );
      }
      return Ok(response);
    } on AuthException catch (e) {
      return Err(_authMessage(e.message));
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<Result<AuthResponse>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      return Ok(response);
    } on AuthException catch (e) {
      return Err(_authMessage(e.message));
    } catch (e) {
      return Err(e.toString());
    }
  }

  String _authMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login') || lower.contains('invalid credentials')) {
      return 'Email or password is incorrect.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Confirm this email in ShotKit web first, then sign in here.';
    }
    return message;
  }

  Future<Result<void>> signInWithGoogle() async {
    try {
      if (_env.hasGoogle) {
        final google = GoogleSignIn(
          serverClientId: _env.googleWebClientId,
          clientId:
              _env.googleIosClientId.isEmpty ? null : _env.googleIosClientId,
          scopes: const ['email', 'profile'],
        );
        final account = await google.signIn();
        if (account == null) return const Err('Google sign-in was cancelled.');
        final auth = await account.authentication;
        final idToken = auth.idToken;
        if (idToken == null) {
          return const Err('Google did not return an ID token.');
        }
        await _client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: auth.accessToken,
        );
        return const Ok(null);
      }

      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: AppBrand.authRedirect,
      );
      return const Ok(null);
    } on AuthException catch (e) {
      return Err(e.message);
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _client.auth.signOut();
  }
}
