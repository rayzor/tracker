// tracker :  Chart Screen : Front End: calls Helper Chart functions to build Chart

// Note: ? means it is OK to be null but caution as it could crash your code
// Note: ! is the "assert symbol" saying I guarantee not null

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; //for all screen widgets, scaffold appbar etc
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart';

import '../helpers/chart_helpers.dart';
import 'home_screen.dart';
import 'info_screen.dart';
import 'list_view_screen.dart';

class ChartScreen extends StatefulWidget {
  final User user; // User Object: full user fields forwarded from login
  ChartScreen({required this.user});

  @override
  ChartScreenState createState() => ChartScreenState();
}

class ChartScreenState extends State<ChartScreen> {
  int _selectedIndex = 1; // for bottomNav Tabs

  // ToDo rayDevOnly final String location = "Glanmire"; // pick up the user location later from dropdown
  // Dates not used in this screen .. delete on final.
  final DateTime today = DateTime.now(); // this give today's date.
  final dateFormatted = DateFormat.yMd().format(DateTime.now());
// Todo ... decide final Date format style EU or US or location based.
  final myDateFormat = DateFormat('dd-MM-yyyy'); // Irish / British date format
  final int yearNumber = DateTime.now().year; // use for aggregating
  late int weekNumber; // use for aggregating all entries by weekNumber

  //== ChatGPT code assisted
  @override
  void initState() {
    super.initState();
    // _currentUser = widget.user;
    //currentUserEmail = widget.user.email;
    //weekNumber = _getWeekNumber(today); // for easy calc the week number for aggregating quantities by week
    //todo Fix. this is not a string for Glanmire it is an object.. must do convert to list and extract see. chart code
    //   getLocation(widget.user.email.toString());
    //.currentUserEmail); // get the location for this emailUser, Glanmire or Watergrasshill etc
  }

// Chat GPT code assisted. how to calc the week number . combine with yearNumber for unique range
  /* int _getWeekNumber(DateTime date) {
    // Calculate the difference in days between the date and the first day of the year
    int diff = date.difference(DateTime(date.year, 1, 1)).inDays; //days diff
    // Calculate the week number by dividing the difference by 7
    // and adding 1 to account for the first week of the year is week zero in computerland
    return ((diff / 7) + 1)
        .floor(); //floor to round down to integer. starts at zero so add 1
  }*/

  // Build the Screen
  @override
  Widget build(BuildContext context) {
    // widget keyword is needed here to expose currentUserEmail in this build Widget - not intuitive a bit wierd
    // final userEmail = widget.user.email;

    // For Dev purposes only Print to console
    String? _currentUserEmail = widget.user.email;
    print(" >>>> In ChartScreen _current user is ${_currentUserEmail}");
    String? _currentLocation = widget.user.displayName;
    print(" >>>> In ChartScreen _current Location is ${_currentLocation}");
    // get all entries here for display in Stream in ListView.
    // Get a reference to the entries collection
    CollectionReference entries = FirebaseFirestore.instance.collection('entries');
    print(
        " >>>> In ChartScreen Sending widget.user to TimeSeriesLineChart ${widget.user} ");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          //title: Text('$_currentLocation - Single Use Plastics Tracker',
          title: Text('Single Use Plastics Tracker',
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
          child: Column(
            children: [
// ============ insert the line chart here from Chart Helpers : Class name is TimeSeriesLineChart
// Build Chart with User and Location Data points from firestore:
// send User Object which has the userID and locationID to get the DataPoints for the 2 charts
              Expanded(child: TimeSeriesLineChart(user: widget.user)),
            ],
          ),
        ),

        // bottom Nav Tabs : Uses GNav plugin package
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GNav(
            gap: 8,
            activeColor: Colors.white,
            iconSize: 26,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            duration: const Duration(milliseconds: 800),
            tabBackgroundColor: Colors.blue,
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
                backgroundColor: Colors.blue,
              ),
              GButton(
                icon: Icons.insert_chart,
                text: 'Charts',
                backgroundColor: Colors.purple,
              ),
              GButton(
                icon: Icons.list_alt,
                text: 'Lists',
                backgroundColor: Colors.blue,
              ),
              GButton(
                icon: Icons.info,
                text: 'Info',
                backgroundColor: Colors.red,
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              switch (index) {
                case 0:
                  // navigate to HomeScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(user: widget.user),
                    ),
                  );

                  break;
                case 1:
                  // navigate to ChartScreen : put Data Entry function in Home Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChartScreen(user: widget.user),
                    ),
                  );
                  break;
                case 2:
                  // navigate to List View Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListViewScreen(user: widget.user),
                    ),
                  );
                  break;
                case 3:
                  // navigate to InfoScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InfoScreen(user: widget.user),
                    ),
                  );
                  break;
              }
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
