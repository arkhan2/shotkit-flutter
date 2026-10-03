import 'package:flutter/material.dart';

final _hex6 = RegExp(r'^#?[0-9a-fA-F]{6}$');
final _hex8 = RegExp(r'^#?[0-9a-fA-F]{8}$');

String normalizeHex(String input) {
  var value = input.trim();
  if (!value.startsWith('#')) value = '#$value';
  return value.toUpperCase();
}

bool isValidHex(String input) {
  final value = input.trim();
  return _hex6.hasMatch(value) || _hex8.hasMatch(value);
}

Color parseHexColor(String input, {Color fallback = const Color(0xFF0F172A)}) {
  try {
    var hex = input.trim();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    if (hex.length == 8) {
      final aa = hex.substring(6);
      final rgb = hex.substring(0, 6);
      return Color(int.parse('$aa$rgb', radix: 16));
    }
  } catch (_) {}
  return fallback;
}
