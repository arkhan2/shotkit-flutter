import 'package:flutter/foundation.dart';
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

  String get oauthRedirect {
    if (kIsWeb) {
      return Uri.base.origin;
    }
    return AppBrand.authRedirect;
  }

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
      if (kIsWeb) {
        return const Err(
          'On the web, use the Google button. It signs in with an ID token.',
        );
      }

      if (!_env.hasGoogle) {
        return const Err(
          'Google Sign-In is not configured. Add GOOGLE_WEB_CLIENT_ID '
          '(the Web client ID from the Supabase Google provider) to '
          'assets/config/app.env.',
        );
      }

      final google = GoogleSignIn(
        clientId:
            _env.googleIosClientId.isEmpty ? null : _env.googleIosClientId,
        serverClientId: _env.googleWebClientId,
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
    } on AuthException catch (e) {
      return Err(e.message);
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<Result<void>> signInWithGoogleIdToken({
    required String idToken,
    String? nonce,
  }) async {
    try {
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        nonce: nonce,
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
