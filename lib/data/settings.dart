import 'expense.dart';
import 'package:observable/observable.dart';

class Settings extends Object with ChangeNotifier{
  int salary = 2897;
  DateTime startDate = new DateTime(2017, 5, 27);
  DateTime endDate = new DateTime(2017, 6, 27);
  List<Expense> expenses = <Expense>[
    new Expense(9.50, new DateTime(2017, 5, 28), "manger/pro/subway"),
    new Expense(9.50, new DateTime(2017, 5, 29), "manger/pro/subway"),
    new Expense(9.50, new DateTime(2017, 5, 30), "manger/pro/subway")
  ];

  Expense addExpense(double pValue, DateTime pDate, String pCategories){
    Expense exp = new Expense(pValue, pDate, pCategories);
    this.expenses.add(exp);
    notifyChange(const ChangeRecord());
    return exp;
  }
}