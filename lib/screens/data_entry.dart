// tracker : List View : Show user list And Location list for this user.

// Note: ? means it is OK to be null but caution as it could crash your code
// Note: ! is the "assert symbol" saying I guarantee not null

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; //for all screen widgets, scaffold appbar etc
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // for DateFormats

class DataEntry extends StatefulWidget {
  final User user;

  const DataEntry({Key? key, required this.user}) : super(key: key);

  @override
  DataEntryState createState() => DataEntryState();
}

class DataEntryState extends State<DataEntry> {
  //final quantity = TextEditingController(); // used to input data .. number of plastic items
  // ToDo rayDevOnly final String location = "Glanmire"; // pick up the user location later from dropdown
  final DateTime today = DateTime.now();
  final dateFormatted = DateFormat.yMd().format(DateTime.now());
// Todo ... decide final Date format style EU or US od location based.
  final myDateFormat = DateFormat('dd-MM-yyyy'); // Irish / British date format
  //String locationName = "";

  //== Chat
  @override
  void initState() {
    super.initState();
  }

  // Build the Screen
  @override
  Widget build(BuildContext context) {
    // widget keyword is needed to expose currentUserEmail in this build Widget - wierd
    String currentUserEmail =
        widget.user.email.toString(); // derives email for user Object passed from Login

    // get all entries here for display in Stream in ListView.
    CollectionReference entries = FirebaseFirestore.instance.collection('entries');

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Single Use Plastics Tracker ',
              //overflow: ,
              style: const TextStyle(fontSize: 18)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(children: [
            //ToDo Expanded widget needed to only expand to available space & avoid ZEBRA yellow crossing
            Expanded(
              child: StreamBuilder(
                stream: entries
                    .orderBy('logDate')
                    .where('locationID', isEqualTo: widget.user.displayName.toString())
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    // if no data // return const Center(child: Text('Loading'));
                    return const CircularProgressIndicator();
                  }
                  // todo test EU date format

                  return ListView(
                    children: snapshot.data!.docs.map((entry) {
                      return Center(
                        child: ListTile(
                          leading: Text(entry['locationID']),
                          trailing: Text(
                              entry['quantity'].toString()), // toString for listview.
                          // works leading: Text(DateFormat.yMMMEd().format(entry['logDate'].toDate())),
                          // works leading: Text(DateFormat.yMd().format(entry['logDate'].toDate())),

                          title: Text(myDateFormat.format(entry['logDate'].toDate())),

                          onLongPress: () {
                            entry.reference
                                .delete(); // ToDo handy but remove in final app
                          },
                        ),
                      );
                    }).toList(), // convert the Map to a List for use in ListView
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// Chat GPT suggestion - good code. prevents text entry OR edit - numbers only allowed.
class IntegerInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Regular expression that matches only digits
    final RegExp digitRegex = RegExp(r'\d+');

    // The ?? is the null coalescing operator.
    // It is used to provide a default value when a variable is null.
    String newString = digitRegex.stringMatch(newValue.text) ?? ''; //if null assign ''
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

// ChatGPT notes ... delete on final code for release
// In your TextField widget
//TextField(
//inputFormatters: [IntegerInputFormatter()],
// Other properties...
//)

// Notes : Date storage in Firebase as per ChatGPT
// The best way to store dates in Firebase (Firestore) using Flutter
// is to store them as Timestamp objects.
// The Timestamp class is part of the Firebase Firestore API
// and represents a specific point in time with nanosecond precision.
//
// Here's an example of how to store a DateTime as a Timestamp in Firebase:
//
// FirebaseFirestore.instance.collection("your_collection").add({
//   "date": Timestamp.fromDate(DateTime.now()),
// });
//
// In this example, DateTime.now() is used to get the current date and time,
// and Timestamp.fromDate is used to convert it to a Timestamp object that
// can be stored in Firebase. This Timestamp object can then be retrieved
// from Firebase and converted back to a DateTime using the .toDate() method.

// Use of Query to get data from Firestore
//You can use firestore query to return the current user using where()
// on getDocId():

//await FirebaseFirestore.instance.collection('users').get()
//change to Todo below to get user trend for chart
//await FirebaseFirestore.instance.collection('users')
//.where('Email name', isEqualTo: 'myEmail@mail.test').get()
