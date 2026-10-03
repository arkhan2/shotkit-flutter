import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import 'google_web_gis_stub.dart'
    if (dart.library.html) 'google_web_gis_web.dart';

class GoogleContinueButton extends ConsumerWidget {
  const GoogleContinueButton({
    super.key,
    required this.onSignedIn,
    required this.onError,
    this.busy = false,
  });

  final VoidCallback onSignedIn;
  final ValueChanged<String> onError;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(envProvider);
    if (kIsWeb) {
      if (!env.hasGoogle) {
        return const Text('Google Sign-In is not configured for web.');
      }
      return GoogleWebGisButton(
        clientId: env.googleWebClientId,
        onError: onError,
        onCredential: (idToken, nonce) async {
          final result = await ref.read(authRepositoryProvider).signInWithGoogleIdToken(
                idToken: idToken,
                nonce: nonce,
              );
          if (!context.mounted) return;
          result.when(ok: (_) => onSignedIn(), err: onError);
        },
      );
    }

    return OutlinedButton(
      onPressed: busy
          ? null
          : () async {
              final result =
                  await ref.read(authRepositoryProvider).signInWithGoogle();
              if (!context.mounted) return;
              result.when(
                ok: (_) => onSignedIn(),
                err: onError,
              );
            },
      child: const Text('Continue with Google'),
    );
  }
}
