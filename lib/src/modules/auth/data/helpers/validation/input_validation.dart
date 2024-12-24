/// This class contains methods for validating user input
/// {@category Repositories}
///
/// in the authentication process.
class InputValidation {
  static String? validateBrandForm({
    required String brandName,
    required String email,
    required String password,
    required String industry,
  }) {
    String? error;
    error = validateName(brandName);

    if (error != null) {
      return error;
    }
    error = validateEmail(email);
    if (error != null) {
      return error;
    }
    error = validatePassword(password).join('\n');
    if (error.isNotEmpty) {
      return error;
    }

    error = validateIndustry(industry);
    if (error != null) {
      return error;
    }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    // Regular expression for a valid email address pattern
    String pattern = r"^[a-zA-Z0-9._+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(email)) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? validateIndustry(String? industry) {
    if (industry == null || industry.isEmpty) {
      return 'Industry is required';
    }
    return null;
  }

  static String? validateInfluencerForm({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String industry,
  }) {
    String? error;
    error = validateName(firstName);
    if (error != null) {
      return error;
    }

    error = validateEmail(email);
    if (error != null) {
      return error;
    }
    error = validatePassword(password).join('\n');
    if (error.isNotEmpty) {
      return error;
    }
    error = validateIndustry(industry);
    if (error != null) {
      return error;
    }

    return null;
  }

  static String? validateName(String? brandName) {
    if (brandName == null || brandName.isEmpty) {
      return 'Name is required';
    }

    if (brandName.length >= 40) {
      return 'Name cannot exceed 40 characters';
    }
    return null;
  }

  static List<String> validatePassword(String? password) {
    List<String> errors = [];

    // Check if password is null or empty
    if (password == null || password.isEmpty) {
      errors.add('Password is required');
    } else {
      // Check password length
      if (password.length < 8) {
        errors.add('Password must be at least 8 characters');
      }
      if (password.length >= 71) {
        errors.add('Password cannot exceed 71 characters');
      }

      // Check for at least one special character
      if (!RegExp(r'[!"#$%&()*+,-./:;<=>?@[\]^_`{|}~]').hasMatch(password)) {
        errors.add('Password must contain at least one special character');
      }
    }

    return errors;
  }
}
