class Expense{
  Expense(this.value, this.date, this.categories, [this.isRecurrent = false]);

  double value;
  DateTime date;
  String categories;
  bool isRecurrent;
}