/// This class contains methods for validating user input
/// in the authentication process.
///
/// {@category Repositories}
class InputValidation {
  static String? validateBrandForm({
    required String brandName,
    required String email,
    required String password,
    required String industry,
  }) {
    String? error;
    error = validateBrandName(brandName);
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

  static String? validateBrandName(String? brandName) {
    if (brandName == null || brandName.isEmpty) {
      return 'Name is required';
    }

    if (brandName.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    // Regular expression for a valid email address pattern
    String pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
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
    error = validateBrandName(firstName);
    if (error != null) {
      return error;
    }

    error = validateUsername(username);
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

      // Check for at least one uppercase letter
      if (!RegExp(r'[A-Z]').hasMatch(password)) {
        errors.add('Password must contain at least one uppercase letter');
      }

      // Check for at least one lowercase letter
      if (!RegExp(r'[a-z]').hasMatch(password)) {
        errors.add('Password must contain at least one lowercase letter');
      }

      // Check for at least one number
      if (!RegExp(r'\d').hasMatch(password)) {
        errors.add('Password must contain at least one number');
      }

      // Check for at least one special character
      if (!RegExp(r'[@$!%*?&#]').hasMatch(password)) {
        errors.add('Password must contain at least one special character');
      }
    }

    return errors;
  }

  static String? validateUsername(String? username) {
    // Check if username length is between 8 and 20 characters

    if (username == null || username.isEmpty) {
      return "Username is required.";
    }

    final lengthRegex = RegExp(r"^.{3,20}$");
    if (!lengthRegex.hasMatch(username)) {
      return "Username must be between 3 and 20 characters.";
    }

    // Check if username starts with _ or .
    final startRegex = RegExp(r"^[_.]");
    if (startRegex.hasMatch(username)) {
      return "Username cannot start with '_' or '.'.";
    }

    // Check if username ends with _ or .
    final endRegex = RegExp(r"[_.]$");
    if (endRegex.hasMatch(username)) {
      return "Username cannot end with '_' or '.'.";
    }

    // Check if username contains consecutive __, .., _. or ._
    final consecutiveRegex = RegExp(r".*[_.]{2,}.*");
    if (consecutiveRegex.hasMatch(username)) {
      return "Username cannot contain '__', '_.', '._', or '..'.";
    }

    // Check if username contains only allowed characters (letters, digits, _, .)
    final validCharsRegex = RegExp(r"^[a-zA-Z0-9._]+$");
    if (!validCharsRegex.hasMatch(username)) {
      return "Username can only contain letters, digits, '_', or '.'.";
    }

    // If all checks pass, return null (valid username)
    return null;
  }
}
