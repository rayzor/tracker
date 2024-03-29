// tracker : coder Dojo Club App to track Single Use Plastics
// Info Screen

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'chart_screen.dart';
import 'home_screen.dart';
import 'list_view_screen.dart';

//import 'chart_screen.dart';
//import 'login_screen.dart';

class InfoScreen extends StatefulWidget {
  final User user;

  const InfoScreen({Key? key, required this.user}) : super(key: key);
  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  int _selectedIndex = 3;

  /*Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushNamedAndRemoveUntil(LoginScreen.routeName, (Route<dynamic> route) => false);
  }*/

  @override
  Widget build(BuildContext context) {
    String currentUserEmail =
        widget.user.email.toString(); // derives email for user Object passed from Login
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Single Use Plastics - Tracker',
            style: TextStyle(fontSize: 16),
          ),
          actions: const []),
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
              image: DecorationImage(
                image: AssetImage('assets/images/bottles2.jpg'),
                fit: BoxFit.fill,
              ),
            ),
            //child: _widgetOptions.elementAt(_selectedIndex),
            //child: Text('Welcome ${widget.user.email.toString()}!'),
          ),
          const SizedBox(height: 20),
          // Asked ChatGPT for appropriate text for an APP on reduction of SUP ...
          const Text(
              '''Are you concerned about the impact of single-use plastics on our planet? You're not alone! Millions of people around the world are taking action to reduce their use of these harmful products.

          Here are a few simple steps you can take to help make a difference:

          Bring your own reusable bags when you go shopping
              Say "no" to plastic straws and cutlery
              Use refillable water bottles instead of disposable plastic bottles
              Choose products with minimal or no packaging whenever possible
              Recycle and dispose of plastics properly
              Together, we can make a positive impact on the environment and help protect our planet for generations to come. Join the movement to reduce single-use plastics today!'''),
        ]),
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
              backgroundColor: Colors.blue,
            ),
            GButton(
              icon: Icons.list_alt,
              text: 'Lists',
              backgroundColor: Colors.purple,
            ),
            GButton(
              icon: Icons.info,
              text: 'Info',
              backgroundColor: Colors.green,
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
                // navigate to data entry in ChartScreen : put Data Entry function in Info Screen
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
    );
  }
}
