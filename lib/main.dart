// tracker 13 from Tommy's firebase Login complete code.
// just one mod to put MaterialApp at top of tree so that Navigator code worked.

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
  User? user;
  CollectionReference? locationsCollection;

  @override
  Widget build(BuildContext context) {
    //here "user" is an Instance of USER NOT current user as I thought
    // bad code  user should only be called once in initState()
    User? user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Auth User (Logged ' + (user == null ? 'out' : 'in') + ')'),
        ),
        body: Center(
          child: Column(
            children: [
              TextField(controller: emailController),
              TextField(controller: passwordController),
              TextField(controller: locationController),

              // Login  Sign Up Logout  Buttons in a Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
//== ChatGPT
                  ElevatedButton(
                    child: Text(
                        'Sign Up'), // demand Location input here & pass via Navigator
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                        // If authenticated then user != null,
                        // then create a location record in the locations collection
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('locations')
                              .doc()
                              .set({
                            "locationName": locationController.text,
                            "userEmail": emailController.text,
                          });
                        }
                        setState(() {});
                      } catch (e) {
                        // Handle any errors that occur during sign-up
                        print(e.toString());
                        // Show an alert or dialog to the user with the error message
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Oh! Oh! Error"),
                              content: Text(e.toString()),
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
                    },
                  ),

                  //==Chat
                  ElevatedButton(
                    child: Text('Login'),
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                        // print("${user?.email}");
                        //rayMod to navigate to data entry screen
                        if (user != null) {
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
                        }
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                                "Oh Oh .. no such user"), // translate for all languages
                            content: Text(e.toString()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("OK"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  ElevatedButton(
                      child: Text('Log Out'),
                      onPressed: () async {
                        if (user != null) {
                          // logout if user is not null (logedIn)
                          await FirebaseAuth.instance.signOut();
                          setState(() {});
                        }
                      }),
                ],
              ),

              // rayMod - new button to go to Chart screen - just convient for now .. rejig
              ElevatedButton(
                child: Text('Chart'),
                onPressed: () {
                  if (user != null) {
                    //rayMod to navigate to Chart screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TimeSeriesLineChart() // class name Not file name
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
    );
  }
}

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
