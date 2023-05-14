// tracker : Home Screen
// Navigate to Home Screen after Login:
// Navigate to all functions from Home Screen
// Used GNav plugin library package to do the Navigation Tabs

// ChatGPT code assisted.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart';

import 'chart_screen.dart';
import 'info_screen.dart';
import 'list_view_screen.dart';
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

  //CGPT code
  TextStyle kTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  TextStyle kSubtitleStyle = TextStyle(
    fontSize: 14,
  );

  //== ChatGPT code
  @override
  void initState() {
    super.initState();
    // _currentUser = widget.user;
    //currentUserEmail = widget.user.email;
    weekNumber = _getWeekNumber(
        today); // for easy calc the week number for aggregating quantities by week
    //todo Fix. this is not a string for Glanmire it is an object.. must do convert to list and extract see. chart code
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
            'Single Use Plastics Tracker',
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
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(30),
                ),
                image: DecorationImage(
                  image: AssetImage('assets/images/boy_sea.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                children: [
                  Text(
                    'Hi $currentUserEmail',
                    style: kTitleStyle,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    // 3 quote marks allows multi line text!
                    // """Help to reduce the use of Single Use Plastics. Avoid the high cost of recycling in energy, transport and labour costs.""",
                    '''Make a positive impact on the environment and help protect our planet for generations to come. Join the movement to reduce single-use plastics today! ''',

                    style: kSubtitleStyle,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Enter the number of Single Use Plastic items put in your bin this week.",
                    style: kSubtitleStyle,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            //  const Text("ToDo -- Recode for a Spinner for Data Entry"),
            const SizedBox(height: 10),
            // New: Use Home Screen for Data Input below
            //
            // CGPT assisted code
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                children: [
                  //  const Text( "Enter quantity of items this week",
                  //    textAlign: TextAlign.center,
                  //   ),
                  TextField(
                    controller: quantity,
                    keyboardType: TextInputType
                        .number, // mod to restrice the keyboard to numbers only
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      hintText: "Enter quantity",
                    ),
                    inputFormatters: [
                      // ChatGPT code to restrict data entry to numbers only
                      IntegerInputFormatter(),
                    ],
                  ),
                ],
              ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(user: widget.user),
                  ),
                );
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
      // insert FAB here

      // FAB to submit plastic quantity
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          entries.add({
            // ToDo use seconds since EPOCH or maybe week number & year
            //'logDate': DateTime.now(), // fail needs TimeStamp type for Firebase
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
          // fail  _chartKey.currentState?.updateData(); // OUCH!

          quantity.clear();
          setState(() {
            // TimeSeriesLineChart._getDataPoints();
          });
          // ChatGPT code Call the updateData() method to redraw the chart
          // _chartKey.currentState?.updateData();  // fail OUCH!
        },
      ),

      // FAB above
    );
  }
}

//
// Chat GPT code suggestion - good code. prevents text entry OR edit - numbers only allowed.
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
