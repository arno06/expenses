import 'expense.dart';
import 'package:observable/observable.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Settings extends Object with ChangeNotifier{
  Settings(){
    _loadData();
  }

  static const String FILE = "data.json";

  bool _opened = false;

  ExpensesData _expensesData;

  Future<Expense> addExpense(double pValue, DateTime pDate, String pCategories) async{
    Expense exp = new Expense(pValue, pDate, pCategories);
    this._expensesData.expenses.add(exp);
    await _saveExpensesData();
    return exp;
  }

  Future<Null> removeExpense(Expense pExpense) async{
    _expensesData.expenses.remove(pExpense);
    notifyChange(const ChangeRecord());
    _saveExpensesData();
  }

  Future<ExpensesData> get expensesData async{

    if(_opened) {
      return _expensesData;
    }
   await _loadData();
    return _expensesData;
  }

  Future<Null> _saveExpensesData() async{
    File localFile = await _getLocalFile();
    Map map = _expensesData.toMap();
    await localFile.writeAsString(JSON.encode(map));
    notifyChange(const ChangeRecord());
  }

  Future<File> _getLocalFile() async{
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File(dir+'/'+Settings.FILE);
  }

  Future<Null> _loadData() async{
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

  int get salary{
    return _expensesData.salary;
  }

  set salary(int pValue){
    _expensesData.salary = pValue;
    _saveExpensesData();
  }

  bool get displaySalary{
    if(_expensesData == null)
      return false;
    return _expensesData.displaySalary;
  }

  set displaySalary(bool pValue){
    _expensesData.displaySalary = pValue;
    _saveExpensesData();
  }

  int get salaryDay{
    return _expensesData.salaryDay;
  }

  set salaryDay(int pValue){
    _expensesData.salaryDay = pValue;
    _saveExpensesData();
  }

  List<Expense> get expenses{
    return _expensesData.expenses;
  }
}

class ExpensesData{

  bool displaySalary = true;
  int salary = 2897;
  int salaryDay = 27;
  List<Expense> expenses = <Expense>[];

  void reset(){
    salary = 0;
    expenses = [];
  }

  void fromMap(Map pMap){
    if(pMap.containsKey('salary')){
      salary = pMap['salary'];
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

    if(pMap.containsKey("displaySalary"))
      displaySalary = pMap["displaySalary"];

    if(pMap.containsKey("salaryDay"))
      salaryDay = pMap["salaryDay"];
  }

  Map toMap(){
    Map data = new Map();

    data['salary'] = salary;
    data['displaySalary'] = displaySalary;
    data['salaryDay'] = salaryDay;

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