// tracker Flutter app - Glanmire Coder Dojo
// SignUp code:
// to register new Users
// to save a "dummy record" in the entries file to have the location and email registeed here also for logins.
// name in Signup is not accessible ...wierd from Firebase.??
// also record a first entry in entries collection with
// email, locationID = location selected from dropdown.
// enter 0 Zero for quantity. This record is just to have a ref for email to location used on logins

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tracker/helpers/auth_helpers.dart';
import 'package:tracker/helpers/validator_helpers.dart';

import 'home_screen.dart';

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

  // List called locations To hold Location Names retrieved from firebase locations collection
//  List<String> locations = [];
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    // get location from Firebase collection locations - restricted to 10 for pilot. Admin controlled on firebase
    // _loadLocations();
    // getLocations();
  }

  void _loadLocations() async {
    List<String> locations = await getLocations();
    setState(() {
      locations = locations;
    });
  }
  //ChatGPT Notes:
  // In the getLocations() method, you retrieve the documents from the "locations" collection using the get() method.
  // Then, you use the map() method to extract the "name" field from each document and add it to the locations list.
  //
  // In the build() method, you create the DropdownButtonFormField widget
  // and populate it with the items from the locations list using the map() method.
  // The selected location is stored in the _selectedLocation variable.

  //ChatGPT code
  Future<List<String>> getLocations() async {
    final CollectionReference locationsRef =
        FirebaseFirestore.instance.collection('locations');

    //final QuerySnapshot querySnapshot = await locationsRef.get();
    final QuerySnapshot querySnapshot = await locationsRef.orderBy('locationName').get();
    final List<String> locations = [];

    querySnapshot.docs.forEach((doc) {
      final String locationName = doc.get('locationName');
      print("In getLocations $locationName");
      locations.add(locationName);
    });
    return locations;
    // return locations.toList();
  }

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
          backgroundColor: Colors.lightBlue,
          title: Text('Join In - Signup'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
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
                        // Try 7 future builder to wait for locations list
/*

                        FutureBuilder<List<String>>(
                          future: getLocations(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final List<String> locations = snapshot.data!;
*/

                        //=========== try5  Dropdown menu

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
                            hintText: "Select Location",
                            errorBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: BorderSide(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
//==== try 7 future
                        /*                         } else if (snapshot.hasError) {
                              return Text('Error loading locations');
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        ),
*/
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
                                  ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        _isProcessing = true;
                                      });

                                      if (_registerFormKey.currentState!.validate()) {
                                        // your code here

                                        User? user = await FirebaseAuthHelper
                                            .registerUsingEmailPassword(
                                          //   name: _nameTextController.text,
                                          // use the name required by yhe built in validation in Firebase
                                          // Error :Cant use name field in User collection to save location names.
                                          // Make a new collection called locations.
                                          /// to record the user location on Signup
                                          ///
                                          /// displayName: The display name for the user, which can be set using the name
                                          /// we can use this to save the locationName for use in subsequent Logins
                                          name: _selectedLocation
                                              .toString(), //  access later in Auth User collection?
                                          email: _emailTextController.text,
                                          password: _passwordTextController.text,
                                        );

                                        setState(() {
                                          _isProcessing = false;
                                        });

                                        if (user != null) {
                                          print(
                                              "In SU Nav to Chart ${user.email} , ${user.displayName}");
                                          Navigator.of(context).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  //    HomeScreen() // after Signup Register goto Home screen with menu
                                                  HomeScreen(user: user),
                                              //  ChartScreen(user: user),
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
                                      backgroundColor:
                                          MaterialStateProperty.all(Colors.lightBlue),
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
      ),
    );
  }
}
