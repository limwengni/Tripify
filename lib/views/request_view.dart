import 'package:flutter/material.dart';

class RequestView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Requests"),
      ),
      body: Center(
        child: Text("Request Services!"),
      ),
    );
  }
}
