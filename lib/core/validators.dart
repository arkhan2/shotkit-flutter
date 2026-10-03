const projectNameMax = 80;
const designNameMax = 80;
const brandKitNameMax = 80;

String? validateProjectName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'Give the project a name.';
  if (trimmed.length > projectNameMax) {
    return 'Keep the name under $projectNameMax characters.';
  }
  return null;
}

String? validateDesignName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'Give the design a name.';
  if (trimmed.length > designNameMax) {
    return 'Keep the name under $designNameMax characters.';
  }
  return null;
}

String? validateBrandKitName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'Give the Brand Kit a name.';
  if (trimmed.length > brandKitNameMax) {
    return 'Keep the name under $brandKitNameMax characters.';
  }
  return null;
}

String? validateEmail(String email) {
  final trimmed = email.trim();
  if (trimmed.isEmpty) return 'Enter your email.';
  if (!trimmed.contains('@') || !trimmed.contains('.')) {
    return 'Enter a valid email.';
  }
  return null;
}

String? validatePassword(String password) {
  if (password.isEmpty) return 'Enter your password.';
  return null;
}
