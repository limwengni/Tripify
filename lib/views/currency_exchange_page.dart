import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tripify/view_models/fixer_api_service.dart';
import 'package:tripify/views/exchange_rate_chart.dart';
import 'package:tripify/widgets/currency_chart.dart';

class CurrencyExchangePage extends StatefulWidget {
  const CurrencyExchangePage({super.key});

  @override
  _CurrencyExchangePageState createState() => _CurrencyExchangePageState();
}

class _CurrencyExchangePageState extends State<CurrencyExchangePage> {
  final FixerApiService apiService = FixerApiService();
  Map<String, String>? currencies;
  String? selectedCurrencyFrom;
  String? selectedCurrencyTo;
  bool isLoading = true;
  String? amountConvertedTo;
  String? amountConvertedFrom;

  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController _amountConvertedToController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  void _fetchCurrencies() async {
    try {
      final data = await apiService.getAvailableCurrencies();
      setState(() {
        currencies = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _amountConvertedToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currencies == null
              ? const Center(child: Text('Failed to load currencies'))
              : SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FormBuilder(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Card for "From Currency"
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    DropdownButton<String>(
                                      value: selectedCurrencyFrom,
                                      items: currencies!.entries.map((entry) {
                                        return DropdownMenuItem<String>(
                                          value: entry.key,
                                          child: Text(
                                              '${entry.key} - ${entry.value}'),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedCurrencyFrom = newValue;
                                        });
                                      },
                                      hint: const Text('Select From Currency'),
                                    ),
                                    const SizedBox(height: 10),
                                    FormBuilderTextField(
                                      initialValue: amountConvertedFrom ?? '0',
                                      name: 'amount_converted_from',
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Enter amount',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Exchange Icon
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                if (_formKey.currentState?.saveAndValidate() ??
                                    false) {
                                  final formValues =
                                      _formKey.currentState?.value;
                                  if (selectedCurrencyFrom != null &&
                                      selectedCurrencyTo != null) {
                                    final amountString = formValues?[
                                                'amount_converted_from'] !=
                                            null
                                        ? formValues!['amount_converted_from']
                                        : 0;

                                    final amount =
                                        double.tryParse(amountString) ?? 0.0;
                                    // Call the API to perform conversion
                                    final convertedAmount =
                                        await apiService.convert(
                                      selectedCurrencyFrom!,
                                      selectedCurrencyTo!,
                                      amount,
                                    );

                                    // Update the converted amount using the controller
                                    setState(() {
                                      _amountConvertedToController.text =
                                          convertedAmount.toString();
                                    });
                                  }
                                }
                              },
                              child: Container(
                                width: 50.0, // Set the width of the circle
                                height: 50.0, // Set the height of the circle
                                decoration: BoxDecoration(
                                  shape: BoxShape
                                      .circle, // Make the container circular
                                  color: Colors
                                      .blue, // Set the color of the button
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: Offset(
                                          0, 4), // Set the shadow's direction
                                      blurRadius:
                                          10, // Set the blur radius for the shadow
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.compare_arrows_sharp,
                                    color: Colors
                                        .white, // Icon color (white to contrast with the blue background)
                                    size: 30, // Icon size
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState
                                            ?.saveAndValidate() ??
                                        false) {
                                      final formValues =
                                          _formKey.currentState?.value;
                                      if (selectedCurrencyFrom != null &&
                                          selectedCurrencyTo != null) {
                                        final amountString = formValues?[
                                                    'amount_converted_from'] !=
                                                null
                                            ? formValues![
                                                'amount_converted_from']
                                            : 0;

                                        final amount =
                                            double.tryParse(amountString) ??
                                                0.0;
                                        // Call the API to perform conversion
                                        final convertedAmount =
                                            await apiService.convert(
                                          selectedCurrencyTo!,
                                          selectedCurrencyFrom!,
                                          amount,
                                        );

                                        // Update the converted amount using the controller
                                        setState(() {
                                          _amountConvertedToController.text =
                                              convertedAmount.toString();
                                        });
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Card for "To Currency"
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    DropdownButton<String>(
                                      value: selectedCurrencyTo,
                                      items: currencies!.entries.map((entry) {
                                        return DropdownMenuItem<String>(
                                          value: entry.key,
                                          child: Text(
                                              '${entry.key} - ${entry.value}'),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedCurrencyTo = newValue;
                                        });
                                      },
                                      hint: const Text('Select To Currency'),
                                    ),
                                    const SizedBox(height: 10),
                                    FormBuilderTextField(
                                      controller: _amountConvertedToController,
                                      name: 'amountConvertedTo',
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: '',
                                      ),
                                      readOnly: true,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            selectedCurrencyFrom != null &&
                                    selectedCurrencyTo != null
                                ? SizedBox(
                                    height: 300.0,
                                    child: CurrencyChart(
                                      key: ValueKey(selectedCurrencyFrom! +
                                          selectedCurrencyTo!),
                                      baseCurrency: selectedCurrencyTo!,
                                      symbols: selectedCurrencyFrom!,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
