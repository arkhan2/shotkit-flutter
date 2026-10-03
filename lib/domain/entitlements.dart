class PlanLimits {
  const PlanLimits({
    this.maxProjects,
    this.maxDesigns,
    this.maxExportsPerMonth,
    this.maxScreensPerProject,
    this.maxBrandKits,
    this.maxFonts,
  });

  final int? maxProjects;
  final int? maxDesigns;
  final int? maxExportsPerMonth;
  final int? maxScreensPerProject;
  final int? maxBrandKits;
  final int? maxFonts;
}

class PlanDefinition {
  const PlanDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.limits,
    required this.features,
    required this.priceLabel,
  });

  final String id;
  final String name;
  final String description;
  final PlanLimits limits;
  final List<String> features;
  final String priceLabel;
}

const allFeatures = [
  'advanced-templates',
  'advanced-mockups',
  'advanced-text-effects',
  'abstract-backgrounds',
  'custom-fonts',
  'watermark-free-export',
  'high-export-limits',
];

/// Matches web runtime: Free currently unlocked like Pro while Polar is deferred.
const plans = {
  'free': PlanDefinition(
    id: 'free',
    name: 'Free',
    description: 'Try ShotKit and design store screenshots.',
    priceLabel: '\$0',
    limits: PlanLimits(
      maxExportsPerMonth: 100,
      maxScreensPerProject: 100,
      maxFonts: 50,
    ),
    features: allFeatures,
  ),
  'pro': PlanDefinition(
    id: 'pro',
    name: 'Pro',
    description: 'Unlimited creative work and store-ready exports.',
    priceLabel: '\$29/mo',
    limits: PlanLimits(
      maxExportsPerMonth: 100,
      maxScreensPerProject: 100,
      maxFonts: 50,
    ),
    features: allFeatures,
  ),
};

const freeTemplateIds = {'system_bold_headline', 'system_clean_focus'};

class UsagePeriod {
  const UsagePeriod({
    required this.id,
    required this.exportsCount,
    required this.projectsCreated,
    required this.designsCreated,
    required this.screensUploaded,
    required this.fontsUploaded,
    required this.periodStart,
    required this.periodEnd,
  });

  final String id;
  final int exportsCount;
  final int projectsCreated;
  final int designsCreated;
  final int screensUploaded;
  final int fontsUploaded;
  final DateTime periodStart;
  final DateTime periodEnd;
}

class ResourceUsage {
  const ResourceUsage({
    required this.projects,
    required this.designs,
    required this.brandKits,
    required this.fonts,
  });

  final int projects;
  final int designs;
  final int brandKits;
  final int fonts;
}

class EntitlementSnapshot {
  const EntitlementSnapshot({
    required this.planId,
    required this.planName,
    required this.status,
    required this.limits,
    required this.features,
    required this.resources,
    this.usagePeriod,
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
    required this.isPaid,
    this.billingWarning,
  });

  final String planId;
  final String planName;
  final String status;
  final PlanLimits limits;
  final List<String> features;
  final ResourceUsage resources;
  final UsagePeriod? usagePeriod;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final bool isPaid;
  final String? billingWarning;

  bool hasFeature(String id) => features.contains(id);
}

class EntitlementCheck {
  const EntitlementCheck.ok() : ok = true, message = null;
  const EntitlementCheck.deny(this.message) : ok = false;
  final bool ok;
  final String? message;
}

({String planId, String status, bool isPaid}) resolveEffectivePlanId({
  required String? planId,
  required String? status,
  DateTime? currentPeriodEnd,
  bool cancelAtPeriodEnd = false,
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  if (planId == null || planId == 'free') {
    return (planId: 'free', status: status ?? 'none', isPaid: false);
  }
  if (status == 'active' || status == 'trialing' || status == 'past_due') {
    return (planId: planId, status: status ?? 'active', isPaid: true);
  }
  if (status == 'canceled' &&
      cancelAtPeriodEnd &&
      currentPeriodEnd != null &&
      currentPeriodEnd.isAfter(clock)) {
    return (planId: planId, status: status ?? 'canceled', isPaid: true);
  }
  return (planId: 'free', status: status ?? 'none', isPaid: false);
}

EntitlementSnapshot buildEntitlementSnapshot({
  required String? planId,
  required String? status,
  DateTime? currentPeriodEnd,
  bool cancelAtPeriodEnd = false,
  required ResourceUsage resources,
  UsagePeriod? usagePeriod,
}) {
  final resolved = resolveEffectivePlanId(
    planId: planId,
    status: status,
    currentPeriodEnd: currentPeriodEnd,
    cancelAtPeriodEnd: cancelAtPeriodEnd,
  );
  final plan = plans[resolved.planId] ?? plans['free']!;
  String? warning;
  if (resolved.status == 'past_due') {
    warning =
        'Payment failed. Update billing to keep Pro access without interruption.';
  } else if (cancelAtPeriodEnd && currentPeriodEnd != null) {
    warning = 'Pro access continues until ${currentPeriodEnd.toLocal()}.';
  }
  return EntitlementSnapshot(
    planId: resolved.planId,
    planName: plan.name,
    status: resolved.status,
    limits: plan.limits,
    features: plan.features,
    resources: resources,
    usagePeriod: usagePeriod,
    currentPeriodEnd: currentPeriodEnd,
    cancelAtPeriodEnd: cancelAtPeriodEnd,
    isPaid: resolved.isPaid,
    billingWarning: warning,
  );
}

bool _within(int current, int? limit) => limit == null || current < limit;

EntitlementCheck canCreateProject(EntitlementSnapshot snapshot) {
  if (!_within(snapshot.resources.projects, snapshot.limits.maxProjects)) {
    return const EntitlementCheck.deny('Project limit reached. Upgrade on web.');
  }
  return const EntitlementCheck.ok();
}

EntitlementCheck canCreateDesign(EntitlementSnapshot snapshot) {
  if (!_within(snapshot.resources.designs, snapshot.limits.maxDesigns)) {
    return const EntitlementCheck.deny('Design limit reached. Upgrade on web.');
  }
  return const EntitlementCheck.ok();
}

EntitlementCheck canCreateBrandKit(EntitlementSnapshot snapshot) {
  if (!_within(snapshot.resources.brandKits, snapshot.limits.maxBrandKits)) {
    return const EntitlementCheck.deny('Brand Kit limit reached. Upgrade on web.');
  }
  return const EntitlementCheck.ok();
}

EntitlementCheck canUploadScreen(EntitlementSnapshot snapshot, int inProject) {
  if (!_within(inProject, snapshot.limits.maxScreensPerProject)) {
    return const EntitlementCheck.deny(
      'Screenshot limit reached for this project.',
    );
  }
  return const EntitlementCheck.ok();
}

EntitlementCheck canExport(EntitlementSnapshot snapshot) {
  final limit = snapshot.limits.maxExportsPerMonth;
  final used = snapshot.usagePeriod?.exportsCount ?? 0;
  if (limit != null && used >= limit) {
    return EntitlementCheck.deny(
      'You have used $used of $limit exports this month.',
    );
  }
  return const EntitlementCheck.ok();
}

bool shouldApplyExportWatermark(EntitlementSnapshot snapshot) {
  return !snapshot.hasFeature('watermark-free-export');
}

EntitlementCheck isTemplateAllowed(
  EntitlementSnapshot snapshot,
  String templateId,
) {
  if (freeTemplateIds.contains(templateId)) return const EntitlementCheck.ok();
  if (snapshot.hasFeature('advanced-templates')) {
    return const EntitlementCheck.ok();
  }
  return const EntitlementCheck.deny('This template is available on Pro.');
}

EntitlementCheck isMockupAllowed(EntitlementSnapshot snapshot, String mockupId) {
  const free = {
    'modern-iphone',
    'android-phone',
    'android-7-tablet',
    'android-7-tablet-landscape',
    'android-10-tablet',
    'android-10-tablet-landscape',
  };
  if (free.contains(mockupId) || snapshot.hasFeature('advanced-mockups')) {
    return const EntitlementCheck.ok();
  }
  return const EntitlementCheck.deny('This mockup is available on Pro.');
}
