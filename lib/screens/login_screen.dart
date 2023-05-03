// login screen from Firebase_authentication on github
//
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tracker/screens/chart_screen.dart';

import '../helpers/auth_helpers.dart';
import '../helpers/validator_helpers.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    // if user returned from Firebase then Navigate to HomeScreen or Login or first page you want User to go to.
    /*  if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            user: user,
          ),
        ),
      );
    }*/

    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        body: FutureBuilder(
          future: _initializeFirebase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // Try1 ========= put the SingleChildScroll here and top Container

              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 250,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          //topLeft: Radius.circular(60),
                          //topRight: Radius.circular(60),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(300),
                        ),
                        //image: DecorationImage(
                        // image: NetworkImage(
                        //   'https://cdn.pixabay.com/photo/2015/03/30/12/37/jellyfish-698521__340.jpg'),
                        //fit: BoxFit.fill)
                        image: DecorationImage(
                          image: AssetImage('assets/images/jellyfish.jpg'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            left: 30,
                            width: 80,
                            height: 200,
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image:
                                      AssetImage('assets/images/flying-dandelions.png'),
                                ),
                              ),
                            ),
                          ),
                          /*                Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/flying-dandelions.png'),
                          ),
                        ),
                      ),
                    ),*/
                          Positioned(
                            right: 40,
                            top: 40,
                            width: 80,
                            height: 150,
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/dandelions.png'),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            child: Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: Center(
                                child: Text(
                                  "Single Use Plastics",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            child: Container(
                              margin: const EdgeInsets.only(top: 120),
                              child: Center(
                                child: Text(
                                  "Tracker",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //==================== Try 1 === looks OK so far

                    Padding(
                      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 48),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                // Try2 = ==== put White Container here to span the 2 fields
                                // This White Container seems to be for the 2 email and password fields surround White
                                Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Color.fromRGBO(143, 148, 251, .2),
                                            blurRadius: 20.0,
                                            offset: Offset(0, 10))
                                      ],
                                    ),
                                    child: Column(children: <Widget>[
                                      /// this is the first container for the Email
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[100]!))),

                                        //=== try2
                                        child: TextFormField(
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
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          controller: _passwordTextController,
                                          focusNode: _focusPassword,
                                          obscureText: true,
                                          validator: (value) =>
                                              Validator.validatePassword(
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
                                      ),

                                      //Mod1
                                      // put wid array end here and Col end for the 2 fileds
                                    ])),
                                // between Password and Login Button
                                SizedBox(height: 24.0),

                                // If still processing do Progress Indicator else open Row
                                _isProcessing
                                    ? CircularProgressIndicator()
                                    :
//ROW was here
                                    /// kill the ROW and just Login button
                                    /// AND SignUP lower down and send to SignUp screen
                                    /// with dropdown for selection of Community
                                    /// Glanmire, Watergrasshill, Knockraha, Glounthaune, Mayfield, Carrig MD

                                    Container(
                                        height: 50,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color.fromRGBO(143, 148, 251, 1),
                                              Color.fromRGBO(143, 148, 251, .6),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          //    child: Expanded(
                                          child: ElevatedButton(
                                            //ChatGPT solution
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              backgroundColor: Colors.transparent,
                                              elevation: 0,
                                              padding: EdgeInsets.zero,
                                            ),
                                            onPressed: () async {
                                              _focusEmail.unfocus();
                                              _focusPassword.unfocus();

                                              if (_formKey.currentState!.validate()) {
                                                setState(() {
                                                  _isProcessing = true;
                                                });

                                                User? user = await FirebaseAuthHelper
                                                    .signInUsingEmailPassword(
                                                  email: _emailTextController.text,
                                                  password: _passwordTextController.text,
                                                );

                                                setState(() {
                                                  _isProcessing = false;
                                                });

                                                if (user != null) {
                                                  Navigator.of(context).pushReplacement(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            //    HomeScreen(user: user),
                                                            ChartScreen(
                                                                currentUserEmail: user
                                                                    .email
                                                                    .toString())),
                                                  );
                                                }
                                              }
                                            },
                                            child: Text(
                                              'Login',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24),
                                            ),
                                          ),
                                          //   style: ButtonStyle(
                                          //     backgroundColor:
                                          //         MaterialStateProperty.all(
                                          //             Colors.deepOrangeAccent),
                                          // ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  } //Widget build
} //Class end
