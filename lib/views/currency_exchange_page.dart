import 'package:flutter/material.dart';

class CurrencyExchangePage extends StatefulWidget {
  const CurrencyExchangePage({super.key});

  @override
  _CurrencyExchangePageState createState() => _CurrencyExchangePageState();
}

class _CurrencyExchangePageState extends State<CurrencyExchangePage> {
  String? selectedCurrency; // Variable to hold the selected currency

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    DropdownButton<String>(
                      value: selectedCurrency,
                      items: [
                        DropdownMenuItem(
                          value: 'USD',
                          child: Text('USD'),
                        ),
                        DropdownMenuItem(
                          value: 'MYR',
                          child: Text('MYR'),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCurrency =
                              newValue; // Update the selected currency
                        });
                      },
                      hint: Text('Select an option'),
                    ),
                    SizedBox(height: 10),
                    TextField(),
                  ],
                ),
              ),
            ),
            Transform.rotate(
              angle: 90 *
                  3.1415926535897932 /
                  180, // Convert 90 degrees to radians
              child: Icon(
                Icons.compare_arrows_sharp,
                size: 30,
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    DropdownButton<String>(
                      value: selectedCurrency,
                      items: [
                        DropdownMenuItem(
                          value: 'USD',
                          child: Text('USD'),
                        ),
                        DropdownMenuItem(
                          value: 'MYR',
                          child: Text('MYR'),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCurrency =
                              newValue; // Update the selected currency
                        });
                      },
                      hint: Text('Select an option'),
                    ),
                    SizedBox(height: 10),
                    TextField(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Text('Company Name'),
                    Spacer(),
                    Text('Rate 1'),
                    Text('Rate 2')
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
