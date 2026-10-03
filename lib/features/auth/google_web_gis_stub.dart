import 'package:flutter/widgets.dart';

class GoogleWebGisButton extends StatelessWidget {
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
  Widget build(BuildContext context) => const SizedBox.shrink();
}
