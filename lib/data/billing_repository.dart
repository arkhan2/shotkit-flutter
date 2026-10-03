import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/result.dart';
import '../domain/entitlements.dart';

class BillingRepository {
  BillingRepository(this._client);
  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('Not authenticated');
    return id;
  }

  Future<EntitlementSnapshot> snapshot() async {
    final sub = await _client
        .from('subscriptions')
        .select()
        .eq('user_id', _uid)
        .maybeSingle();

    UsagePeriod? usage;
    try {
      final raw = await _client.rpc('ensure_usage_period', params: {
        'p_user_id': _uid,
      });
      if (raw is Map) {
        usage = UsagePeriod(
          id: raw['id'] as String? ?? '',
          exportsCount: (raw['exports_count'] as num?)?.toInt() ?? 0,
          projectsCreated: (raw['projects_created'] as num?)?.toInt() ?? 0,
          designsCreated: (raw['designs_created'] as num?)?.toInt() ?? 0,
          screensUploaded: (raw['screens_uploaded'] as num?)?.toInt() ?? 0,
          fontsUploaded: (raw['fonts_uploaded'] as num?)?.toInt() ?? 0,
          periodStart: DateTime.tryParse(raw['period_start'] as String? ?? '') ??
              DateTime.now(),
          periodEnd: DateTime.tryParse(raw['period_end'] as String? ?? '') ??
              DateTime.now(),
        );
      }
    } catch (_) {}

    final projects = await _client
        .from('projects')
        .select('id')
        .eq('user_id', _uid);
    final projectIds =
        (projects as List).map((p) => (p as Map)['id'] as String).toList();
    var designCount = 0;
    if (projectIds.isNotEmpty) {
      final designs = await _client
          .from('designs')
          .select('id')
          .inFilter('project_id', projectIds);
      designCount = (designs as List).length;
    }
    final kits = await _client.from('brand_kits').select('id').eq('user_id', _uid);
    final fonts = await _client
        .from('assets')
        .select('id')
        .eq('user_id', _uid)
        .eq('type', 'font');

    return buildEntitlementSnapshot(
      planId: sub?['plan_id'] as String?,
      status: sub?['status'] as String?,
      currentPeriodEnd: DateTime.tryParse(
        sub?['current_period_end'] as String? ?? '',
      ),
      cancelAtPeriodEnd: sub?['cancel_at_period_end'] as bool? ?? false,
      resources: ResourceUsage(
        projects: projectIds.length,
        designs: designCount,
        brandKits: (kits as List).length,
        fonts: (fonts as List).length,
      ),
      usagePeriod: usage,
    );
  }

  Future<Result<void>> claimExport(int? limit) async {
    try {
      final data = await _client.rpc(
        'claim_export_usage',
        params: {'p_limit': limit ?? -1},
      );
      if (data is Map && data['ok'] == true) return const Ok(null);
      final message = data is Map
          ? (data['error'] as String? ?? 'Export limit reached.')
          : 'Export claim failed.';
      return Err(message);
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<void> releaseExport() async {
    try {
      await _client.rpc('release_export_usage');
    } catch (_) {}
  }
}
