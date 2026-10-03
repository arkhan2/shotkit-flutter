import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/providers.dart';
import '../../domain/brand.dart';
import '../../shared/widgets.dart';

enum LegalDocument { privacy, terms }

class LegalScreen extends ConsumerWidget {
  const LegalScreen({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(envProvider);
    final isPrivacy = document == LegalDocument.privacy;
    final title = isPrivacy ? 'Privacy Policy' : 'Terms of Use';
    final hosted = isPrivacy ? env.privacyUrl : env.termsUrl;
    final body = isPrivacy ? _privacyBody : _termsBody;

    return Scaffold(
      appBar: ShotKitAppBar(title: title),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'Last updated: 3 October 2026',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Text(body),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => launchUrl(
              Uri.parse(hosted),
              mode: LaunchMode.externalApplication,
            ),
            child: const Text('Open hosted copy'),
          ),
        ],
      ),
    );
  }
}

class LegalLinks extends StatelessWidget {
  const LegalLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => context.push('/legal/privacy'),
          child: const Text('Privacy'),
        ),
        Text(
          '·',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        TextButton(
          onPressed: () => context.push('/legal/terms'),
          child: const Text('Terms'),
        ),
      ],
    );
  }
}

const _privacyBody = '''
${AppBrand.name} (“we”, “us”) is a screenshot studio for App Store and Google Play listings. This companion app uses the same account and data as the ShotKit web studio.

What we collect
• Account data: email address and sign-in identifiers from email/password or Google Sign-In, stored in our Supabase project.
• Project content you upload: app screenshots, Brand Kit logos, colors, and design documents.
• Usage counters needed to enforce export and resource limits (for example exports this month).
• Device-level permissions you grant: camera (to capture screens), photo library (to pick screens/logos and save exports).

How we use it
• To sign you in and keep your projects, Brand Kits, and designs in sync with the web studio.
• To render and export store screenshots to Photos or the system share sheet.
• To apply the same entitlement snapshot as the web app.

Where it is stored
Uploads go to private storage under your user id (users/{uid}/…). We do not put a service-role key in this app. Signed URLs are short-lived and used only to preview and export your files.

Sharing
We do not sell your personal information. Processors we rely on include Supabase (auth, database, storage) and Google (optional Sign-In). Exports you save or share leave the app under your control.

Retention
You can delete screens, designs, Brand Kits, and projects in the app. Deleting your account is handled from the web studio. Cached preview images may remain on device until the OS clears them.

Your choices
You can refuse camera or photo access; those features will not work. You can sign out at any time. Contact us from the Account screen or the hosted policy if you need a data request.

Children
${AppBrand.name} is not directed at children under 13.

Changes
We will update this page when the product’s data practices change.''';

const _termsBody = '''
These Terms cover the ${AppBrand.name} companion app. By creating an account or using the app you agree to them.

The product
${AppBrand.name} helps you compose App Store and Google Play screenshot sets. v1 is a guided composer. Designs use the same document schema as the web studio and can be opened there.

Your account
You must use the same credentials as ShotKit web. You are responsible for the content you upload and for keeping your password confidential. Do not upload content you do not have the right to use.

Acceptable use
Do not abuse the service, attempt unauthorized access, or upload malware. Store listing screenshots must follow Apple and Google policies — we surface compliance checks, but you remain responsible for what you submit to the stores.

Exports and plans
Export limits and paid features follow the same entitlement snapshot as the web studio. Billing checkout stays on the web. If a render or save fails after a credit is claimed, the app releases that credit.

Limitation
The app is provided “as is”. We are not liable for rejected store listings, lost exports, or indirect damages to the extent permitted by law.

Changes and contact
We may update these terms as the product changes. The hosted copy linked from Account is the public version. Continued use after an update means you accept the revised terms.''';
