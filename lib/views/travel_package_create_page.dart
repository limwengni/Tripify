import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class TravelPackageCreatePage extends StatefulWidget {
  const TravelPackageCreatePage({super.key});

  @override
  _TravelPackageCreatePageState createState() =>
      _TravelPackageCreatePageState();
}

class _TravelPackageCreatePageState extends State<TravelPackageCreatePage> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'travel package name',
                    decoration:
                        InputDecoration(labelText: 'Travel Package Name'),
                    onChanged: (val) {
                      print(val); // Print the text value written into TextField
                    },
                  ),
                  const SizedBox(height: 10),
                  FormBuilderDateRangePicker(
                    name: 'travel date',
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(
                      Duration(days: 5 * 365),
                    ),
                    decoration: InputDecoration(labelText: 'Travel Date'),
                  ),
                  const SizedBox(height: 10),
                  FormBuilderTextField(
                    name: 'quantity',
                    decoration:
                        InputDecoration(labelText: 'Quantity Available'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      print('Quantity: $val'); // Print the quantity
                    },
                  ),
                  const SizedBox(height: 10),
                  FormBuilderTextField(
                    name: 'price',
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      print('Price: $val'); // Print the price
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    // Make this Expanded to fill the remaining space
                    child: FormBuilderTextField(
                      name: 'itinerary',
                      decoration: InputDecoration(
                        labelText: 'Itinerary',
                        // floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      maxLines: null,
                      onChanged: (val) {
                        print(
                            val); // Print the text value written into TextField
                      },
                    ),
                  ),                  const SizedBox(height: 10),

                ],
              ),
            ),
          ),
          MaterialButton(
            padding: EdgeInsets.all(15),
            minWidth: double.infinity,
            color: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              // Validate and save the form values
              _formKey.currentState?.saveAndValidate();
              debugPrint(_formKey.currentState?.value.toString());

              // On another side, can access all field values without saving form with instantValues
              _formKey.currentState?.validate();
              debugPrint(_formKey.currentState?.instantValue.toString());
            },
            child: const Text('On Shelves'),
          ),
          const SizedBox(height: 10), // Optional spacing below the button
        ],
      ),
    );
  }
}
