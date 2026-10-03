import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/env.dart';
import 'auth_repository.dart';
import 'billing_repository.dart';
import 'brand_kit_repository.dart';
import 'design_repository.dart';
import 'project_repository.dart';
import 'screen_repository.dart';

final envProvider = Provider<AppEnv>((ref) {
  throw StateError('envProvider must be overridden in ProviderScope');
});

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseProvider), ref.watch(envProvider));
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseProvider).auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(supabaseProvider).auth.currentUser;
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(ref.watch(supabaseProvider));
});

final screenRepositoryProvider = Provider<ScreenRepository>((ref) {
  return ScreenRepository(ref.watch(supabaseProvider));
});

final brandKitRepositoryProvider = Provider<BrandKitRepository>((ref) {
  return BrandKitRepository(ref.watch(supabaseProvider));
});

final designRepositoryProvider = Provider<DesignRepository>((ref) {
  return DesignRepository(ref.watch(supabaseProvider));
});

final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  return BillingRepository(ref.watch(supabaseProvider));
});
