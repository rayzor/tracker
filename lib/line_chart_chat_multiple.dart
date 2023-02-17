//Certainly! Here's a Flutter code example that creates
// a time series chart using the charts_flutter library
// with data from a Firebase Firestore database.
// This example uses the logDate, locationID, quantity, and userID fields
// from a collection and displays two chart lines,
// one for locationID and one for userID,
// with colors red and green, respectively.

//chatGPT

import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimeSeriesChart extends StatefulWidget {
  const TimeSeriesChart({Key? key}) : super(key: key);

  @override
  _TimeSeriesChartState createState() => _TimeSeriesChartState();
}

class _TimeSeriesChartState extends State<TimeSeriesChart> {
  List<charts.Series<ChartData, DateTime>> _seriesList = [];

  @override
  void initState() {
    super.initState();
    _seriesList = _createSampleData();
  }

  List<charts.Series<ChartData, DateTime>> _createSampleData() {
    final data = FirebaseFirestore.instance.collection('entries');
    return [
      charts.Series<ChartData, DateTime>(
        id: 'locationID',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (ChartData chartData, _) => DateTime.parse(chartData.logDate),
        measureFn: (ChartData chartData, _) => chartData.locationID,
        // data: _getData(data, 'locationID'),
        data: _getData(data, 'Glanmire'),
      ),
      charts.Series<ChartData, DateTime>(
        id: 'userID',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (ChartData chartData, _) => DateTime.parse(chartData.logDate),
        measureFn: (ChartData chartData, _) => chartData.userID,
        //data: _getData(data, 'userID'),
        data: _getData(data, 'test0@test.com'),
      ),
    ];
  }

  List<ChartData> _getData(Query data, String field) {
    List<ChartData> dataList = [];
    data.where(field, isGreaterThan: 0).orderBy('logDate').snapshots().listen((snapshot) {
      snapshot.docs.forEach((doc) {
        dataList.add(ChartData(
          logDate: doc.get('logDate').toString(),
          locationID: doc.get('locationID'),
          quantity: doc.get('quantity'),
          userID: doc.get('userID'),
        ));
      });
      setState(() {});
    });
    return dataList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Time Series Chart')),
      body: Center(
        child: Container(
          height: 400,
          padding: EdgeInsets.all(20),
          child: charts.TimeSeriesChart(
            _seriesList,
            animate: true,
            dateTimeFactory: const charts.LocalDateTimeFactory(),
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final String logDate;
  final int locationID;
  final int quantity;
  final int userID;

  ChartData(
      {required this.logDate,
      required this.locationID,
      required this.quantity,
      required this.userID});
}
