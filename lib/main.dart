
import 'package:flutter/material.dart';

import 'package:expenses/widgets/ExpenseFormWidget.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Expenses',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new ExpenseFormWidget(),
    );
  }
}