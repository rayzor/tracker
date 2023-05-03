// validation helpers.
// this file contains helper methods which are called from the main screens
// it is convenient to separate these methods into separate files to reduce the clutter in the main screens
// these helper methods are used to validate name, email, password
// Also to limit the quantity entered by the user. It is set at 50 bottles of plastic ToDo put in Params file

import 'package:flutter/services.dart';

class Validator {
// Email validation pattern helper method
// Validation Step4 video and code steps https://learnflutterwithme.com/firebase-auth-validation
  //static String? validateEmail({required String? email}) {
  static String? validateEmail({String? email}) {
    //null test is used to detect the absence of a value, while empty is used to check for an empty collection.
    if (email == null || email.isEmpty) return 'E-mail address is required.';

    String pattern = r'\w+@\w+\.\w+';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(email)) return 'Invalid E-mail address format.';

    return null;
  }

// Password Validation pattern helper method:
  static String? validatePassword({String? password}) {
    //null test is used to detect the absence of a value, while empty is used to check for an empty collection.
    if (password == null || password.isEmpty) return 'Password is required.';

    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';

    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(password)) {
      return '''
      Password must be at least 8 characters,
      include an uppercase letter, number and symbol.
      ''';
    }

    return null;
  }
} // END VALIDATOR

// Data Entry formatter helper method : allows numbers only
// Chat GPT suggestion - good code. prevents text entry OR edit - numbers only allowed.
class IntegerInputFormatter extends TextInputFormatter {
  // ToDo Data Entry limit of 50 items of SUPs ToDo extract to Parameter file
  num get quantityLimit => 50;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Regular expression that matches only digits
    final RegExp digitRegex = RegExp(r'\d+');

    // The ?? is the null coalescing operator.
    // It is used to provide a default value when a variable is null.
    String newString =
        digitRegex.stringMatch(newValue.text) ?? ''; //if null assign '' //empty string

    // ToDo Limit the input quantity to 50 to stop extreme data entries
    if (newString.isNotEmpty && int.parse(newString) > quantityLimit) {
      newString = quantityLimit.toString();
    }

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

//================ Todo duplicate methods delete on final

/*
// Validator Class:
class Validator {
  static String? validateName({required String? name}) {
    if (name == null) {
      return null;
    }
    if (name.isEmpty) {
      return 'Name can\'t be empty'; // translate
    }
    return null;
  }

  static String? validateEmail({required String? email}) {
    if (email == null) {
      return null;
    }
// Regular Expression is used to test if the format complies with standard email formats text@text.com
    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    if (email.isEmpty) {
      return 'Email can\'t be empty';
    } else if (!emailRegExp.hasMatch(email)) {
      return 'Enter a correct email';
    }
    return null;
  }

  static String? validatePassword({required String? password}) {
    if (password == null) {
      return null;
    }
// test if the password is empty or less than 6 characters.
    if (password.isEmpty) {
      return 'Password can\'t be empty';
    } else if (password.length < 8) {
      return 'Enter a password with length at least 8';
    }
    return null;
  }
}
*/
