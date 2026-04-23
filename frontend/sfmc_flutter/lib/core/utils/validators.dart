class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'L\'email est requis';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) return 'Email invalide';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Le mot de passe est requis';
    if (value.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName est requis';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return null;
    final phoneRegex = RegExp(r'^\+?[0-9\s-]{8,}$');
    if (!phoneRegex.hasMatch(value)) return 'Numéro invalide';
    return null;
  }

  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName est requis';
    final number = double.tryParse(value);
    if (number == null) return 'Doit être un nombre';
    if (number <= 0) return 'Doit être positif';
    return null;
  }
}
