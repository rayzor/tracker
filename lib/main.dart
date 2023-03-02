// tracker17 from Tommy's firebase Login complete code.
// just one mod to Tommy to put MaterialApp at top of tree so that Navigator code worked.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tracker/line_chart.dart';

import 'data_entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    // Navigator needs Material App here high in the widget tree.
    const MaterialApp(
      home: AuthApp(),
    ),
  );
}

class AuthApp extends StatefulWidget {
  const AuthApp({Key? key}) : super(key: key);

  @override
  AuthAppState createState() => AuthAppState();
}

class AuthAppState extends State<AuthApp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final locationController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>(); // for validation Step 4
  String errorMessage = '';
  CollectionReference? locationsCollection;

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    print("IN BUILD ........ user is  $user");

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Auth User (Logged ' + (user == null ? 'out' : 'in') + ')'),
        ),
        body: Form(
          key: _key, // to tie key to the Form Step4 - Validation
          child: Center(
            child: Column(
              children: [
                TextFormField(controller: emailController, validator: validateEmail),
                TextFormField(
                    controller: passwordController, validator: validatePassword),
                TextField(controller: locationController),
                //==
                Center(
                  child: Text(errorMessage),
                ),
                //==

                // Login  Sign Up Logout  Buttons in a Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
//== ChatGPT
                    ElevatedButton(
                      child: Text(
                          'Sign Up'), // demand Location input here & pass via Navigator
                      onPressed: () async {
                        if (_key.currentState!.validate()) {
                          try {
                            UserCredential userCredential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                            // If authenticated then user != null,
                            // then create a location record in the locations collection

                            //before user not null test
                            print("BEFORE USER NOT NULL TEST user is $userCredential");

                            //chatGPT fix to ensure user is instanciated before test for null
                            final User? user = userCredential.user;

                            if (user != null) {
                              // after user not null test
                              print("AFTER USER NOT NULL TEST USER IS $user");
                              await FirebaseFirestore.instance
                                  .collection('locations')
                                  .doc()
                                  .set({
                                "locationName": locationController.text,
                                "userEmail": emailController.text,
                              });
                              // T13 Navigate to dataEntry Screen if Auth = true
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DataEntry(
                                    currentUserEmail:
                                        emailController.text, //pass email to next screen
                                  ),
                                ),
                              );
                            }
                            // setState(() {
                            //   print("got ${locationController.text}");
                            // });
                            errorMessage = '';
                            // } catch (e) {
                          } on FirebaseAuthException catch (error) {
                            // Handle any errors that occur during sign-up
                            errorMessage = error.message!;
                            print(errorMessage.toString());
                            // Show an alert or dialog to the user with the error message
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Oh! Oh! Error"),
                                  content: Text(errorMessage.toString()),
                                  actions: [
                                    TextButton(
                                      child: Text("OK"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                          setState(() {
                            print("WE GOT LOCATION  ${locationController.text}");
                          });
                        } // if validate
                      }, //onPressed
                    ),

                    //==Chat
                    ElevatedButton(
                      child: Text('Login'),
                      onPressed: () async {
                        if (_key.currentState!.validate()) {
                          try {
                            await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                            print("USER ON LOGIN is  $user ");
                            //rayMod to navigate to data entry screen
                            //  if (user != null) {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DataEntry(
                                  currentUserEmail:
                                      emailController.text, //pass email to next screen
                                ),
                              ),
                            );
                            setState(() {}); //end setState
                            //  }
                            // } catch (e) {
                            errorMessage = '';
                          } on FirebaseAuthException catch (error) {
                            errorMessage = error.message!;
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                    "Oh Oh .. no such user"), // translate for all languages
                                content: Text(errorMessage.toString()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("OK"),
                                  ),
                                ],
                              ),
                            );
                          }
                          setState(() {}); //end setState
                        }
                      },
                    ),
                    ElevatedButton(
                        child: Text('Log Out'),
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance.signOut();
                            errorMessage = '';
                          } on FirebaseAuthException catch (error) {
                            errorMessage = error.message!;
                          }
                          setState(() {
                            user = null;
                          });
                        }),
                  ],
                ),

                // rayMod - new button to go to Chart screen - just convient for now .. rejig
                ElevatedButton(
                  child: Text('Chart'),
                  onPressed: () {
                    // test if valid user to proceed
                    if (user != null) {
                      //rayMod to navigate to Chart screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TimeSeriesLineChart(
                                  currentUserEmail:
                                      emailController.text, //pass email to next scree
                                ) // class name Not file name
                            ),
                      );
                    }
                    ; // if test

                    setState(() {}); //end setState
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//== Validation Step4 video and code steps https://learnflutterwithme.com/firebase-auth-validation
String? validateEmail(String? formEmail) {
  if (formEmail == null || formEmail.isEmpty) return 'E-mail address is required.';

  String pattern = r'\w+@\w+\.\w+';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formEmail)) return 'Invalid E-mail Address format.';

  return null;
}
//==
//==

String? validatePassword(String? formPassword) {
  if (formPassword == null || formPassword.isEmpty) return 'Password is required.';

  String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formPassword))
    return '''
      Password must be at least 8 characters,
      include an uppercase letter, number and symbol.
      ''';

  return null;
}

//==

//Todo
// Notes Only - delete on final code before release
// User fields on Firebase...
/*
User(
displayName: ,
email: test0@test.com,
emailVerified: false,
isAnonymous: false,
metadata: UserMetadata(
creationTime: 2023-02-11 22:06:55.872Z,
lastSignInTime: 2023-02-11 22:06:55.872Z),
phoneNumber: ,
photoURL: null,
providerData, [
  UserInfo(
  displayName: ,
  email: test0@test.com,
phoneNumber: ,
photoURL: null,
providerId: password,
uid: test0@test.com)
],
refreshToken: ,
tenantId: null,
uid: 2VVnhCWTn9UH1EDViCxbR8F0wRd2)*/
