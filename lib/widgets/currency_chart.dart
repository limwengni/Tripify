import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripify/view_models/fixer_api_service.dart'; // For date formatting

class CurrencyChart extends StatefulWidget {
  final String baseCurrency;
  final String symbols;

  const CurrencyChart(
      {super.key, required this.baseCurrency, required this.symbols});

  @override
  State<CurrencyChart> createState() => _CurrencyChartState();
}

class _CurrencyChartState extends State<CurrencyChart> {
  final FixerApiService apiService = FixerApiService();

  double? lowestRate;
  double? highestRate;
  double? gap;
  double? position1;
  double? position2;
  double? position3;
  double? middleRate;

  List<Color> gradientColors = [
    Colors.black,
    Colors.blue,
  ];

  bool showAvg = false;

  List<DateTime> months = [];
  List<Map<String, dynamic>> rateList = [];

  @override
  void initState() {
    super.initState();
    DateTime currentDate = DateTime.now();
    months = List.generate(
      12,
      (index) => DateTime(
        currentDate.year,
        (currentDate.month + index) % 12 + 1,
      ),
    );

    test();
  }

  void test() async {
    DateTime currentDate = DateTime.now();

    // Initialize a list to hold the past 12 months' dates
    List<String> past12MonthsDates = [];

    for (int i = 0; i < 12; i++) {
      // Subtract 'i' months from the current date
      DateTime pastDate = DateTime(
        currentDate.year,
        currentDate.month - i,
        1, // Start with the first day of the month
      );

      // Adjust to the same day or the last valid day of the month
      int targetDay = currentDate.day;
      int lastDayOfMonth = DateTime(pastDate.year, pastDate.month + 1, 0).day;

      pastDate = DateTime(
        pastDate.year,
        pastDate.month,
        targetDay > lastDayOfMonth ? lastDayOfMonth : targetDay,
      );

      // Format the date as yyyy-MM-dd
      String formattedDate = DateFormat('yyyy-MM-dd').format(pastDate);
      // Add the formatted date to the list
      past12MonthsDates.add(formattedDate);
    }

    for (int i = 0; i < past12MonthsDates.length; i++) {
      Map<String, dynamic> rate;
      rate = await apiService.getRatesForDate(
          widget.symbols, widget.baseCurrency, past12MonthsDates[i]);
      rateList.add(rate);
      print(rateList.length);
    }

   for (int i = 0; i < rateList.length; i++) {
      print('Rate ${i + 1}: ${rateList[i]['rates'][widget.baseCurrency].toString()}');
      if (lowestRate == null && highestRate == null) {
        lowestRate = rateList[i]['rates'][widget.baseCurrency];
        highestRate = rateList[i]['rates'][widget.baseCurrency];
      } else if (lowestRate! > rateList[i]['rates'][widget.baseCurrency]) {
        lowestRate = rateList[i]['rates'][widget.baseCurrency];
      } else if (highestRate! < rateList[i]['rates'][widget.baseCurrency]) {
        highestRate = rateList[i]['rates'][widget.baseCurrency];
      }
    }
    gap = (highestRate! - lowestRate!) / 4;

    setState(() {
      middleRate = lowestRate! + (highestRate! - lowestRate!) / 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
          child: SizedBox(
            width: 60,
            height: 34,
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Color.fromARGB(255, 0, 140, 255), // Blue color
                ),
              ),
              onPressed: () {
                setState(() {
                  showAvg = !showAvg;
                });
              },
              child: Text(
                'avg',
                style: TextStyle(
                  fontSize: 12,
                  color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
                ),
              ),
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              showAvg ? avgData() : mainData(),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    if (value.toInt() >= 0 && value.toInt() < months.length) {
      text = DateFormat('MMM').format(months[value.toInt()]);
    } else {
      text = '';
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = (lowestRate?.toStringAsFixed(2)) ?? '0';
        break;
      case 3:
        text = (middleRate?.toStringAsFixed(2)) ?? '1';
        break;
      case 5:
        text = (highestRate?.toStringAsFixed(2)) ?? '0';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.black,
            strokeWidth: 0.5,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.black,
            strokeWidth: 0.5,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11, // 12 months (0-based index)
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: rateList.length == 12
              ? List.generate(rateList.length, (index) {
                  // Assuming the 'MYR' rate exists in the response
                  return FlSpot(
                    index.toDouble(),
                    (rateList[index]['rates'][widget.baseCurrency]?.toDouble() -lowestRate)/gap+1 ?? 0,
                  );
                })
              : [], //
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color.fromARGB(255, 60, 81, 98),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          left: BorderSide(
              color: const Color(0xff37434d), width: 1), // Left border
          bottom: BorderSide(
              color: const Color(0xff37434d), width: 1), // Bottom border
          right: BorderSide.none, // No right border
          top: BorderSide.none, // No top border
        ),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2, 3.44),
            FlSpot(4, 3.44),
            FlSpot(6, 3.44),
            FlSpot(8, 3.44),
            FlSpot(10, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors:
                gradientColors.map((color) => color.withOpacity(0.7)).toList(),
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.1))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}