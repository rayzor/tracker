import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'chart_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  // const HomeScreen({User? user, required this.user}) : super(key: key);
  final User user;

  //const HomeScreen({required this.user});
  const HomeScreen({Key? key, required this.user}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions = <Widget>[
    const Center(
      child: Text(
        'Home',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    ),
    const Center(
      child: Text(
        'Date Entry',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    ),
    const Center(
      child: Text(
        'Charts',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    ),
    const Center(
      child: Text(
        'Info',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    ),
  ];

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    print("after Firebase signOut()");
    Navigator.of(context)
        .pushNamedAndRemoveUntil(LoginScreen.routeName, (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    String currentUserEmail =
        widget.user.email.toString(); // derives email for user Object passed from Login
    return Scaffold(
      appBar: AppBar(title: const Text('Single Use Plastics - Tracker'), actions: [
        Row(
          children: [
            Text('Logout'),
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
        child: Column(children: <Widget>[
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
          SizedBox(height: 20),
          Text('Hi ${widget.user.email}'),
          Text("You can help to stop the use of Single Use Plastics."),
          Text("Enter the number of plastic items put in your waste bin this week."),
          SizedBox(height: 50),
          Text("Put Data Entry field here - use a spinner "),
        ]),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GNav(
          gap: 8,
          activeColor: Colors.white,
          iconSize: 26,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          duration: Duration(milliseconds: 800),
          tabBackgroundColor: Colors.blue,
          tabs: [
            GButton(
              icon: Icons.home,
              text: 'Home',
              backgroundColor: Colors.blue,
            ),
            GButton(
              icon: Icons.add,
              text: 'Data Entry',
              backgroundColor: Colors.blue,
            ),
            GButton(
              icon: Icons.insert_chart,
              text: 'Charts',
              backgroundColor: Colors.purple,
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
                // navigate to ChartScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChartScreen(user: widget.user),
                  ),
                );
                break;
              case 2:
                // navigate to DataEntryScreen
                break;
              case 3:
                // navigate to InfoScreen
                break;
            }
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}

// logout from Firebase function
/*Future<dynamic> logOut() async {
  await FirebaseAuth.instance.signOut();

  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => LoginScreen(),
    ),
  );
}*/
