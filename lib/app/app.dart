import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../domain/brand.dart';
import '../features/account/account_screen.dart';
import 'router.dart';
import 'theme.dart';

class ShotKitApp extends ConsumerWidget {
  const ShotKitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(envProvider);
    if (!env.isConfigured) {
      return MaterialApp(
        title: AppBrand.name,
        theme: buildShotKitTheme(brightness: Brightness.light),
        darkTheme: buildShotKitTheme(brightness: Brightness.dark),
        home: const SetupRequiredScreen(),
      );
    }
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: AppBrand.name,
      theme: buildShotKitTheme(brightness: Brightness.light),
      darkTheme: buildShotKitTheme(brightness: Brightness.dark),
      routerConfig: router,
    );
  }
}
