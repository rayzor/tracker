// I asked ChatGPT to improve my code. It did a good job. user called only once in init

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'data_entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      home: AuthApp(),
    ),
  );
}

class AuthApp extends StatefulWidget {
  @override
  _AuthAppState createState() => _AuthAppState();
}

class _AuthAppState extends State<AuthApp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  User? user;

  @override
  void initState() {
    super.initState();
    _getCurrentUser(); // get user initially will be null because not logged in
  }

  void _getCurrentUser() async {
    user = await FirebaseAuth.instance.currentUser;
    //String? firebaseUserEmail = user?.email;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      child: Text('Sign Up'),
                      onPressed: () async {
                        await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                        _getCurrentUser(); // get user after Login
                      }),
                  ElevatedButton(
                      child: Text('Login'),
                      onPressed: () async {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );

                        if (user != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DataEntry(
                                currentUserEmail: emailController.text,
                              ),
                            ),
                          );
                        }
                      }),
                  ElevatedButton(
                      child: Text('Log Out'),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        _getCurrentUser();
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Some of the changes I made include:
//
// Moving the retrieval of the current user to the initState method, which ensures that the user is fetched only once when the widget is first created.
// Using the await keyword when retrieving the current user to make sure that the value is assigned before the build method is called.
// Adding a separate method
