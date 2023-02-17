// ChatGPT verion of line chart for cjartd Flutter example...
// Your code looks good overall, but there are a few suggestions that might improve it:
//
// Consider adding error handling for the entries.get() call in the initState() method, as it may throw an exception if the collection does not exist or if the user does not have permission to access it.
// It's a good practice to separate data retrieval and UI rendering, so you might want to move the logic for retrieving and processing data into a separate method.
// You can use the fromSnapshot() constructor of the Entries class to simplify the creation of the list of entries data.
// Here's an updated version of your code that incorporates these suggestions:

import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LineChart extends StatefulWidget {
  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  late List<charts.Series<Entries, DateTime>> _seriesData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getData();

    print("In InitState");
  }

  Future<void> _getData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('entries').get();
      final entriesData = snapshot.docs.map((doc) => Entries.fromSnapshot(doc)).toList();

      // test for data
      print("In getData called in InitState Function");
      print(snapshot);
      print(entriesData);

      setState(() {
        _seriesData = [
          charts.Series(
            data: entriesData,
            domainFn: (entry, _) => entry.logDate,
            measureFn: (entry, _) => entry.quantity,
            id: 'Plastics',
          )
        ];
        _loading = false;
        print("loading set to false");
      });
    } catch (e) {
      // handle error
    }
  }

  @override
  Widget build(BuildContext context) {
// define vars here for use in build...

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Single Use Plastics - Chart'), //- $location'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Container(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                //  : charts.LineChart(_seriesData, animate: true), // chat GPT suggestion
                : charts.LineChart(_seriesData.cast<charts.Series<dynamic, num>>(),
                    animate: true),
          ),
        ),
      ),
    );
  }
}

class Entries {
  final DateTime logDate;
  final int quantity;

  Entries(this.logDate, this.quantity);

  // factory example - Class instance but does not create the class every time??
  factory Entries.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final title = data['title'] as String;
    final content = data['content'] as String;
    return Entries(title as DateTime, content as int);
  }

  /*factory Entries.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data();

    if (data == true) {
      return Entries(data['logDate'].toDate(), data['quantity'].toInt());
    }
    DateTime logDate = "01/01/2020" as DateTime;
    int quantity = 10;
    return Entries(logDate, quantity);
  }*/
} //end
