// Tommy's Tutorial for signup/login to Firebase
// validation part.
// https://learnflutterwithme.com/firebase-auth-validation

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(AuthApp());
}

class AuthApp extends StatefulWidget {
  const AuthApp({Key? key}) : super(key: key);

  @override
  _AuthAppState createState() => _AuthAppState();
}

class _AuthAppState extends State<AuthApp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  // validate step 1
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  String errorMessage = ''; // not used yet

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Auth User (Logged ' + (user == null ? 'out' : 'in') + ')'),
        ),
        // validate step 2 change to a Form. Wrap with Form widget
        body: Form(
          key: _key, // and add the form key
          child: Center(
            ///      body:  Center(
            child: Column(
              children: [
                //validate step 4 . change fields to Form Fields
                //TextFormField(controller: emailController),
                //  TextFormField(controller: passwordController),

                // validate step 7 add validators to the TextFormFields
                TextFormField(controller: emailController, validator: validateEmail),
                TextFormField(
                    controller: passwordController, validator: validatePassword),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(errorMessage, style: TextStyle(color: Colors.red)),
                  ),
                ),
                //  TextField(controller: emailController),
                // TextField(controller: passwordController),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        child: Text('Sign Up'),
                        onPressed: () async {
                          // validate step 5 . test if the form is validated
                          if (_key.currentState!.validate()) {
                            await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                            setState(() {});
                          } // validate step 5 rem out for if key test
                        }),
                    ElevatedButton(
                        child: Text('Sign In'),
                        onPressed: () async {
                          await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                          setState(() {});
                        }),
                    ElevatedButton(
                        child: Text('Log Out'),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          setState(() {});
                        }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// validate step 3 . create a method to check if email is valid
// remember the ? is to indicate we will accept a null returned from this method.

// this method tests if the email is valid
String? validateEmail(String? formEmail) {
  if (formEmail == null || formEmail.isEmpty) return 'E-mail address is required.';

  // validate step 7 // make email comply with our format. use a Regex
  String pattern = r'\w+@\w+\.\w+';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formEmail)) return 'Invalid E-mail Address format.';

  return null;
}

// validate step 6 // same for password . Validate it is to our specification
String? validatePassword(String? formPassword) {
  if (formPassword == null || formPassword.isEmpty) return 'Password is required.';

  //validate step 8 : same for password

  String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formPassword))
    return '''
      Password must be at least 8 characters,
      include an uppercase letter, number and symbol.
      ''';

  return null;
}
