import 'package:charts_flutter_new/flutter.dart' as charts; // use tag charts
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Entry {
  final String locationID;
  final int quantity;
  final int yearNumber;
  final int weekNumber;

  Entry(
      {required this.locationID,
      required this.quantity,
      required this.yearNumber,
      required this.weekNumber});
}

class DataPoint {
  final int yearNumber;
  final int weekNumber;
  final int totalQuantity;

  DataPoint(this.yearNumber, this.weekNumber, this.totalQuantity);
}

class TimeSeriesLineChart extends StatefulWidget {
  final String currentUserEmail; // passed from the Navigator in main
  const TimeSeriesLineChart({Key? key, required this.currentUserEmail}) : super(key: key);

  @override
  _TimeSeriesLineChartState createState() => _TimeSeriesLineChartState();
}

class _TimeSeriesLineChartState extends State<TimeSeriesLineChart> {
  String? _locationID; // local variable to hold the location name we get from Firebase

  List<DataPoint> dataPoints = [];

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {
    final String? locationID = await _getUserLocation(widget.currentUserEmail);
    setState(() {
      _locationID = locationID;
    });
    _getDataPoints();
  }

  void _getDataPoints() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('entries')
        .where('locationID', isEqualTo: _locationID)
        .orderBy('logDate', descending: false) // order by date in ascending order
        .get();

    Map<String, List<Entry>> groupedEntries = {};
    snapshot.docs.forEach((doc) {
      Entry entry = Entry(
        locationID: doc['locationID'],
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
    });

    List<DataPoint> dataPoints = [];
    groupedEntries.forEach((key, value) {
      List<String> parts = key.split('-');
      int yearNumber = int.parse(parts[0]);
      int weekNumber = int.parse(parts[1]);

      int totalQuantity =
          value.fold(0, (previousValue, element) => previousValue + element.quantity);
      int _kount = value.length; // count of items in value list to calc average

      print("_kount is  ... $_kount");
      //int normalizedValue = ((totalQuantity / _kount) * 100).floor(); // per 100 users
      int normalizedValue = (totalQuantity / _kount).floor(); // average
      DataPoint dataPoint = DataPoint(yearNumber, weekNumber, normalizedValue);

      dataPoints.add(dataPoint);
      print("_locationID is ... $_locationID");
      print(
          "YearNum weekNumber normalizedValue = $yearNumber - $weekNumber - $totalQuantity");
    });

    setState(() {
      this.dataPoints = dataPoints;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<charts.Series<DataPoint, DateTime>> seriesList = [
      charts.Series<DataPoint, DateTime>(
        id: 'Quantity',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        // very smart to calc date for the x-axis from Jan1 plus weekNumber-1/7 // ChatGPT
        domainFn: (DataPoint dataPoint, _) => DateTime(dataPoint.yearNumber, 1, 1)
            .add(Duration(days: (dataPoint.weekNumber - 1) * 7)),
        measureFn: (DataPoint dataPoint, _) => dataPoint.totalQuantity,
        data: dataPoints,
      )
    ];

    return Container(
      color: Colors.white, // required because defaults to terrible DARK mode.
      height: 400,
      padding: EdgeInsets.all(16),
      child: dataPoints.isNotEmpty
          ? charts.TimeSeriesChart(
              seriesList,
              animate: true,
              dateTimeFactory: const charts.LocalDateTimeFactory(),
              primaryMeasureAxis: charts.NumericAxisSpec(
                tickProviderSpec: charts.BasicNumericTickProviderSpec(zeroBound: false),
              ),
              behaviors: [
                charts.ChartTitle('Single Use Plastics - ' + '', //'$locationID',
                    subTitle: 'Weekly trend - average per participant',
                    behaviorPosition: charts.BehaviorPosition.top,
                    titleOutsideJustification: charts.OutsideJustification.middle,
                    titleStyleSpec: const charts.TextStyleSpec(
                        color: charts.Color(r: 50, g: 205, b: 50),
                        fontFamily: 'Georgia',
                        fontSize: 18),
                    innerPadding: 28),
                charts.ChartTitle('Time Line',
                    behaviorPosition: charts.BehaviorPosition.bottom,
                    titleOutsideJustification:
                        charts.OutsideJustification.middleDrawArea),
                charts.ChartTitle('Plastic Items',
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

  // ChatGPTcode
// This Future function gets the user location from the locations collection by select email
// We will use this to select ALL the other Glanmire records in the collection to chart them
  Future<String?> _getUserLocation(String currentUserEmail) async {
// Get a reference to the locations collection
    CollectionReference<Map<String, dynamic>> locations =
        await FirebaseFirestore.instance.collection('locations');

// Use a query to find the first document that matches the currentUserEmail
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await locations.where('userEmail', isEqualTo: currentUserEmail).limit(1).get();

// Check if any documents were returned by the query

    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> docSnapshot = querySnapshot.docs.first;
      final String? _locationID = docSnapshot.data()!['locationName'] as String?;

      setState(() {
        print("_locationID in getLocID in SetState is  $_locationID");
      }); // to build the screen when new locationName

      return _locationID;
    }
    return null; // test for null by receiver and gracefully let user know
  }
}
