// Tommy's firebase Login complete code.
// just one mod to put MaterialApp at top of tree so thay Navigator code worked.
// solution from Stackoverflow

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tracker/line_chart.dart';

import 'data_entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      // Navigator needs Material App here high in the widget tree.
      home: AuthApp(),
    ),
  );
}

class AuthApp extends StatefulWidget {
  const AuthApp({Key? key}) : super(key: key);

  @override
  _AuthAppState createState() => _AuthAppState();
}

class _AuthAppState extends State<AuthApp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  // User? user;

  @override
  Widget build(BuildContext context) {
    //here user is an Instance of USER NOT current user as I thought
    // bad code  user should only be called once in initState()
    User? user = FirebaseAuth.instance.currentUser;

    // ToDo Delete on final ...tests only
    String? currentUserEmail = user?.email; // too early must be after await
    print("In Main Build  ${user?.email} "); // print the field email from User Instance
    //  print("In Main Build  ${currentUserEmail} ");
    // print("In Main Build  ${user}"); // print full firebase Instance of User ...

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

              // Login  Sign Up Logout  Buttones in a Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      child: Text(
                          'Sign Up'), // demand Location choice here & pass via Navigator
                      onPressed: () async {
                        await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                        setState(() {});
                      }),
                  ElevatedButton(
                      child: Text('Login'),
                      onPressed: () async {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );

                        //rayMod to navigate to data entry screen
                        if (user != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DataEntry(
                                currentUserEmail: emailController.text, //pass email
                              ),
                            ),
                          );
                          setState(() {
                            print("In Navigator to pass var + ${emailController.text}");
                          }); //end setState
                        }
                      }),
                  ElevatedButton(
                      child: Text('Log Out'),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        setState(() {});
                      }),
                ],
              ),

              // rayMod - new button to go to Chart screen
              ElevatedButton(
                  child: Text('Chart'),
                  onPressed: () {
                    //rayMod to navigate to Chart screen

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TimeSeriesLineChart() // DataEntry(),
                          ),
                    );

/*                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DataEntry(), //LineChart(),
                      ),
                    );*/
                    setState(() {
                      //    print("In Navigator to pass var + ${emailController.text}");
                    }); //end setState
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
// User fields...
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
