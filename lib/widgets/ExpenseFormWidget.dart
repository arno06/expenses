import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'package:intl/intl.dart';

import 'HomeWidget.dart';
import 'package:expenses/data/expense.dart';
import 'package:expenses/data/settings.dart';


class ExpenseFormWidget extends StatefulWidget{
  const ExpenseFormWidget({Key key, this.settings}):super(key:key);

  final Settings settings;

  @override
  ExpenseFormState createState() => new ExpenseFormState(this.settings);
}

class ExpenseFormState extends State<ExpenseFormWidget>{

  ExpenseFormState(Settings this.settings);

  final Settings settings;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  DateTime _selectedDate = new DateTime.now();
  double _value;
  String _categories = "";
  bool _isRecurrent = false;

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
      settings.addExpense(_value, _selectedDate, _categories, _isRecurrent);
      Navigator.pop(this.context);
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
                  new ListTile(
                    leading:new Icon(Icons.update),
                    title: new Text("Dépense récurrente"),
                    trailing: new Checkbox(value: _isRecurrent, onChanged: (bool pValue){
                      setState((){
                        _isRecurrent = pValue;
                      });
                    }),
                    onTap: (){
                      setState((){
                        _isRecurrent = !_isRecurrent;
                      });
                    },
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
                  new _CategoryPicker(
                    labelText: "Catégorie",
                    categories:settings.categories,
                    value:_categories,
                    categoryChanged: (String pValue){
                      _categories = pValue;
                    },
                  ),
                ]
            )
        )
    );
  }
}

class _CategoryPicker extends StatelessWidget{
  _CategoryPicker({
    Key key,
    this.labelText,
    this.value,
    this.categories,
    this.categoryChanged
  }):super(key:key);

  List<Category> categories;
  String labelText;
  String value = "";
  ValueChanged<String> categoryChanged;

  List<Widget> categoryList(BuildContext pContext, List<Category> pBaseList, int pDeep, String pBase){
    if(pBase.isNotEmpty)
      pBase += "/";
    List<Widget> list = <Widget>[];
    pBaseList.forEach((Category cat){
      list.add(new _CategoryItem(label: cat.label, color:cat.color, deep:pDeep, onPressed: (){Navigator.pop(pContext, pBase+cat.label);}));
      if(cat.children.length > 0)
        list.addAll(categoryList(pContext, cat.children, pDeep+1, pBase+cat.label));
    });

    return list;
  }


  void showCategoriesDialog<T>(BuildContext pContext){

    List<Widget> items = categoryList(pContext, categories, 0, "");

    showDialog(
        context: pContext,
        child: new SimpleDialog(
          title: new Text("Sélectionner une catégorie"),
          children: items,
        )
    ).then<Null>((String pValue){
      if(pValue != null){
        categoryChanged(pValue);
      }
    });
  }

  @override
  Widget build(BuildContext pContext){
    final TextStyle textStyle = Theme.of(pContext).textTheme.title;
    return new Row(
      children: <Widget>[
        new Container(
            margin:const EdgeInsets.only(right:11.0, left:12.0, top:10.0),
            child:new Icon(Icons.assignment)
        ),
        new Expanded(
            child: new InkWell(
                onTap:(){showCategoriesDialog<String>(pContext);},
                child:new InputDecorator(
                    decoration: new InputDecoration(labelText: labelText),
                    child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Text(this.value, style:textStyle),
                          new Icon(Icons.arrow_drop_down, color:Theme.of(pContext).brightness == Brightness.light ? Colors.grey.shade700: Colors.white70)
                        ]
                    )
                )
            )
        )],
    );
  }
}

class _CategoryItem extends StatelessWidget{

  _CategoryItem({
    Key key,
    this.label,
    this.color,
    this.deep,
    this.onPressed
}):super(key:key);

  String label;
  Color color;
  int deep;
  VoidCallback onPressed;

  @override
  Widget build(BuildContext pContext){
    double marginLeft = 20.0 * this.deep;
    return new SimpleDialogOption(
      onPressed: onPressed,
      child: new Row(
        children: <Widget>[
          new Container(
            margin:new EdgeInsets.only(left:marginLeft),
            decoration: new BoxDecoration(border: new Border(left: new BorderSide(color:this.color, width: 5.0))),
            child: new Container(
              margin: const EdgeInsets.only(left:10.0),
              child: new Text(this.label),
            ),
          ),
        ],
      ),
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
                            new Text(new DateFormat.yMMMd("fr_FR").format(dateValue), style:textStyle),
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
      lastDate: new DateTime(2101),
    );

    if(picked != null && picked != dateValue)
      dateChanged(picked);
  }
}