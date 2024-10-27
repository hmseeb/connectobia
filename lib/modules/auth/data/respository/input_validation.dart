/// This class contains methods for validating user input
/// in the authentication process.
///
/// {@category Repositories}
class InputValidation {
  static String? validateBrandForm({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String website,
    required String industry,
  }) {
    String? error;
    error = validateFirstName(firstName);
    if (error != null) {
      return error;
    }
    error = validateLastName(lastName);
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
    error = validateWebsite(website);
    if (error != null) {
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
    String pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(email)) {
      return 'Invalid email format';
    }
    return null;
  }

  // First name shouldn't be less than 2 characters
  static String? validateFirstName(String? firstName) {
    if (firstName == null || firstName.isEmpty) {
      return 'First name is required';
    }
    if (firstName.length < 2) {
      return 'First name must be at least 2 characters';
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
    required String email,
    required String password,
    required String industry,
  }) {
    String? error;
    error = validateFirstName(firstName);
    if (error != null) {
      return error;
    }
    error = validateLastName(lastName);
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

  // Last name shouldn't be less than 2 characters
  static String? validateLastName(String? lastName) {
    if (lastName == null || lastName.isEmpty) {
      return 'Last name is required';
    }
    if (lastName.length < 2) {
      return 'Last name must be at least 2 characters';
    }
    return null;
  }

  static List<String> validatePassword(String? password) {
    List<String> errors = [];

    if (password == null || password.isEmpty) {
      errors.add('Password is required');
    } else {
      if (password.length < 8) {
        errors.add('Password must be at least 8 characters');
      }
      if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
        errors.add('Password must contain at least one uppercase letter');
      }
      if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
        errors.add('Password must contain at least one lowercase letter');
      }
      if (!RegExp(r'(?=.*\d)').hasMatch(password)) {
        errors.add('Password must contain at least one number');
      }
      if (!RegExp(r'(?=.*[@$!%*?&#])').hasMatch(password)) {
        errors.add('Password must contain at least one special character');
      }
    }

    return errors;
  }

  static String? validateWebsite(String? website) {
    if (website == null || website.isEmpty) {
      return null;
    }
    // Regular expression for a valid website address pattern
    String pattern =
        r"^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$";
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(website)) {
      return 'Invalid website format';
    }
    return null;
  }
}
