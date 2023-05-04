// tracker 27 - PreTabs :

// Note: ? means it is OK to be null but caution as it could crash your code
// Note: ! is the "assert symbol" saying I guarantee not null

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; //for all screen widgets, scaffold appbar etc
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../helpers/chart_helpers.dart';
import 'home_screen.dart';

class ChartScreen extends StatefulWidget {
  final User user;
  ChartScreen({required this.user});
  //final GlobalKey<_TimeSeriesLineChartState> chartKey = GlobalKey(); //Error

  // Declare a field that holds the currentUserEmail from Navigator pushed from login
  // final User user;
  //    LoginScreen({required this.user});

  //const ChartScreen( {Key? key,
  //    // required this.chartKey,
  //    required this.currentUserEmail})
  //   : super(key: key);

  @override
  ChartScreenState createState() => ChartScreenState();
}

class ChartScreenState extends State<ChartScreen> {
  // late User _currentUser;

  late User _currentUser;
  //late late final String currentUserEmail = user.email.toString(); // passed from the Navigator in main
  //================= CGPT 1 Mod
  // chat gpt code to redraw chart when new data is entered.
  // needed to redraw chart on data entry
  //final GlobalKey<_TimeSeriesLineChartState> _chartKey = GlobalKey();

  // void onDataEntered() {
  // Call this method whenever data is entered to update the chart
  // _chartKey.currentState?.updateData();
  // }
  //=========================

  final quantity =
      TextEditingController(); // used to input data .. number of plastic items
  //int quantityLimit = 50; // limit users to this quantity inputted to stop messers entering 10,000

  // ToDo rayDevOnly final String location = "Glanmire"; // pick up the user location later from dropdown
  final DateTime today = DateTime.now(); // this give today's date.
  final dateFormatted = DateFormat.yMd().format(DateTime.now());
// Todo ... decide final Date format style EU or US or location based.
  final myDateFormat = DateFormat('dd-MM-yyyy'); // Irish / British date format
  final int yearNumber = DateTime.now().year; // use for aggregating
  late int weekNumber; // use for aggregating
  String locationName = "";

  //== ChatGPT code
  @override
  void initState() {
    super.initState();
    // _currentUser = widget.user;
    _currentUser = widget.user;
    //currentUserEmail = widget.user.email;
    weekNumber = _getWeekNumber(
        today); // for easy calc the week number for aggregating quantities by week
    //todo Fix. this is not a string for Mallow it is an object.. must do convert to list and extract see. chart code
    getLocation(widget.user.email.toString());
    //.currentUserEmail); // get the location for this emailUser, Glanmire or Watergrasshill etc
  }

// Chat GPT how to calc the week number . combine with yearNumber for unique range
  int _getWeekNumber(DateTime date) {
    // Calculate the difference in days between the date and the first day of the year
    int diff = date.difference(DateTime(date.year, 1, 1)).inDays; //days diff
    // Calculate the week number by dividing the difference by 7
    // and adding 1 to account for the first week of the year is week zero in computerland
    return ((diff / 7) + 1)
        .floor(); //floor to round down to integer. starts at zero so add 1
  }

//== ChatGPT code
  Future<String> getLocation(String currentUserEmail) async {
    // Get a reference to the locations collection
    CollectionReference<Map<String, dynamic>> locations =
        FirebaseFirestore.instance.collection('locations');

    // Use a query to find the first document that matches the currentUserEmail
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await locations.where('userEmail', isEqualTo: currentUserEmail).get();

    // Check if any documents were returned by the query
    if (querySnapshot.size > 0) {
      setState(() {
        // to build the screen when new locationName
        locationName = querySnapshot.docs.first.data()['locationName'];
      });
      //print("in querySnapshot [locationName] is ...$locationName");
      return locationName.toString();
    } else {
      // Todo: No documents were found, return null or throw an exception
      return locationName = "";
    }
  }

  // Build the Screen
  @override
  Widget build(BuildContext context) {
    // widget keyword is needed here to expose currentUserEmail in this build Widget - not intuitive a bit wierd
    final userEmail = widget.user.email;

    // get all entries here for display in Stream in ListView.
    // Get a reference to the entries collection
    CollectionReference entries = FirebaseFirestore.instance.collection('entries');

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('$locationName - Single Use Plastics Tracker',
              //overflow: ,
              style: const TextStyle(fontSize: 16)),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              // ChatGPT on the Error
              // you can try using Navigator.pushReplacement() instead of Navigator.push()
              onPressed: () =>
                  //Navigator.pop(context),

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      // builder: (context) => LoginScreen(),
                      builder: (context) => HomeScreen(
                        user: widget.user,
                      ),
                    ),
                  )),
        ),
        body: Center(
          child: Column(children: [
            TextField(
              controller: quantity,
              decoration: const InputDecoration(
                  hintText: "Enter the number of single use plastic items this week"),
              inputFormatters: [
                // ChatGPT code to restrict data entry to numbers only
                IntegerInputFormatter()
              ],
            ),

// ============ insert the line chart here instead of ListView

            Expanded(
              child: TimeSeriesLineChart(
                //  chartKey: chartKey,
                //currentUserEmail: userEmail,
                currentUserEmail: userEmail.toString(),
              ),
            )

            // trigger chart redraw
            //chartKey.currentState?.updateChart();
            //===============
            /* // ToDo: Put this code list in a tab with the chart
            //ToDo Expanded widget needed to only expand to available space & avoid ZEBRA yellow crossing
            Expanded(
              child: StreamBuilder(
                stream: entries
                    .orderBy('logDate')
                    .where('locationID', isEqualTo: locationName.toString())
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    // if no data // return const Center(child: Text('Loading'));
                    return const CircularProgressIndicator();
                  }
                  // todo test EU date format

                  //  return ListView.builder(
                  //  itemCount: snapshot.data.docs.length, //Todo use Length to display for count of entries
                  //  itemBuilder: (context, index) {
                  //  DocumentSnapshot entry = snapshot.data.docs[index];

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

    */ // replace ListView with Chart
          ]),
        ),

        // FAB to submit plastic quantity
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            entries.add({
              // ToDo use seconds since EPOCH or maybe week number & year
              //'logDate': DateTime.now(),
              'logDate': Timestamp.fromDate(DateTime.now()),
              // added year number and week number to database
              'yearNumber': yearNumber,
              'weekNumber': weekNumber,
              //weekNumber
              // Todo locationID  Do Dropdown Select
              'locationID': locationName,
              'quantity': int.parse(quantity.text), // parse converts Text input to int
              'userID': userEmail,
            });

            // to redraw chart after data entry
            // Call this method whenever data is entered to update the chart
            // fail  _chartKey.currentState?.updateData();

            quantity.clear();
            // locationTextController.clear();
            // dateTextController.clear();
            // userTextController.clear();

            setState(() {
              // TimeSeriesLineChart._getDataPoints();
            });

            // ChatGPT code Call the updateData() method to redraw the chart
            // _chartKey.currentState?.updateData();  // fail
          },
        ),
      ),
    );
  }
}

// Chat GPT suggestion - good code. prevents text entry OR edit - numbers only allowed.
class IntegerInputFormatter extends TextInputFormatter {
  num get quantityLimit => 50; // Data Entry limit of 50 items of SUPs

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Regular expression that matches only digits
    final RegExp digitRegex = RegExp(r'\d+');

    // The ?? is the null coalescing operator.
    // It is used to provide a default value when a variable is null.
    String newString =
        digitRegex.stringMatch(newValue.text) ?? ''; //if null assign '' //empty string

    // ToDo Limit the input quantity to 50 to stop messers
    if (newString.isNotEmpty && int.parse(newString) > quantityLimit) {
      newString = quantityLimit.toString();
    }

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
