// tracker: main.dart : Glanmire Coder Dojo Club - Apr 2023.
//
// A Flutter app to report trends in Single Use Plastics usage in Communities.
// This App is opensource code and can be used by any communities to track their SUP usage.
// They can download this app code from Github and setup a Firebase database for their Community or Communities.
// In Firebase enter the Community names which can participate in the 'locations' collection in a document (field) called locationName.
// In Firebase enter the weekly quantities in collection "entries" with the following document(fields)
// locationID (String), logDate(TimeDate), quantity(number) userID(String), weekNumber(number), yearNumber(number)
// RN/DM

// main.dart
//
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tracker/screens/home_screen.dart';

import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // todo test only remove later
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  //routes
  final routes = <String, WidgetBuilder>{
    '/home': (BuildContext context) {
      final user = FirebaseAuth
          .instance.currentUser!; // ! indicates we are certain user is not null???
      return HomeScreen(user: user);
    },
    // '/chart': (BuildContext context) => ChartScreen( user: null,  ),
    //  '/data_entry': (BuildContext context) => DataEntryScreen(),
    // '/info': (BuildContext context) => InfoScreen(),
    '/login': (BuildContext context) => LoginScreen(),
  };
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Single Use Plastics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(
              fontSize: 24.0,
            ),
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          ),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 46.0,
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: const TextStyle(fontSize: 18.0),
        ),
      ),
      home: LoginScreen(), // start at Login Screen

      //routes
      initialRoute: '/login',
      routes: routes,
    );
  }
}
