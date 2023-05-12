// tracker : List View Screen: Show user list And Location list for this user.

// Note: ? means it is OK to be null but caution as it could crash your Dart code
// Note: ! is the "assert symbol" saying I guarantee not null in your Dart code

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; //for all screen widgets, scaffold appbar etc
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart';

import 'chart_screen.dart';
import 'info_screen.dart'; // for DateFormats

class ListViewScreen extends StatefulWidget {
  final User user;

  const ListViewScreen({Key? key, required this.user}) : super(key: key);

  @override
  ListViewScreenState createState() => ListViewScreenState();
}

class ListViewScreenState extends State<ListViewScreen> {
  int _selectedIndex = 2; // for bottomNav Tabs

  final DateTime today = DateTime.now();
  final dateFormatted = DateFormat.yMd().format(DateTime.now());
// Todo ... decide final Date format style EU or US od location based.
  final myDateFormat = DateFormat(
      'dd-MM-yyyy'); // Irish / British date format : Todo make variable by region

  //== Chat
  @override
  void initState() {
    super.initState();
  }

  // Build the Screen
  @override
  Widget build(BuildContext context) {
    // widget keyword is needed to access the User attributes in the build Widget - wierd
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
                          trailing: Text('Quantity   ' +
                              '${entry['quantity'].toString()}'), // toString for listview.
                          // works leading: Text(DateFormat.yMMMEd().format(entry['logDate'].toDate())),
                          // works leading: Text(DateFormat.yMd().format(entry['logDate'].toDate())),

                          title: Text(
                            '${myDateFormat.format(entry['logDate'].toDate())} '
                            '          Wk   '
                            ' ${entry['weekNumber'].toString()}',
                          ),

                          onLongPress: () {
                            entry.reference
                                .delete(); // ToDo handy for Development but remove in final app
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
        // bottomNav Bar ..extract to separate helper.
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
