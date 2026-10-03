import 'dart:convert';
import 'dart:math';
import 'dart:ui_web' as ui_web;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:google_identity_services_web/id.dart' as gis;
import 'package:google_identity_services_web/loader.dart';
import 'package:web/web.dart' as web;

class GoogleWebGisButton extends StatefulWidget {
  const GoogleWebGisButton({
    super.key,
    required this.clientId,
    required this.onCredential,
    required this.onError,
  });

  final String clientId;
  final void Function(String idToken, String nonce) onCredential;
  final ValueChanged<String> onError;

  @override
  State<GoogleWebGisButton> createState() => _GoogleWebGisButtonState();
}

class _GoogleWebGisButtonState extends State<GoogleWebGisButton> {
  late final String _viewType;
  late final String _rawNonceValue;
  late final String _hashedNonce;
  var _ready = false;

  @override
  void initState() {
    super.initState();
    _rawNonceValue = _rawNonce();
    _hashedNonce = sha256.convert(utf8.encode(_rawNonceValue)).toString();
    _viewType = 'shotkit-gis-${identityHashCode(this)}';
    _boot();
  }

  Future<void> _boot() async {
    try {
      await loadWebSdk();
      if (!mounted) return;
      final host = web.HTMLDivElement()
        ..style.width = '100%'
        ..style.display = 'flex'
        ..style.justifyContent = 'center';

      gis.id.initialize(
        gis.IdConfiguration(
          client_id: widget.clientId,
          callback: (response) {
            final token = response.credential;
            if (token == null || token.isEmpty) {
              widget.onError(response.error ?? 'Google did not return an ID token.');
              return;
            }
            widget.onCredential(token, _rawNonceValue);
          },
          nonce: _hashedNonce,
          ux_mode: gis.UxMode.popup,
          use_fedcm_for_prompt: false,
          auto_select: false,
          cancel_on_tap_outside: true,
        ),
      );
      gis.id.renderButton(
        host,
        gis.GsiButtonConfiguration(
          type: gis.ButtonType.standard,
          theme: gis.ButtonTheme.outline,
          size: gis.ButtonSize.large,
          text: gis.ButtonText.continue_with,
          shape: gis.ButtonShape.rectangular,
        ),
      );
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (_) => host);
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      widget.onError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox(
        height: 44,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return SizedBox(
      height: 44,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}

String _rawNonce([int length = 32]) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._';
  final random = Random.secure();
  return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
}
