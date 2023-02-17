/// Example of a combo time series chart with two series rendered as lines, and
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

  DateTimeComboLinePointChart(this.seriesList, {required this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory DateTimeComboLinePointChart.withSampleData() {
    return DateTimeComboLinePointChart(
      _createSampleData(),

      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      // Configure the default renderer as a line renderer. This will be used
      // for any series that does not define a rendererIdKey.
      //
      // This is the default configuration, but is shown here for  illustration.
      defaultRenderer: charts.LineRendererConfig(),
      // Custom renderer configuration for the point series.
      customSeriesRenderers: [
        charts.PointRendererConfig(
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
      TimeSeriesSales(DateTime(2017, 9, 19), 5),
      TimeSeriesSales(DateTime(2017, 9, 26), 25),
      TimeSeriesSales(DateTime(2017, 10, 3), 100),
      TimeSeriesSales(DateTime(2017, 10, 10), 75),
    ];

    final tableSalesData = [
      TimeSeriesSales(DateTime(2017, 9, 19), 10),
      TimeSeriesSales(DateTime(2017, 9, 26), 50),
      TimeSeriesSales(DateTime(2017, 10, 3), 200),
      TimeSeriesSales(DateTime(2017, 10, 10), 150),
    ];

    final mobileSalesData = [
      TimeSeriesSales(DateTime(2017, 9, 19), 10),
      TimeSeriesSales(DateTime(2017, 9, 26), 50),
      TimeSeriesSales(DateTime(2017, 10, 3), 200),
      TimeSeriesSales(DateTime(2017, 10, 10), 150),
    ];

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
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
