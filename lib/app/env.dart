import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  const AppEnv({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.webAppUrl,
    required this.googleWebClientId,
    required this.googleIosClientId,
  });

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String webAppUrl;
  final String googleWebClientId;
  final String googleIosClientId;

  bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  bool get hasGoogle => googleWebClientId.isNotEmpty;

  String get billingUrl {
    final base = webAppUrl.replaceAll(RegExp(r'/$'), '');
    return '$base/app/billing';
  }

  static Future<AppEnv> load() async {
    try {
      await dotenv.load(fileName: 'assets/config/app.env');
    } catch (_) {
      // Optional local file — dart-define still works.
    }

    String read(String key) {
      const defines = {
        'SUPABASE_URL': String.fromEnvironment('SUPABASE_URL'),
        'SUPABASE_ANON_KEY': String.fromEnvironment('SUPABASE_ANON_KEY'),
        'SHOTKIT_WEB_URL': String.fromEnvironment('SHOTKIT_WEB_URL'),
        'GOOGLE_WEB_CLIENT_ID': String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
        'GOOGLE_IOS_CLIENT_ID': String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
      };
      final fromDefine = defines[key] ?? '';
      if (fromDefine.isNotEmpty) return fromDefine;
      return dotenv.maybeGet(key)?.trim() ?? '';
    }

    return AppEnv(
      supabaseUrl: read('SUPABASE_URL'),
      supabaseAnonKey: read('SUPABASE_ANON_KEY'),
      webAppUrl: read('SHOTKIT_WEB_URL').isEmpty
          ? 'http://127.0.0.1:3000'
          : read('SHOTKIT_WEB_URL'),
      googleWebClientId: read('GOOGLE_WEB_CLIENT_ID'),
      googleIosClientId: read('GOOGLE_IOS_CLIENT_ID'),
    );
  }
}
