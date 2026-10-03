import 'canvas.dart';
import 'models.dart';

class StoreComplianceRules {
  const StoreComplianceRules({
    required this.presetId,
    required this.platform,
    required this.deviceType,
    required this.displayName,
    required this.minScreenshots,
    required this.maxScreenshots,
  });

  final String presetId;
  final String platform;
  final String deviceType;
  final String displayName;
  final int minScreenshots;
  final int maxScreenshots;
}

const storeComplianceRules = <StoreComplianceRules>[
  StoreComplianceRules(
    presetId: 'iphone_6_9',
    platform: 'app_store',
    deviceType: 'iphone_6_9',
    displayName: 'App Store · iPhone 6.9"',
    minScreenshots: 1,
    maxScreenshots: 10,
  ),
  StoreComplianceRules(
    presetId: 'android_phone',
    platform: 'google_play',
    deviceType: 'android_phone',
    displayName: 'Google Play · Android Phone',
    minScreenshots: 2,
    maxScreenshots: 8,
  ),
  StoreComplianceRules(
    presetId: 'android_7_tablet',
    platform: 'google_play',
    deviceType: 'android_7_tablet',
    displayName: 'Google Play · Android 7" Tablet Portrait',
    minScreenshots: 1,
    maxScreenshots: 8,
  ),
  StoreComplianceRules(
    presetId: 'android_7_tablet_landscape',
    platform: 'google_play',
    deviceType: 'android_7_tablet_landscape',
    displayName: 'Google Play · Android 7" Tablet Landscape',
    minScreenshots: 1,
    maxScreenshots: 8,
  ),
  StoreComplianceRules(
    presetId: 'android_10_tablet',
    platform: 'google_play',
    deviceType: 'android_10_tablet',
    displayName: 'Google Play · Android 10" Tablet Portrait',
    minScreenshots: 1,
    maxScreenshots: 8,
  ),
  StoreComplianceRules(
    presetId: 'android_10_tablet_landscape',
    platform: 'google_play',
    deviceType: 'android_10_tablet_landscape',
    displayName: 'Google Play · Android 10" Tablet Landscape',
    minScreenshots: 1,
    maxScreenshots: 8,
  ),
  StoreComplianceRules(
    presetId: 'google_play_feature_graphic',
    platform: 'google_play',
    deviceType: 'google_play_feature_graphic',
    displayName: 'Google Play · Feature Graphic',
    minScreenshots: 1,
    maxScreenshots: 1,
  ),
];

class ComplianceIssue {
  const ComplianceIssue({
    required this.ruleId,
    required this.severity,
    required this.title,
    required this.message,
    this.currentValue,
    this.expectedValue,
  });

  final String ruleId;
  final String severity;
  final String title;
  final String message;
  final String? currentValue;
  final String? expectedValue;
}

class ComplianceReport {
  const ComplianceReport({
    required this.platform,
    required this.presetDisplayName,
    required this.width,
    required this.height,
    required this.pageCount,
    required this.issues,
    required this.hasErrors,
    required this.hasWarnings,
    required this.canExport,
  });

  final String platform;
  final String presetDisplayName;
  final int width;
  final int height;
  final int pageCount;
  final List<ComplianceIssue> issues;
  final bool hasErrors;
  final bool hasWarnings;
  final bool canExport;
}

StoreComplianceRules? rulesForPreset(String presetId) {
  for (final rule in storeComplianceRules) {
    if (rule.presetId == presetId) return rule;
  }
  return null;
}

ComplianceReport evaluateCompliance({
  required Design design,
  required List<DesignPage> pages,
  String format = 'png',
}) {
  final presetId = pages.isNotEmpty
      ? pages.first.document.canvas.presetId
      : design.deviceType;
  final rules = rulesForPreset(presetId) ??
      storeComplianceRules.cast<StoreComplianceRules?>().firstWhere(
            (r) =>
                r!.platform == design.platform &&
                r.deviceType == design.deviceType,
            orElse: () => null,
          );

  if (rules == null) {
    return ComplianceReport(
      platform: design.platform,
      presetDisplayName: 'Unknown',
      width: design.width,
      height: design.height,
      pageCount: pages.length,
      issues: const [
        ComplianceIssue(
          ruleId: 'supported-preset',
          severity: 'error',
          title: 'Unsupported preset',
          message: 'No compliance rules for this design’s platform/device.',
        ),
      ],
      hasErrors: true,
      hasWarnings: false,
      canExport: false,
    );
  }

  final preset = canvasPresetById(rules.presetId);
  final expectedW = preset?.width ?? design.width;
  final expectedH = preset?.height ?? design.height;
  final issues = <ComplianceIssue>[];

  final dimOk = design.width == expectedW && design.height == expectedH;
  issues.add(
    ComplianceIssue(
      ruleId: 'canvas-dimensions',
      severity: dimOk ? 'success' : 'error',
      title: dimOk ? 'Canvas dimensions' : 'Invalid canvas dimensions',
      message: dimOk
          ? 'Design dimensions match the selected platform preset.'
          : 'Canvas dimensions do not match this platform preset.',
      currentValue: '${design.width} × ${design.height}',
      expectedValue: '$expectedW × $expectedH',
    ),
  );

  final count = pages.length;
  if (count < rules.minScreenshots) {
    issues.add(
      ComplianceIssue(
        ruleId: 'screenshot-count',
        severity: 'error',
        title: 'Too few screenshots',
        message: 'This platform expects at least ${rules.minScreenshots}.',
        currentValue: '$count',
        expectedValue: '${rules.minScreenshots}–${rules.maxScreenshots}',
      ),
    );
  } else if (count > rules.maxScreenshots) {
    issues.add(
      ComplianceIssue(
        ruleId: 'screenshot-count',
        severity: 'warning',
        title: 'Screenshot count high',
        message:
            '$count screenshots created; this platform allows up to ${rules.maxScreenshots}.',
        currentValue: '$count',
        expectedValue: '${rules.minScreenshots}–${rules.maxScreenshots}',
      ),
    );
  } else {
    issues.add(
      ComplianceIssue(
        ruleId: 'screenshot-count',
        severity: 'success',
        title: 'Screenshot count',
        message: 'Page count is within the allowed range.',
        currentValue: '$count',
        expectedValue: '${rules.minScreenshots}–${rules.maxScreenshots}',
      ),
    );
  }

  final formatOk = format == 'png' || format == 'jpeg';
  issues.add(
    ComplianceIssue(
      ruleId: 'file-format',
      severity: formatOk ? 'success' : 'error',
      title: 'File format',
      message: formatOk
          ? '${format.toUpperCase()} is supported.'
          : '${format.toUpperCase()} is not supported.',
      currentValue: format.toUpperCase(),
      expectedValue: 'PNG, JPEG',
    ),
  );

  issues.add(
    ComplianceIssue(
      ruleId: 'export-resolution',
      severity: dimOk ? 'success' : 'error',
      title: 'Export resolution',
      message: dimOk
          ? 'Export will render at the exact canvas pixel size.'
          : 'Export resolution would not match the store preset.',
      currentValue: '${design.width} × ${design.height}',
      expectedValue: '$expectedW × $expectedH',
    ),
  );

  final hasErrors = issues.any((i) => i.severity == 'error');
  final hasWarnings = issues.any((i) => i.severity == 'warning');
  return ComplianceReport(
    platform: rules.platform,
    presetDisplayName: rules.displayName,
    width: expectedW,
    height: expectedH,
    pageCount: pages.length,
    issues: issues,
    hasErrors: hasErrors,
    hasWarnings: hasWarnings,
    canExport: !hasErrors,
  );
}

String sanitizeFilenameSegment(String input) {
  final cleaned = input
      .trim()
      .toLowerCase()
      .replaceAll('..', '')
      .replaceAll(RegExp(r'[\\/]+'), '-')
      .replaceAll(RegExp(r'[<>:"|?*]'), '')
      .replaceAll(RegExp(r'[^\w\s.-]'), '')
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return cleaned.isEmpty ? 'file' : cleaned;
}

String buildPageFilename({
  required int sortIndex,
  String? pageName,
  required String extension,
}) {
  final name = sanitizeFilenameSegment(pageName?.trim().isNotEmpty == true
      ? pageName!
      : 'page');
  final ext = extension == 'jpeg' ? 'jpg' : extension;
  return '${(sortIndex + 1).toString().padLeft(2, '0')}-$name.$ext';
}

String buildZipFilename({
  required String designName,
  required String platform,
}) {
  final design = sanitizeFilenameSegment(designName);
  final label = platform == 'app_store' ? 'app-store' : 'google-play';
  return '$design-$label-screenshots.zip';
}
