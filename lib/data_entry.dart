// This is Tommy's main page code for Cloud firestore Apples / Oranges
// called from Main and cut down for Data Entry ... much better arch to do this but maybe best
// to stick to his building blocks so the boys get how simple it is.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; //for all screen widgets, scaffold appbar etc
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // for DateFormats

class DataEntry extends StatefulWidget {
  // Declare a field that holds the currentUserEmail from Navigator push in main.dart
  final String currentUserEmail; // to pass via the NAvigator to the DataEntry screen

  DataEntry({Key? key, required this.currentUserEmail}) : super(key: key);

  @override
  _DataEntryState createState() => _DataEntryState();
}

class _DataEntryState extends State<DataEntry> {
  final quantity = TextEditingController();
  final String location = "Glanmire"; // pick up the user location later from dropdown
  final DateTime today = DateTime.now();
  final dateFormatted = DateFormat.yMd().format(DateTime.now());
// Todo ... decide final Date format style EU or US od loaction based.
  final myDateFormat = new DateFormat('dd-MM-yyyy');
  @override
  Widget build(BuildContext context) {
    // the use of WIDGET here is very wierd syntax .not at all intuitive or logical.
    final userEmail = widget.currentUserEmail;
    print("In DataEntry + ${userEmail}");

    // get all entries here for display in Stream in ListView.
    CollectionReference entries = FirebaseFirestore.instance.collection('entries');
    print("Entries from FirebaseFirestore.instance . collection ARE ");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Single Use Plastics Tracker - $location',
              //overflow: ,
              style: TextStyle(fontSize: 18)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(children: [
            TextField(
              controller: quantity,
              decoration: InputDecoration(hintText: "Enter quantity of plastic items"),
              inputFormatters: [
                IntegerInputFormatter()
              ], // to restrict to numbers only ChatGPt
            ),

            //ToDo rayMod use Expanded to only expand to available space & avoid ZEBRA yellow crossing
            Expanded(
              child: StreamBuilder(
                stream: entries.orderBy('logDate').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: Text('Loading'));
                  }
                  // test EU date format

                  print("In StreamBuilder + $snapshot");
                  return ListView(
                    // Note: ! is assert symbol saying I guarantee not null
                    //    or ? is it is OK to be null but caution as it could fail
                    children: snapshot.data!.docs.map((entry) {
                      return Center(
                        child: ListTile(
                          leading: Text(entry['locationID']),
                          trailing:
                              Text(entry['quantity'].toString()), // String for listview.
                          // works leading: Text(DateFormat.yMMMEd().format(entry['logDate'].toDate())),
                          // works leading: Text(DateFormat.yMd().format(entry['logDate'].toDate())),

                          title: Text(myDateFormat.format(entry['logDate'].toDate())),

                          onLongPress: () {
                            entry.reference.delete(); // ToDo nice but not in this app
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ]),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: () {
            entries.add({
              // ToDo use seconds since EPOCH or maybe week number & year
              //'logDate': DateTime.now(),
              'logDate': Timestamp.fromDate(DateTime.now()),

              // maybe use locationID or itemID as generic as possible for other trackers ..
              'locationID':
                  "Glanmire", // only fixed now for dev and test Do Dropdown Select
              'quantity':
                  int.parse(quantity.text), // convert Text input to int for Firestore
              'userID': userEmail,
            });
            quantity.clear();
            // locationTextController.clear();
            // dateTextController.clear();
            // userTextController.clear();
          },
        ),
      ),
    );
  }
}

// Chat GPT suggestion - good code. prevents entry OR edit to text.
class IntegerInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Regular expression that matches only digits
    final RegExp digitRegex = RegExp(r'\d+');

    String newString = digitRegex.stringMatch(newValue.text) ?? '';
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

// In your TextField widget
//TextField(
//inputFormatters: [IntegerInputFormatter()],
// Other properties...
//)

// Notes : Date storage in Firebase as per ChatGPT
// The best way to store dates in Firebase (Firestore) using Flutter is to store them as Timestamp objects. The Timestamp class is part of the Firebase Firestore API and represents a specific point in time with nanosecond precision.
//
// Here's an example of how to store a DateTime as a Timestamp in Firebase:
//
// dart
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
