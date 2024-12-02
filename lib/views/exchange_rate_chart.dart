import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tripify/widgets/currency_chart.dart';

class ChartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CurrencyChart(baseCurrency:  'MYR',symbols:  'USD')),
    );
  }
}