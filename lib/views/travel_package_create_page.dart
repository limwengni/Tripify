import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class TravelPackageCreatePage extends StatefulWidget{
  const TravelPackageCreatePage({super.key});

  @override
  _TravelPackageCreatePageState createState() => _TravelPackageCreatePageState();

}

class _TravelPackageCreatePageState extends State<TravelPackageCreatePage> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: FormBuilderTextField(
        name: 'text',
        onChanged: (val) {
            print(val); // Print the text value write into TextField
        },),
    );
  }

}