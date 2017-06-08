
import 'package:flutter/material.dart';

import 'package:expenses/data/settings.dart';
import 'package:expenses/widgets/ExpenseFormWidget.dart';
import 'package:expenses/widgets/HomeWidget.dart';
import 'package:expenses/widgets/ExpensesWidget.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {

  MyApp(){
    initializeDateFormatting('fr_FR');
  }

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
        '/expenses': (BuildContext context) => new ExpensesWidget(settings:this.settings),
      }
    );
  }
}