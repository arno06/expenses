import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:expenses/data/settings.dart';
import 'package:expenses/data/expense.dart';
import 'package:expenses/utils/Dictionary.dart';

class ExpensesWidget extends StatefulWidget{

  ExpensesWidget({this.settings});

  final Settings? settings;

  @override
  _ExpensesWidgetState createState() => new _ExpensesWidgetState(this.settings!);
}

class _ExpensesWidgetState extends State<ExpensesWidget>{
  _ExpensesWidgetState(this.settings){
    this.expenses = this.settings.getExpenses((new DateTime.now().month));
    this.expenses.sort((Expense a, Expense b){
      return a.date.compareTo(b.date);
    });
  }

  final Settings settings;

  List<Expense> expenses = [];

  Widget buildItem(Expense pExpense){
    ThemeData theme = Theme.of(context);
    DateFormat format = new DateFormat.yMMMd("fr_FR");
    String dateDetail = format.format(pExpense.date);
    if(pExpense.isRecurrent){
      dateDetail = Dictionary.term("expenses.recurrent_expense_date");
      dateDetail = dateDetail.replaceAll("%day", pExpense.date.day.toString());
    }
    return new Dismissible(
      direction: DismissDirection.endToStart,
      background: new Container(
        color:theme.primaryColor,
        child: const ListTile(
          trailing: const Icon(Icons.delete, color:Colors.white, size: 36.0,),
        ),
      ),
      onDismissed: (DismissDirection pDirection){
        settings.removeExpense(pExpense);
      },
      key: new ObjectKey(pExpense),
      child: new Container(
        decoration: new BoxDecoration(
          color:theme.canvasColor,
          border: new Border(bottom: new BorderSide(color:theme.dividerColor))
        ),
        child: new ListTile(
          title: new Text(pExpense.value.toString()+"€"),
          subtitle: new Text(pExpense.categories),
          trailing: new Text(dateDetail),
        )
      )
    );
  }

  @override
  Widget build(BuildContext pContext){

    Widget body;

    if(this.expenses.length>0){
      body = new ListView(
        children: this.expenses.map(buildItem).toList(),
      );
    }else{
      body = new Center(
        child:new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 10.0),
              child: new Icon(Icons.sentiment_very_satisfied, color: Colors.grey,),
            ),
            new Text(Dictionary.term("expenses.empty_list"), style: new TextStyle(color: Colors.grey),)
          ],
        ),
      );
    }


    return new Scaffold(
      appBar: new AppBar(
        title: Dictionary.localizedText("expenses.title"),
      ),
      body: body,
    );
  }
}