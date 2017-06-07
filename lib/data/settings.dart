import 'expense.dart';
import 'package:observable/observable.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Settings extends Object with ChangeNotifier{

  static const String FILE = "data.json";

  bool _opened = false;

  ExpensesData _expensesData;

  Future<Expense> addExpense(double pValue, DateTime pDate, String pCategories) async{
    Expense exp = new Expense(pValue, pDate, pCategories);
    this._expensesData.expenses.add(exp);
    notifyChange(const ChangeRecord());
    await _saveExpensesData();
    return exp;
  }

  Future<ExpensesData> get expensesData async{
    if(!_opened){
      _expensesData = new ExpensesData();
      try{

        File file = await _getLocalFile();

        String content = await file.readAsString();

        Map data = JSON.decode(content);
        _expensesData.fromMap(data);

      } on FileSystemException{
        print('Settings.getExpensesData::unable to get File data');
      }

      _opened = true;
    }
    return _expensesData;
  }

  Future<Null> _saveExpensesData() async{
    File localFile = await _getLocalFile();
    Map map = _expensesData.toMap();
    print(map);
    print(JSON.encode(map));
    await localFile.writeAsString(JSON.encode(_expensesData.toMap()));
  }

  Future<File> _getLocalFile() async{
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File(dir+'/'+Settings.FILE);
  }

}

class ExpensesData{

  int salary = 2897;
  DateTime startDate = new DateTime(2017, 5, 27);
  DateTime endDate = new DateTime(2017, 6, 27);
  List<Expense> expenses = <Expense>[
    new Expense(9.50, new DateTime(2017, 5, 28), "manger/pro/subway"),
    new Expense(9.50, new DateTime(2017, 5, 29), "manger/pro/subway"),
    new Expense(9.50, new DateTime(2017, 5, 30), "manger/pro/subway")
  ];

  void fromMap(Map pMap){
    if(pMap.containsKey('salary')){
      salary = pMap['salary'];
    }

    if(pMap.containsKey('startDate')){
      startDate = DateTime.parse(pMap['startDate']);
    }

    if(pMap.containsKey('endDate')){
      endDate = DateTime.parse(pMap['endDate']);
    }

    if(pMap.containsKey('expenses') && pMap['expenses'].length > 0){
      List<Expense> expenses = [];
      Map map;
      Expense exp;
      for(var i = 0, max = pMap['expenses'].length; i<max; i++){
        map = JSON.decode(pMap['expenses'][i]);
        exp = new Expense(map['value'], DateTime.parse(map['date']), map['categories']);
        expenses.add(exp);
      }
      this.expenses = expenses;
    }
  }

  Map toMap(){
    Map data = new Map();

    data['salary'] = salary;
    data['startDate'] = startDate.toString();
    data['endDate'] = startDate.toString();

    List<String> expenses = [];

    Expense exp;
    Map map;
    for(var i = 0, max = this.expenses.length; i<max; i++){
      exp = this.expenses[i];
      map = new Map();
      map['value'] = exp.value;
      map['date'] = exp.date.toString();
      map['categories'] = exp.categories;
      expenses.add(JSON.encode(map));
    }

    data['expenses'] = expenses;

    return data;
  }
}