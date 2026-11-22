class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? required(String? v, {String label = 'This field'}) =>
    (v == null || v.trim().isEmpty) ? '$label is required' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!_email.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Min. 6 characters';
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return 'Confirm your password';
    if (v != original) return 'Passwords do not match';
    return null;
  }

  static String? positiveNumber(String? v, {String label = 'Value'}) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    final n = double.tryParse(v.trim());
    if (n == null || n <= 0) return 'Enter a positive number';
    return null;
  }

  static String? positiveInt(String? v, {String label = 'Value'}) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    final n = int.tryParse(v.trim());
    if (n == null || n <= 0) return 'Enter a whole positive number';
    return null;
  }
}
