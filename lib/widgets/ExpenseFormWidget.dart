import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'package:intl/intl.dart';

class ExpenseFormWidget extends StatefulWidget{
  const ExpenseFormWidget({Key key}):super(key:key);

  @override
  ExpenseFormState createState() => new ExpenseFormState();
}

class Expense
{
  double value = 0.0;
  String categories = "";
  DateTime date;
}

class ExpenseFormState extends State<ExpenseFormWidget>{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  DateTime _selectedDate = new DateTime.now();
  double _value;
  String _categories;

  String _validateValue(String pValue){
    pValue = pValue.trim();
    if(pValue.length == 0)
      return "Veuillez saisir le montant de la dépense";
    _value = double.parse(pValue);
    return null;
  }

  String _validateCategories(String pValue){
    _categories = pValue.trim();
    if(_categories.length == 0)
      return "Veuillez saisir au moins une catégorie";
    return null;
  }

  _postExpense() async{

    final FormState form = _formKey.currentState;

    if(form.validate()){
      var formatter = new DateFormat("yyyy-MM-dd");
      String url = 'https://api.arnaud-nicolas.fr/expenses/';
      var client = createHttpClient();
      var response  = await client.post(url, body:{"data":'[{"value_expense":'+_value.toString()+', "categories_expense":"'+_categories+'", "date_expense":"'+formatter.format(_selectedDate)+'"}]'});

      var b = JSON.decode(response.body);

      var icon;
      var message;
      if(b.containsKey("response")){
        icon = Icons.mood;
        message = "Dépense enregistrée";
      }
      else{
        icon = Icons.sentiment_neutral;
        message = "Une erreur est apparue lors de l'enregistrement.";
      }
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: new Row(
            children: <Widget>[
              new Icon(icon),
              new Text(message)
            ]
          ),
          backgroundColor: Colors.green
      ));
    }
    else{

    }

  }

  @override
  Widget build(BuildContext pContext){
    return new Scaffold(
        key:_scaffoldKey,
        appBar: new AppBar(
            title:const Text("Ajouter une dépense"),
            actions: <Widget>[
              new IconButton(icon: new Icon(Icons.check), onPressed:_postExpense)
            ]
        ),
        body:new Form(
            key:_formKey,
            child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal:16.0),
                children: <Widget>[
                  new TextFormField(
                      decoration:new InputDecoration(
                          icon:const Icon(Icons.euro_symbol),
                          hintText: "Combien avez-vous dépensé?",
                          labelText: "Dépense"
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateValue
                  ),
                  new _DatePicker(
                      labelText: "Date",
                      dateValue: _selectedDate,
                      dateChanged: (DateTime pValue){
                        setState((){
                          _selectedDate = pValue;
                        });
                      }
                  ),
                  new TextFormField(
                      decoration: new InputDecoration(
                          icon:const Icon(Icons.assignment),
                          hintText: "Assigner une catégorie de dépense",
                          labelText: "Catégorie"
                      ),
                      validator: _validateCategories
                  )
                ]
            )
        )
    );
  }
}

class _DatePicker extends StatelessWidget{
  const _DatePicker({
    Key key,
    this.labelText,
    this.dateValue,
    this.dateChanged
  }):super(key:key);

  final String labelText;
  final DateTime dateValue;
  final ValueChanged<DateTime> dateChanged;

  @override
  Widget build(BuildContext pContext){
    final TextStyle textStyle = Theme.of(pContext).textTheme.title;
    return new Row(
        children:<Widget>[
          new Container(
              margin:const EdgeInsets.only(right:11.0, left:12.0, top:10.0),
              child:new Icon(Icons.date_range)
          ),
          new Expanded(
              child: new InkWell(
                  onTap:(){_showDatePicker(pContext);},
                  child:new InputDecorator(
                      decoration: new InputDecoration(labelText: labelText),
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new Text(new DateFormat.yMMMd().format(dateValue), style:textStyle),
                            new Icon(Icons.arrow_drop_down, color:Theme.of(pContext).brightness == Brightness.light ? Colors.grey.shade700: Colors.white70)
                          ]
                      )
                  )
              )
          )]
    );
  }

  Future<Null> _showDatePicker(BuildContext pContext) async{
    final DateTime picked = await showDatePicker(
        context: pContext,
        initialDate: dateValue,
        firstDate: new DateTime(2015, 8),
        lastDate: new DateTime(2101));

    if(picked != null && picked != dateValue)
      dateChanged(picked);
  }
}