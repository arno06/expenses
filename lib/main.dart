
import 'dart:async';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';

import 'package:expenses/utils/Dictionary.dart';
import 'package:expenses/data/settings.dart';
import 'package:expenses/widgets/ExpenseFormWidget.dart';
import 'package:expenses/widgets/HomeWidget.dart';
import 'package:expenses/widgets/ExpensesWidget.dart';
import 'package:expenses/widgets/SettingsWidget.dart';
import 'package:expenses/widgets/ChartsWidget.dart';
import 'package:expenses/widgets/MapEditorWidget.dart';

Future<Null> main() async {
  initializeDateFormatting('fr_FR');
  await Dictionary.setLocal('fr_FR');
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {


  Settings? settings;

  MyApp(){
    this.settings = new Settings();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expenses',
      theme: new ThemeData(
        primarySwatch: Colors.cyan,
      ),
      routes: <String, WidgetBuilder>{
        '/':  (BuildContext context) => new HomeWidget(settings:this.settings!),
        '/add':  (BuildContext context) => new ExpenseFormWidget(settings:this.settings!),
        '/expenses': (BuildContext context) => new ExpensesWidget(settings:this.settings!),
        '/settings': (BuildContext context) => new SettingsWidget(settings:this.settings!),
        '/charts': (BuildContext context) => new ChartsWidget(settings:this.settings!),
        '/categories/edit': (BuildContext context) => new MapEditorWidget(settings:this.settings!),
      }
    );
  }
}