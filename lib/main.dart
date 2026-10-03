import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/env.dart';
import 'data/providers.dart';
import 'domain/brand.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final env = await AppEnv.load();
  if (env.isConfigured) {
    await Supabase.initialize(
      url: env.supabaseUrl,
      anonKey: env.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }
  runApp(
    ProviderScope(
      overrides: [
        envProvider.overrideWithValue(env),
      ],
      child: const ShotKitApp(),
    ),
  );
}

/// Deep-link scheme used by Supabase OAuth / email confirmations.
const authRedirect = AppBrand.authRedirect;
