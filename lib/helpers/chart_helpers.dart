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

// chart : this is the chart code for charts_flutter package.
class TimeSeriesLineChart extends StatefulWidget {
  User user;

  //final Key chartKey; // to provide a key called from dataentry to redraw chart every time data is entered.
  //final chartKey = GlobalKey<_TimeSeriesLineChartState>(); // ChatGPT suggested code
  //final String currentUserEmail; // passed from the Navigator in main/login

  // final User user; // full user fields forwarded from login
  // TimeSeriesLineChart({required this.user});

  TimeSeriesLineChart({Key? key, required this.user}) : super(key: key);

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
    _getLocationDataPoints(
        // currentlocation
        widget.user.displayName); // get full location data for this user from firestore.

    _getUserDataPoints(widget.user.displayName,
        widget.user.email); // get this user ONLY data from firestore.
  }

// to trigger chart update ChatGPT
  void updateChart() {
    // Call this method to update the chart with new data
    setState(() {
      // update chart data here ?? HOW ?? //todo
    });
  }

  // ChatGPT code works.
  _getLocationDataPoints(locationID) async {
    print("In Chart Helper getLocationDataPoints locationID is ... $locationID");
    print("Type of locationID is ${locationID.runtimeType}");

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance //wakeup Firebase
            .collection('entries')
            .where('locationID', isEqualTo: locationID)
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
    // to group the entries by week to get Totals per week for all location users, number of entries and Average
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
      dataPointsLocation = dataPoints; // use for the Location data points for the chart
    });
  } // end get

  // PART 2 - get User data points - clone loc chart code to get User chart line

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
      dataPointsUser = dataPoints2; // used for user Chart
    });
  }

  // Build the chart screen here
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

    // here we have the 2 chart lines dataPoints ..brill so then create Series
    return Container(
      color: Colors.white, // required because defaults to terrible DARK mode.
      height: 400,
      padding: const EdgeInsets.all(16),

      child: dataPointsLocation.isNotEmpty
          ? charts.TimeSeriesChart(
              seriesList,
              animate: true,
              animationDuration: const Duration(seconds: 1),
              // Todo new added to show points in line chart line
              defaultRenderer: charts.LineRendererConfig(includePoints: true),
              // chart animation 1sec
              dateTimeFactory: const charts.LocalDateTimeFactory(),
              primaryMeasureAxis: const charts.NumericAxisSpec(
                tickProviderSpec: charts.BasicNumericTickProviderSpec(zeroBound: false),
              ),
              behaviors: [
                charts.SeriesLegend(
                    horizontalFirst: true, // true = across false for line after line
                    showMeasures:
                        true, // shows values after Legends whn dots ar selected .. nice
                    cellPadding:
                        const EdgeInsets.only(top: 20.0, right: 4.0, bottom: 4.0),
                    entryTextStyle: const charts.TextStyleSpec(
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
          : const Center(child: CircularProgressIndicator()),
    );
  }
} // END TOTAL
