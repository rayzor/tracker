// second Chat code
import 'package:charts_flutter_new/flutter.dart'; //as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TimeSeriesLineChart extends StatefulWidget {
  const TimeSeriesLineChart({super.key});

  @override
  _TimeSeriesLineChartState createState() => _TimeSeriesLineChartState();
}

class _TimeSeriesLineChartState extends State<TimeSeriesLineChart> {
  List<ChartLine> _dataLocation = [];
  List<ChartLine> _dataParticipant = []; //rayMod for second chart line

  @override
  void initState() {
    super.initState();
    getLocationData(); // for location chart line
    getParticipantData(); //for individual participant chart line
    // getLocationComparisonData(); // to compare other communities ??
  }

  void getLocationData() async {
    // print("In getLocationData");
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    print("In getData - firestore instance is ${firestore}");
    // 01 QuerySnapshot querySnapshot = await firestore.collection('entries').get();
    QuerySnapshot querySnapshot = await firestore
        .collection('entries')
        .orderBy("logDate")
        .where('locationID', isEqualTo: 'Glanmire') //this needs a composite index
        .get();
    // print("querySnapshot line 37 $querySnapshot");
    final List<DocumentSnapshot> snapshotList = querySnapshot.docs;
    // print(snapshotList); //todo remove print
    snapshotList.forEach((entry) {
      final Timestamp timestamp = entry['logDate'];
      final DateTime logDate =
          timestamp.toDate(); //note timestamp converted to Date format
      final int quantity = entry['quantity'];
      final String locationID = entry['locationID'];
      final String userID = entry['userID'];

      final ChartLine entries = ChartLine(logDate, quantity);
//Todo remove print from production release
      print("In getLOC BLUE $logDate $quantity $locationID $userID"); //todo remove print

      _dataLocation.add(
          entries); // each extracted entry from Firebase is added to the _dataLocation list

      // print(_dataLocation); //todo remove print
    });
    setState(() {}); // to rebuild the screen
  }

  // rayMod ..add code to get the individual participant data from the Firebase database
  void getParticipantData() async {
    // print("In getLocationData");
    final FirebaseFirestore firestore =
        FirebaseFirestore.instance; //Todo dont call instance twice!!!
    User? user =
        FirebaseAuth.instance.currentUser; //get user email for filter query on DB
    String? currentUserEmail = user?.email;

    print("In getParticipant Data ${currentUserEmail}");
    // 01 QuerySnapshot querySnapshot = await firestore.collection('entries').get();
    QuerySnapshot querySnapshot = await firestore
        .collection('entries')
        .orderBy("logDate")
        .where('userID',
            isEqualTo: '$currentUserEmail') //needs a composite index for this to work
        .get();

    final List<DocumentSnapshot> snapshotList = querySnapshot.docs;
    snapshotList.forEach((entry) {
      final Timestamp timestamp = entry['logDate'];
      final DateTime logDate =
          timestamp.toDate(); // note here timestamp converted to Date format
      final int quantity = entry['quantity'];
      final String locationID = entry['locationID'];
      final String userID = entry['userID'];

      final ChartLine entries = ChartLine(logDate, quantity);

      print("In getPAR GREEN $logDate $quantity $locationID $userID"); //todo remove print

      _dataParticipant.add(
          entries); // each extracted entry from Firebase is added to the _dataLocation list
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      ///stops keyboard overflow
      //appBar: new AppBar( title: _buildTitle(context), actions: _buildActions( context ), ),

      body: SafeArea(
        child: Container(
          // return Container(
          color: Colors.white, // required because defaults to terrible DARK mode.
          // height: 350,
          child: _dataLocation.isNotEmpty
              ? TimeSeriesChart(
                  [
                    Series<ChartLine, DateTime>(
                      id: 'locationChartID',
                      colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
                      //rayMod fillColorFn: (_, __) => MaterialPalette.yellow.shadeDefault,
                      domainFn: (entries, _) => entries.logDate,
                      measureFn: (entries, _) => entries.quantity,
                      displayName: ('Single Use Plastics'), // translated version
                      data: _dataLocation,
                    ),
                    Series<ChartLine, DateTime>(
                      id: 'participantChartID',
                      colorFn: (_, __) => MaterialPalette.red.shadeDefault,
                      //rayMod fillColorFn: (_, __) => MaterialPalette.yellow.shadeDefault,
                      domainFn: (entries, _) => entries.logDate,
                      measureFn: (entries, _) => entries.quantity,
                      displayName: ('Single Use Plastics'), // translated version
                      data: _dataParticipant,
                    ),
                  ],
                  animate: true,
                  //  animationDuration: Duration(seconds: 2), // chart animation 1sec
                  //  dateTimeFactory: const LocalDateTimeFactory(),
                  //  defaultRenderer: LineRendererConfig(includePoints: true),
                  behaviors: [
                    ChartTitle('Glanmire Single Use Plastics',
                        subTitle: 'Weekly trend per 1000 residents',
                        behaviorPosition: BehaviorPosition.top,
                        titleOutsideJustification: OutsideJustification.middle,
                        titleStyleSpec: TextStyleSpec(
                            //     HTML / CSS Color Name	Hex Code #RRGGBB	Decimal Code (R,G,B)
                            //   lawngreen	#7CFC00	rgb(124,252,0)
                            //  chartreuse	#7FFF00	rgb(127,255,0)
                            //  limegreen	#32CD32	rgb(50,205,50)
                            // ORIG color: Color(r: 127, g: 63, b: 191),
                            color: Color(r: 50, g: 205, b: 50),
                            fontFamily: 'Georgia',
                            fontSize: 18),

                        // Set a larger inner padding than the default (10) to avoid
                        // rendering the text too close to the top measure axis tick label.
                        // The top tick label may extend upwards into the top margin region
                        // if it is located at the top of the draw area.
                        innerPadding: 28),
                    ChartTitle('Time Line',
                        behaviorPosition: BehaviorPosition.bottom,
                        titleOutsideJustification: OutsideJustification.middleDrawArea),
                    new ChartTitle('Plastic Items',
                        behaviorPosition: BehaviorPosition.start,
                        titleOutsideJustification: OutsideJustification.middleDrawArea),
                    new ChartTitle('',
                        behaviorPosition: BehaviorPosition.end,
                        titleOutsideJustification: OutsideJustification.middleDrawArea),
                  ],
                )
              : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

// Model for Chart with x and y axix defined. Put in model folder later
class ChartLine {
  final DateTime logDate;
  final int quantity;

  ChartLine(@required this.logDate, @required this.quantity);
}
// In this example, we define a Sales class that holds the data for each entry,
// which consists of a DateTime and a quantity. We also define a TimeSeriesLineChart widget
// that retrieves data from a Firebase collection called "entries" and stores it in a list of Sales objects.

// The getData method retrieves the data from Firebase and populates the _dataLocation list.
// We convert the Timestamp value in the "date" field to a DateTime object and
// create a Sales object with the date and quantity values. Once the data has been retrieved,
// we call setState to trigger a rebuild of the widget and display the chart.

// In the build method, we use the TimeSeriesChart widget from charts_flutter_new to build the chart.
// We create a Series with the Sales list as the data source and specify the domainFn and measureFn functions
// to extract the date and quantity values from each Sales object.
// We also set the dateTimeFactory property to LocalDateTimeFactory,
// which creates DateTime objects in the local time zone.
// Finally, we pass the Series to the TimeSeriesChart widget and set the animate property to true.

// I hope this helps! Let me know if you have any questions.

//In this example, we define a Sales class that holds the data for each entry, which consists of a DateTime and a quantity. We also define a TimeSeriesLineChart widget that retrieves data from a Firebase collection called "entries" and stores it in a list of Sales objects.
//
// The getData method retrieves the data from Firebase and populates the _dataLocation list. We convert the Timestamp value in the "date" field to a DateTime object and create a Sales object with the date and quantity values. Once the data has been retrieved, we call setState to trigger a rebuild of the widget and display the chart.
//
// In the build method, we use the TimeSeriesChart widget from charts_flutter_new to build the chart. We create a Series with the Sales list as the data source and specify the domainFn and measureFn functions to extract the date and quantity values from each Sales object. We also set the dateTimeFactory property to LocalDateTimeFactory, which creates DateTime objects in the local time zone. Finally, we pass the Series to the TimeSeriesChart widget and set the animate property to true.
//
// I hope this helps! Let me know if you have any questions.

// SUM query
//In this example, we're querying a collection named "products"
// for documents
// where the "category" field equals "fruit".
// We're then using the map() method to convert the query result
// to a list of integers representing the quantity field
// of each document, and using the reduce() method
// to add up all the values in the list.
// The result is the total quantity of all documents in the query result.
//
// You can modify this code to match the collection
// and field names of your Firestore database.

//CODE is
//final FirebaseFirestore firestore = FirebaseFirestore.instance;
//
// // Querying a Firestore collection named "products" for documents where the "category" field equals "fruit"
// QuerySnapshot snapshot = await firestore.collection('products')
//     .where('category', isEqualTo: 'fruit')
//     .get();
//
// // Summing the quantity of all documents in the query result
// int totalQuantity = snapshot.docs.map<int>((doc) => doc['quantity']).reduce((a, b) => a + b);
//
// // Printing the total quantity
// print(totalQuantity);

// Notes on Query by date
//In this example, we're using the orderBy() method to sort the documents
// in descending order by the date field. You can replace the posts collection name
// and the date field name with your own collection and field names.
// Once you have the sorted QuerySnapshot, you can convert the DocumentSnapshot
// objects to maps using the data() method, and then manipulate the resulting
// list of maps as needed.

// Ex:
//final FirebaseFirestore firestore = FirebaseFirestore.instance;
//
// // Retrieving documents from a Firestore collection named "posts"
// QuerySnapshot snapshot = await firestore.collection('posts')
//     .orderBy('date', descending: true)
//     .get();
//
// // Converting each document to a Map
// List<Map<String, dynamic>> posts = snapshot.docs.map((doc) => doc.data()).toList();
//
// // Printing the list of posts
// print(posts);
