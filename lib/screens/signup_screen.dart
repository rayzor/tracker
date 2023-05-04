// tracker Flutter app - Glanmire Coder Dojo
// register the signup the new User.
// also record a first entry in entries collection with
// email, locationID = location selected from dropdown.

import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tracker/helpers/auth_helpers.dart';
import 'package:tracker/helpers/validator_helpers.dart';

import 'chart_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _registerFormKey = GlobalKey<FormState>();

  //final _locationTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  //final _focusLocation = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;

  //ChatGPT code for DropDown in the Form widget.
  List<String> locations = [
    'Glanmire',
    'Watergrasshill',
    'Knockraha',
    'Glounthaune',
    'Mayfield',
    'Carrigtwohill',
    'Midleton',
    'Location 8',
    'Location 9',
    'Location 10'
  ];

  String? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //_focusLocation.unfocus();
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrangeAccent,
          title: Text('Join In - Signup'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _registerFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //=========== try5  Dropdown menu
                      //   List<String> locations = ['Location 1', 'Location 2', 'Location 3', 'Location 4', 'Location 5', 'Location 6', 'Location 7', 'Location 8', 'Location 9', 'Location 10'];

                      //    String? _selectedLocation;

                      DropdownButtonFormField(
                        value: _selectedLocation,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedLocation = newValue.toString();
                          });
                        },
                        items: locations.map((location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          hintText: "Location",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),

                      //==== try5  ================

                      // omit name field
                      /*
                      TextFormField(
                        controller: _locationTextController,
                        focusNode: _focusLocation,
                        validator: (value) => Validator.validateName(
                          name: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Name",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
    //======== omit name field
                      */

                      SizedBox(height: 12.0),
                      TextFormField(
                        controller: _emailTextController,
                        focusNode: _focusEmail,
                        validator: (value) => Validator.validateEmail(
                          email: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Email",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      TextFormField(
                        controller: _passwordTextController,
                        focusNode: _focusPassword,
                        obscureText: true,
                        validator: (value) => Validator.validatePassword(
                          password: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Password",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32.0),
                      _isProcessing
                          ? CircularProgressIndicator()
                          : Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        _isProcessing = true;
                                      });

                                      if (_registerFormKey.currentState!.validate()) {
                                        User? user = await FirebaseAuthHelper
                                            .registerUsingEmailPassword(
                                          //   name: _nameTextController.text,
                                          // use the name required by yhe built in validation in Firebase
                                          /// to record the user location on Signup
                                          name: _selectedLocation.toString(),
                                          email: _emailTextController.text,
                                          password: _passwordTextController.text,
                                        );

                                        setState(() {
                                          _isProcessing = false;
                                        });

                                        if (user != null) {
                                          Navigator.of(context).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  //    HomeScreen(user: user),
                                                  ChartScreen(user: user),
                                              //    ChartScreen(
                                              //        currentUserEmail:
                                              //            user.email.toString()),
                                            ),
                                            ModalRoute.withName('/'),
                                          );
                                        }
                                      } else {
                                        setState(() {
                                          _isProcessing = false;
                                        });
                                      }
                                    },
                                    child: Text(
                                      'Sign up',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(
                                          Colors.deepOrangeAccent),
                                    ),
                                  ),
                                ),
                              ],
                            )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
