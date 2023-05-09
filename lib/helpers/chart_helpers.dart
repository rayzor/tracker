// tracker: line_chart. Builds the 2 line chart of location trend and user trend
// ChatGPT code assist
import 'package:charts_flutter_new/flutter.dart' as charts; // use tag charts
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Define a temp class Entry to save the query entries from Firebase in memory.
class Entry {
  final String locationID;
  final String userID;
  final int quantity;
  final int yearNumber;
  final int weekNumber;

  Entry(
      {required this.locationID,
      required this.userID,
      required this.quantity,
      required this.yearNumber,
      required this.weekNumber});
}

// Define a temp class DataPoint to hold the Chart data points derived from the Entries
class DataPoint {
  final int yearNumber;
  final int weekNumber;
  final int averageQuantity;

  DataPoint(this.yearNumber, this.weekNumber, this.averageQuantity);
}

// chart
class TimeSeriesLineChart extends StatefulWidget {
  User user;

  //final Key chartKey; // to provide a key called from dataentry to redraw chart every time data is entered.
  //final chartKey = GlobalKey<_TimeSeriesLineChartState>(); // ChatGPT suggested code
  //final String currentUserEmail; // passed from the Navigator in main/login

  // final User user; // full user fields forwarded from login
  // TimeSeriesLineChart({required this.user});

  TimeSeriesLineChart(
      {Key? key,
      // required this.chartKey,
      //  required user: user})
      // required this.currentUserEmail})
      required this.user})
      : super(key: key);

  @override
  TimeSeriesLineChartState createState() => TimeSeriesLineChartState();
}

class TimeSeriesLineChartState extends State<TimeSeriesLineChart> {
  List<DataPoint> dataPointsLocation = []; // empty array for loc data from firestore
  List<DataPoint> dataPointsUser = []; // empty array for the data from firestore

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    //  String? locationID = await _getUserLocation(widget.currentUserEmail);
    //  setState(() {
    //    locationID = locationID;
    //  });
    // String? currentLocation = widget.user.displayName; // local variable to hold the location name we get from Firebase
    // String? currentUserEmail = widget.user.displayName;

    _getLocationDataPoints(
        // currentlocation
        widget.user.displayName); // get this user full location data from firestore.

    _getUserDataPoints(widget.user.displayName,
        widget.user.email); // get this user ONLY data from firestore.
  }

  // ChatGPTcode
// This Future function gets the user location from the locations collection by select email
// We will use this to select ALL the other Glanmire records in the collection to chart them

  // to do Delete no longer reqd because we have user location from signup in users Firestore file as "displayName"
  Future<String?> _getUserLocation(String currentUserEmail) async {
// Get a reference to the locations collection in tracker db on Firestore London
    // no longer required: Location s now recorded in the Auth User data as displayName.
    CollectionReference<Map<String, dynamic>> locations =
        await FirebaseFirestore.instance.collection('locations');

// Use a query to find the first document that matches the currentUserEmail
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await locations.where('userEmail', isEqualTo: currentUserEmail).limit(1).get();

// Check if any documents were returned by the query
    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> docSnapshot = querySnapshot.docs.first;
      final String? locationID = docSnapshot.data()!['locationName'] as String?;

      setState(() {});
      return locationID;
    }
    return null; // test for null by receiver and gracefully let user know. NoCrash
  }

// to trigger chart update ChatGPT
  void updateChart() {
    // Call this method to update the chart with new data
    setState(() {
      // update chart data here ?? HOW ?? //todo
    });
  }

  _getLocationDataPoints(locationID) async {
    print("In Chart Helper getLocationDataPoints locationID is ... $locationID");
    print("Type of locationID is ${locationID.runtimeType}");

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance //wakeup Firebase
            .collection('entries')
            .where('locationID', isEqualTo: locationID)
            //Todo remove this rem to use date order. Remmed for test only
            .orderBy('logDate', descending: false) // order by date in ascending order
            .get();

    Map<String, List<Entry>> groupedEntries = {}; //empty Map with {}
// group the entries by year/weekNo for easy use by chart timeline.
    for (var doc in snapshot.docs) {
      Entry entry = Entry(
        locationID: doc['locationID'],
        userID: doc['userID'],
        quantity: doc['quantity'],
        yearNumber: doc['yearNumber'],
        weekNumber: doc['weekNumber'],
      );
      String key = '${entry.yearNumber}-${entry.weekNumber}';
      if (!groupedEntries.containsKey(key)) {
        groupedEntries[key] = [entry];
      } else {
        groupedEntries[key]!.add(entry);
      }
    }

    List<DataPoint> dataPoints = []; //empty List based on class DataPoint as def above
    // to group the entries by week
    groupedEntries.forEach(
      (key, value) {
        List<String> parts = key.split('-');
        int yearNumber = int.parse(parts[0]);
        int weekNumber = int.parse(parts[1]);
        // use the "fold" function to accumulate the total quantity for each weekno
        int totalQuantity =
            value.fold(0, (previousValue, element) => previousValue + element.quantity);
        int kount = value.length; // count of items in value list to calc average
        // Normalise the data to per user
        int averageQuantity = (totalQuantity / kount).floor(); // average
        DataPoint dataPoint = DataPoint(yearNumber, weekNumber, averageQuantity);
        dataPoints.add(dataPoint);
//todo del on final
        print("In Chart Helpers locationID is ... $locationID");
        print(
            "In Chart Helpers YearNum weekNumber normalizedValue = $yearNumber - $weekNumber - $totalQuantity");
      },
    );
    setState(() {
      dataPointsLocation =
          dataPoints; // we now have the Location data points for the chart
    });
  } // end get

  // PART 2 - get USer data points - clone loc chart to get User chart line

  // ChatGPT ... good tip -  use locationID and UserID to get the specific User chart data points
  _getUserDataPoints(locationID, userID) async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance //instantiate Firebase
            .collection('entries')
            .where('locationID', isEqualTo: locationID) //filter by this location
            .where('userID', isEqualTo: userID) // filter by user ID
            .orderBy('logDate', descending: false) // order by date in ascending order
            .get();

    // Group the data points by week to sum by week - user will usually only have 1 entry er week
    Map<String, List<Entry>> groupedEntries = {}; //empty Map with {}
    for (var doc in snapshot.docs) {
      Entry entry = Entry(
        locationID: doc['locationID'],
        userID: doc['userID'],
        quantity: doc['quantity'],
        yearNumber: doc['yearNumber'],
        weekNumber: doc['weekNumber'],
      );

      String key = '${entry.yearNumber}-${entry.weekNumber}';
      if (!groupedEntries.containsKey(key)) {
        groupedEntries[key] = [entry];
      } else {
        groupedEntries[key]!.add(entry);
      }
    }

    List<DataPoint> dataPoints2 = []; //empty List based on class DataPoint as def above
    // to group the entries by week
    groupedEntries.forEach(
      (key, value) {
        List<String> parts = key.split('-');
        int yearNumber = int.parse(parts[0]);
        int weekNumber = int.parse(parts[1]);

        int totalQuantity =
            value.fold(0, (previousValue, element) => previousValue + element.quantity);
        int kount = value.length;

        int averageQuantity = (totalQuantity / kount).floor(); // average

        DataPoint dataPoints = DataPoint(yearNumber, weekNumber, averageQuantity);
        dataPoints2.add(dataPoints);
      },
    );
    setState(() {
      dataPointsUser = dataPoints2;
    });
  }

  // Build the screen here
  @override
  Widget build(BuildContext context) {
    // the X-axis of the chart is domainFn of dates
    // the Y-axis of the chart is measureFn of quantity
    // see charts_flutter package on how to code/configure the chart params
    List<charts.Series<DataPoint, DateTime>> seriesList = [
      //First chart line here - Location trend line
      charts.Series<DataPoint, DateTime>(
        id: '${widget.user.displayName}', //  id: '$locationID Trend', //FAIL
        colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
        // ChatGPT very smart to calc date for the x-axis from Jan1 plus weekNumber-1/7 // ChatGPT
        domainFn: (DataPoint dataPoint, _) => DateTime(dataPoint.yearNumber, 1, 1)
            .add(Duration(days: (dataPoint.weekNumber - 1) * 7)),
        measureFn: (DataPoint dataPoint, _) => dataPoint.averageQuantity,
        data: dataPointsLocation,
      ),
      //put second User line chart data here
      charts.Series<DataPoint, DateTime>(
        id: 'User',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        // ChatGPT very smart to calc date for the x-axis from Jan1 plus weekNumber-1/7 // ChatGPT
        domainFn: (DataPoint dataPoint, _) => DateTime(dataPoint.yearNumber, 1, 1)
            .add(Duration(days: (dataPoint.weekNumber - 1) * 7)),
        measureFn: (DataPoint dataPoint, _) => dataPoint.averageQuantity,
        data: dataPointsUser,
      ),
    ];
    // print("data points Location $dataPointsLocation");
    //  print("data points User $dataPointsUser");
    // here we have the 2 chart lines dataPoints ..brill So then create Series
    return Container(
      color: Colors.white, // required because defaults to terrible DARK mode.
      height: 400,
      padding: EdgeInsets.all(16),

      child: dataPointsLocation.isNotEmpty
          ? charts.TimeSeriesChart(
              seriesList,
              animate: true,
              animationDuration: Duration(seconds: 1),
              // Todo new added to show points in line chart line
              defaultRenderer: new charts.LineRendererConfig(includePoints: true),
              // chart animation 1sec
              dateTimeFactory: const charts.LocalDateTimeFactory(),
              primaryMeasureAxis: charts.NumericAxisSpec(
                tickProviderSpec: charts.BasicNumericTickProviderSpec(zeroBound: false),
              ),
              behaviors: [
                new charts.SeriesLegend(
                    horizontalFirst: true, // true = across false for line after line
                    showMeasures:
                        true, // shows values after Legends whn dots ar selected .. nice
                    cellPadding: new EdgeInsets.only(top: 20.0, right: 4.0, bottom: 4.0),
                    entryTextStyle: charts.TextStyleSpec(
                        // color: charts.Color(r: 127, g: 63, b: 191),
                        color: charts.Color(r: 0, g: 0, b: 129),
                        fontFamily: 'Georgia',
                        fontSize: 16) // + textFactor),
                    ),
                charts.ChartTitle('Weekly Trend',
                    // subTitle: 'Weekly Trend - Average',
                    behaviorPosition: charts.BehaviorPosition.top,
                    titleOutsideJustification: charts.OutsideJustification.middle,
                    titleStyleSpec: const charts.TextStyleSpec(
                        color: charts.Color(r: 50, g: 205, b: 50),
                        fontFamily: 'Georgia',
                        fontSize: 14),
                    innerPadding: 28),
                charts.ChartTitle('Time Line',
                    behaviorPosition: charts.BehaviorPosition.bottom,
                    titleOutsideJustification:
                        charts.OutsideJustification.middleDrawArea),
                charts.ChartTitle('Single Use Plastics',
                    behaviorPosition: charts.BehaviorPosition.start,
                    titleOutsideJustification:
                        charts.OutsideJustification.middleDrawArea),
                charts.ChartTitle('',
                    behaviorPosition: charts.BehaviorPosition.end,
                    titleOutsideJustification:
                        charts.OutsideJustification.middleDrawArea),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
} // END TOTAL
