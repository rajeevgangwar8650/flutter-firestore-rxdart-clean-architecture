class Validators {
  static bool isValidEmail(String email) {
    return RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+").hasMatch(email);
  }

  static String? requiredText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

  static String? todoTitle(String? value) {
    final requiredMessage = requiredText(value, 'Title');
    if (requiredMessage != null) {
      return requiredMessage;
    }

    if (value!.trim().length < 3) {
      return 'Title must be at least 3 characters.';
    }

    if (value.trim().length > 80) {
      return 'Title must be 80 characters or less.';
    }

    return null;
  }

  static String? todoDescription(String? value) {
    if (value != null && value.trim().length > 500) {
      return 'Description must be 500 characters or less.';
    }

    return null;
  }
}
