import 'package:flutter/material.dart';

/// Product naming and palette — keep centralized so renaming stays easy.
class AppBrand {
  static const name = 'ShotKit';
  static const tagline = 'App Store screenshot studio';
  static const description =
      'Create professional App Store and Google Play submission screenshots — fast, opinionated, and built for developers and designers.';

  static const sky = Color(0xFF38BDF8);
  static const ink = Color(0xFF141414);
  static const slate = Color(0xFF5A7388);
  static const deep = Color(0xFF0B1520);
  static const mist = Color(0xFFF4F7FA);
  static const mistDeep = Color(0xFFE8EEF4);

  static const logoMarkAsset = 'assets/brand/logo-mark.svg';
  static const appIconAsset = 'assets/brand/app-icon.svg';

  static const authRedirect = 'io.shotkit.app://login-callback';

  /// Same geometry as ShotKit web `SHOTKIT_LOGO_MARK` (viewBox 64×64).
  static const markViewBox = 64.0;
  static const markStrokeWidth = 1.25;
  static const markBack = Rect.fromLTWH(8.75, 10.75, 30.5, 42.5);
  static const markFront = Rect.fromLTWH(24.75, 10.75, 30.5, 42.5);
  static const markRadius = 8.25;
}
