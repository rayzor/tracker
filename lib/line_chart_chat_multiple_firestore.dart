// To retrieve data from Firestore, you would need to update
// the _createSampleData function in the DateTimeComboLinePointChart class.
// Instead of creating sample hard-coded data,
// you would need to make a call to Firestore to fetch the data you need
// and then use that data to create your TimeSeriesSales objects.
// Here's an example of how you can do this:
//
// dart

import 'package:charts_flutter_new/flutter.dart';// as charts;
import 'package:flutter/material.dart';

class DateTimeComboLinePointChart extends StatelessWidget {
  final List<Series> seriesList;
  final bool animate;

  DateTimeComboLinePointChart(this.seriesList, {required this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory DateTimeComboLinePointChart.withData() {
    return DateTimeComboLinePointChart(
      // _createSampleData(),
      _fetchData() as List<Series>, // get data from Firestore
      // Disable animations for image tests.
      animate: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return TimeSeriesChart(
      seriesList,
      animate: animate,
      // Configure the default renderer as a line renderer. This will be used
      // for any series that does not define a rendererIdKey.
      //
      // This is the default configuration, but is shown here for  illustration.
      defaultRenderer: LineRendererConfig(),
      // Custom renderer configuration for the point series.
      customSeriesRenderers: [
        PointRendererConfig(
          // ID used to link series to this renderer.
            customRendererId: 'customPoint')
      ],
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const LocalDateTimeFactory(),
    );
  }


static Future<List<Series<TimeSeriesSales, DateTime>>> _fetchData() async {
final data = await FirebaseFirestore.instance
    .collection('entries')
.orderBy('logDate')
.get();

final desktopSalesData = <TimeSeriesSales>[];
final tableSalesData = <TimeSeriesSales>[];
final mobileSalesData = <TimeSeriesSales>[];

for (final doc in data.docs) {
final sales = TimeSeriesSales(
doc['time'].toDate(),
doc['sales'],
);

switch (doc['platform']) {
case 'Desktop':
desktopSalesData.add(sales);
break;
case 'Tablet':
tableSalesData.add(sales);
break;
case 'Mobile':
mobileSalesData.add(sales);
break;
}
}

return [
charts.Series<TimeSeriesSales, DateTime>(
id: 'Desktop',
colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
domainFn: (TimeSeriesSales sales, _) => sales.time,
measureFn: (TimeSeriesSales sales, _) => sales.sales,
data: desktopSalesData,
),
charts.Series<TimeSeriesSales, DateTime>(
id: 'Tablet',
colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
domainFn: (TimeSeriesSales sales, _) => sales.time,
measureFn: (TimeSeriesSales sales, _) => sales.sales,
data: tableSalesData,
),
charts.Series<TimeSeriesSales, DateTime>(
id: 'Mobile',
colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
domainFn: (TimeSeriesSales sales, _) => sales.time,
measureFn: (TimeSeriesSales sales, _) => sales.sales,
data: mobileSalesData)
// Configure our custom point renderer for this series.
..setAttribute(charts.rendererIdKey, 'customPoint'),
];
}



/// ChatGPT cpmment at end of code
/// This function will fetch the data from Firestore
/// and create TimeSeriesSales objects based on the data retrieved.
/// You can then pass the resulting list of charts.Series<TimeSeriesSales,
/// DateTime> to the DateTimeComboLinePointChart constructor
/// to display the chart with the retrieved data.
///

/////////// Original 2 line chart from Plugin site
//Could you review this dart Flutter code and rewrite it to get the data from Firestore /// Example of a combo time series chart with two series rendered as lines, and
/// a third rendered as points along the top line with a different color.
///
/// This example demonstrates a method for drawing points along a line using a
/// different color from the main series color. The line renderer supports
/// drawing points with the "includePoints" option, but those points will share
/// the same color as the line.
import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:flutter/material.dart';

class DateTimeComboLinePointChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  DateTimeComboLinePointChart(this.seriesList, {this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory DateTimeComboLinePointChart.withSampleData() {
    return new DateTimeComboLinePointChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      // Configure the default renderer as a line renderer. This will be used
      // for any series that does not define a rendererIdKey.
      //
      // This is the default configuration, but is shown here for  illustration.
      defaultRenderer: new charts.LineRendererConfig(),
      // Custom renderer configuration for the point series.
      customSeriesRenderers: [
        new charts.PointRendererConfig(
          // ID used to link series to this renderer.
            customRendererId: 'customPoint')
      ],
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData() {
    final desktopSalesData = [
      new TimeSeriesSales(new DateTime(2017, 9, 19), 5),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 25),
      new TimeSeriesSales(new DateTime(2017, 10, 3), 100),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 75),
    ];

    final tableSalesData = [
      new TimeSeriesSales(new DateTime(2017, 9, 19), 10),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 50),
      new TimeSeriesSales(new DateTime(2017, 10, 3), 200),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 150),
    ];

    final mobileSalesData = [
      new TimeSeriesSales(new DateTime(2017, 9, 19), 10),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 50),
      new TimeSeriesSales(new DateTime(2017, 10, 3), 200),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 150),
    ];

    return [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Desktop',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: desktopSalesData,
      ),
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Tablet',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: tableSalesData,
      ),
      new charts.Series<TimeSeriesSales, DateTime>(
          id: 'Mobile',
          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
          domainFn: (TimeSeriesSales sales, _) => sales.time,
          measureFn: (TimeSeriesSales sales, _) => sales.sales,
          data: mobileSalesData)
      // Configure our custom point renderer for this series.
        ..setAttribute(charts.rendererIdKey, 'customPoint'),
    ];
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
