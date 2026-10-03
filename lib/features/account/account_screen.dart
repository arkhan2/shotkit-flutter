import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/providers.dart';
import '../../domain/brand.dart';
import '../../domain/entitlements.dart';
import '../../shared/widgets.dart';
import '../legal/legal_screen.dart';

final entitlementsProvider = FutureProvider<EntitlementSnapshot>((ref) {
  ref.watch(currentUserProvider);
  return ref.watch(billingRepositoryProvider).snapshot();
});

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final entitlements = ref.watch(entitlementsProvider);
    final env = ref.watch(envProvider);

    return Scaffold(
      appBar: const ShotKitAppBar(title: 'Account'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const BrandMark(size: 48),
          const SizedBox(height: 12),
          Text(user?.email ?? 'Signed in', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          entitlements.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => ErrorBanner(e.toString()),
            data: (snap) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (snap.billingWarning != null) ...[
                  ErrorBanner(snap.billingWarning!),
                  const SizedBox(height: 12),
                ],
                Card(
                  child: ListTile(
                    title: Text('${snap.planName} plan'),
                    subtitle: Text(
                      snap.isPaid ? 'Pro features unlocked' : 'Manage upgrades on the web studio',
                    ),
                    trailing: Text(snap.status),
                  ),
                ),
                const SizedBox(height: 12),
                _UsageRow(
                  label: 'Exports this month',
                  value: '${snap.usagePeriod?.exportsCount ?? 0} / ${snap.limits.maxExportsPerMonth ?? '∞'}',
                ),
                _UsageRow(label: 'Projects', value: '${snap.resources.projects}'),
                _UsageRow(label: 'Designs', value: '${snap.resources.designs}'),
                _UsageRow(label: 'Brand Kits', value: '${snap.resources.brandKits}'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => launchUrl(
                    Uri.parse(env.billingUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text(
                    env.isLocalWebUrl
                        ? 'Open local studio'
                        : 'Manage on web',
                  ),
                ),
                if (env.isLocalWebUrl) ...[
                  const SizedBox(height: 8),
                  Text(
                    'SHOTKIT_WEB_URL is still localhost. Set the production ShotKit web URL when the studio is deployed.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            child: const Text('Sign out'),
          ),
          const SizedBox(height: 16),
          const LegalLinks(),
          const SizedBox(height: 16),
          Text(
            '${AppBrand.name} companion · same account as the web studio',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppBrand.slate),
          ),
        ],
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class SetupRequiredScreen extends StatelessWidget {
  const SetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EmptyState(
        title: 'Connect Supabase',
        message:
            'Add SUPABASE_URL and SUPABASE_ANON_KEY to assets/config/app.env (same project as ShotKit web). Never add a service-role key.',
      ),
    );
  }
}
