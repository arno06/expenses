import 'dart:async';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:expenses/data/settings.dart';
import 'package:expenses/utils/Dictionary.dart';


class ExpenseFormWidget extends StatefulWidget{
  const ExpenseFormWidget({Key? key, this.settings}):super(key:key);

  final Settings? settings;

  @override
  ExpenseFormState createState() => new ExpenseFormState(this.settings!);
}

class ExpenseFormState extends State<ExpenseFormWidget>{

  ExpenseFormState(Settings this.settings);

  final Settings settings;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  DateTime _selectedDate = new DateTime.now();
  double? _value;
  String _categories = "";
  bool _isRecurrent = false;

  String? _validateValue(String? pValue){
    pValue = pValue!.trim();
    if(pValue.length == 0)
      return Dictionary.term("new_expense.expense.empty_error");
    _value = double.parse(pValue);
    return null;
  }

  _postExpense() async{
    final FormState form = _formKey.currentState!;
    if(form.validate()){
      settings.addExpense(_value!, _selectedDate, _categories, _isRecurrent);
      Navigator.pop(this.context);
    }
  }

  @override
  Widget build(BuildContext pContext){
    return new Scaffold(
        key:_scaffoldKey,
        appBar: new AppBar(
            title:Dictionary.localizedText("new_expense.title"),
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
                        hintText: Dictionary.term("new_expense.expense.hint"),
                        labelText: Dictionary.term("new_expense.expense.label"),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateValue
                  ),
                  new _CategoryPicker(
                    labelText: Dictionary.term("new_expense.category.label"),
                    categories:settings.categories,
                    value:_categories,
                    categoryChanged: (String? pValue){
                      _categories = pValue!;
                    },
                  ),
                  new _DatePicker(
                      labelText: Dictionary.term("new_expense.date.label"),
                      dateValue: _selectedDate,
                      dateChanged: (DateTime pValue){
                        setState((){
                          _selectedDate = pValue;
                        });
                      }
                  ),
                  new ListTile(
                    leading:new Icon(Icons.update),
                    dense: true,
                    title: Dictionary.localizedText("new_expense.recurrent_expense.label"),
                    trailing: new Checkbox(value: _isRecurrent, onChanged: (bool? pValue){
                      setState((){
                        _isRecurrent = pValue!;
                      });
                    }),
                    onTap: (){
                      setState((){
                        _isRecurrent = !_isRecurrent;
                      });
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
    Key? key,
    this.labelText,
    this.value,
    this.categories,
    this.categoryChanged
  }):super(key:key);

  List<Category>? categories;
  String? labelText;
  String? value = "";
  ValueChanged<String?>? categoryChanged;

  List<Widget> categoryList(BuildContext pContext, List<Category>? pBaseList, int pDeep, String pBase){
    if(pBase.isNotEmpty)
      pBase += "/";
    List<Widget> list = <Widget>[];
    pBaseList!.forEach((Category cat){
      list.add(new _CategoryItem(label: cat.label, color:cat.color, deep:pDeep, onPressed: (){Navigator.pop(pContext, pBase+cat.label);}));
      if(cat.children.length > 0)
        list.addAll(categoryList(pContext, cat.children, pDeep+1, pBase+cat.label));
    });

    return list;
  }


  void showCategoriesDialog<T>(BuildContext pContext){

    List<Widget> items = categoryList(pContext, categories, 0, "");

    showDialog<String>(
        context: pContext,
        builder:(BuildContext pContext){
          return new SimpleDialog(
            title: Dictionary.localizedText("new_expense.category.dialog_title"),
            children: items,
          );
        }
    ).then<void>((String? pValue){
      if(pValue != null){
        categoryChanged!(pValue);
      }
    });
  }

  @override
  Widget build(BuildContext pContext){
    final TextStyle textStyle = Theme.of(pContext).textTheme.headline6!;
    textStyle.apply(color:const Color(0xff555555));
    return new Row(
      children: <Widget>[
        new Container(
            margin:const EdgeInsets.only(right:11.0, left:12.0, top:10.0),
            child:new Icon(Icons.assignment, color: const Color(0xff777777),)
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
                          new Text(this.value!, style:textStyle),
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
    Key? key,
    this.label,
    this.color,
    this.deep,
    this.onPressed
}):super(key:key);

  String? label;
  Color? color;
  int? deep;
  VoidCallback? onPressed;

  @override
  Widget build(BuildContext pContext){
    double marginLeft = 20.0 * this.deep!;
    return new SimpleDialogOption(
      onPressed: onPressed,
      child: new Row(
        children: <Widget>[
          new Container(
            margin:new EdgeInsets.only(left:marginLeft),
            decoration: new BoxDecoration(border: new Border(left: new BorderSide(color:this.color!, width: 5.0))),
            child: new Container(
              margin: const EdgeInsets.only(left:10.0),
              child: new Text(this.label!),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePicker extends StatelessWidget{
  const _DatePicker({
    Key? key,
    this.labelText,
    this.dateValue,
    this.dateChanged
  }):super(key:key);

  final String? labelText;
  final DateTime? dateValue;
  final ValueChanged<DateTime>? dateChanged;

  @override
  Widget build(BuildContext pContext){
    final TextStyle textStyle = Theme.of(pContext).textTheme.headline6!;
    textStyle.apply(color: const Color(0xff555555));
    return new Row(
        children:<Widget>[
          new Container(
              margin:const EdgeInsets.only(right:11.0, left:12.0, top:10.0),
              child:new Icon(Icons.date_range, color:const Color(0xFF777777))
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
                            new Text(new DateFormat.yMMMd("fr_FR").format(dateValue!), style:textStyle),
                            new Icon(Icons.arrow_drop_down, color:Theme.of(pContext).brightness == Brightness.light ? Colors.grey.shade700: Colors.white70)
                          ]
                      )
                  )
              )
          )]
    );
  }

  Future<Null> _showDatePicker(BuildContext pContext) async{
    final DateTime? picked = await showDatePicker(
      context: pContext,
      initialDate: dateValue!,
      firstDate: new DateTime(2015, 8),
      lastDate: new DateTime(2101),
    );

    if(picked != null && picked != dateValue)
      dateChanged!(picked);
  }
}