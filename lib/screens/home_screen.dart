// tracker : Home Screen : after Login: navigate to all functions from Home Screen

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart';

import 'chart_screen.dart';
import 'data_entry.dart';
import 'info_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final quantity =
      TextEditingController(); // used to input data .. number of plastic items
  // ToDo rayDevOnly final String location = "Glanmire"; // pick up the user location later from dropdown
  final DateTime today = DateTime.now(); // this give today's date.
  final dateFormatted = DateFormat.yMd().format(DateTime.now());
// Todo ... decide final Date format style EU or US or location based.
  final myDateFormat = DateFormat('dd-MM-yyyy'); // Irish / British date format
  final int yearNumber = DateTime.now().year; // use for aggregating
  late int weekNumber; // use for aggregating

  //== ChatGPT code
  @override
  void initState() {
    super.initState();
    // _currentUser = widget.user;
    // _currentUser = widget.user;
    //currentUserEmail = widget.user.email;
    weekNumber = _getWeekNumber(
        today); // for easy calc the week number for aggregating quantities by week
    //todo Fix. this is not a string for Mallow it is an object.. must do convert to list and extract see. chart code
    //   getLocation(widget.user.email.toString());
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

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushNamedAndRemoveUntil(LoginScreen.routeName, (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Get a reference to the entries collection
    CollectionReference entries = FirebaseFirestore.instance.collection('entries');
    String currentUserEmail =
        widget.user.email.toString(); // derives email for user Object passed from Login
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Single Use Plastics - Tracker',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            Row(
              children: [
                const Text('Logout'),
                IconButton(
                  onPressed: () {
                    _signOut(); // sign out user
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
          ]),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 250,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  //topLeft: Radius.circular(60),
                  //topRight: Radius.circular(60),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(30),
                ),
                //image: DecorationImage(
                // image: NetworkImage(
                //   'https://cdn.pixabay.com/photo/2015/03/30/12/37/jellyfish-698521__340.jpg'),
                //fit: BoxFit.fill)
                image: DecorationImage(
                  image: AssetImage('assets/images/boy_sea.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
              //child: _widgetOptions.elementAt(_selectedIndex),
              //child: Text('Welcome ${widget.user.email.toString()}!'),
            ),
            const SizedBox(height: 20),
            Text('Hi $currentUserEmail'),
            const Text("You can help to stop the use of Single Use Plastics."),
            const Text(
                "Enter the number of plastic items put in your waste bin this week."),
            const SizedBox(height: 50),
            const Text("Put Data Entry field here - use a spinner "),

            // New: Use Home Screen for Data Input here
            TextField(
              controller: quantity,
              decoration: const InputDecoration(
                  hintText: "Enter the number of single use plastic items this week"),
              inputFormatters: [
                // ChatGPT code to restrict data entry to numbers only
                IntegerInputFormatter()
              ],
            ),
          ],
        ),
      ),
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
                break;
              case 1:
                // navigate to data entry in ChartScreen : put Data Entry function in Home Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChartScreen(user: widget.user),
                  ),
                );
                break;
              case 2:
                // navigate to Charts
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DataEntry(user: widget.user),
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
      // insert FAB here

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
            'locationID': widget.user.displayName,
            'quantity': int.parse(quantity.text), // parse converts Text input to int
            'userID': widget.user.email,
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

      // FAB above
    );
  }
}

//
// Chat GPT suggestion - good code. prevents text entry OR edit - numbers only allowed.
class IntegerInputFormatter extends TextInputFormatter {
  num get quantityLimit =>
      50; // Data Entry limit of 50 items of SUPs : put in Params file in firestore

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Regular expression that matches only digits
    final RegExp digitRegex = RegExp(r'\d+');

    // The ?? is the null coalescing operator.
    // It is used to provide a default value when a variable is null.
    String newString =
        digitRegex.stringMatch(newValue.text) ?? ''; //if null assign '' //empty string

    // ToDo Limit the input quantity to 50 to stop rogue inputs
    if (newString.isNotEmpty && int.parse(newString) > quantityLimit) {
      newString = quantityLimit.toString();
    }

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
