class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Name is required';
    if (v.length < 2) return 'Name is too short';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (value) {
      if ((value ?? '').isEmpty) return 'Please confirm your password';
      if (value != original()) return 'Passwords do not match';
      return null;
    };
  }

  static String? cardNumber(String? value) {
    final digits = (value ?? '').replaceAll(' ', '');
    if (digits.length != 16 || int.tryParse(digits) == null) {
      return 'Enter a 16-digit card number';
    }
    return null;
  }

  static String? expiry(String? value) {
    final v = value ?? '';
    final ok = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(v);
    return ok ? null : 'Use MM/YY';
  }

  static String? cvv(String? value) {
    final v = value ?? '';
    return (v.length == 3 || v.length == 4) && int.tryParse(v) != null
        ? null
        : 'Invalid CVV';
  }
}
