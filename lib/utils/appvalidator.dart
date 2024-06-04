class AppValidator {
  // Validate username
  String? validateUserName(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a username";
    }
    return null;
  }

  // Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter an email";
    }

    // Regular expression pattern for validating email addresses
    RegExp emailRegExp = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
      multiLine: false,
    );

    if (!emailRegExp.hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
  }

  // Number phone verification
  String? validatePhoneNumber(String? value) {
    if (value!.isEmpty) {
      return "Please enter a phone number";
    }
    if (value.length != 10) {
      return "Please enter a 10-digit phone number";
    }

    return null;
  }

  // Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a password";
    }
    return null;
  }

  // Validate reconfirm password
  String? validateReconfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please reconfirm password";
    }
    return null;
  }

  // Validate checkbox empty
  String? isEmptyCheck(value) {
    if (value!.isEmpty) {
      return "Please fill details";
    }
    return null;
  }

  // Validate category selection
  String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return "Please select a category";
    }
    return null;
  }
}
