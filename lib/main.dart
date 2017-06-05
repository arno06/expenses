
import 'package:flutter/material.dart';

import 'package:expenses/data/settings.dart';
import 'package:expenses/widgets/ExpenseFormWidget.dart';
import 'package:expenses/widgets/HomeWidget.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {

  Settings settings = new Settings();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expenses',
      theme: new ThemeData(
        primarySwatch: Colors.cyan,
      ),
      routes: <String, WidgetBuilder>{
        '/':  (BuildContext context) => new HomeWidget(settings:this.settings),
        '/add':  (BuildContext context) => new ExpenseFormWidget(settings:this.settings),
      }
    );
  }
}