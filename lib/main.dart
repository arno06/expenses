
import 'package:flutter/material.dart';

import 'package:expenses/widgets/ExpenseFormWidget.dart';
import 'package:expenses/widgets/HomeWidget.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expenses',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: <String, WidgetBuilder>{
        '/':  (BuildContext context) => new HomeWidget(),
        '/add':  (BuildContext context) => new ExpenseFormWidget(),
      }
    );
  }
}