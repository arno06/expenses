import 'dart:async';
import 'package:flutter/material.dart';
import 'package:expenses/data/settings.dart';
import 'package:expenses/utils/Dictionary.dart';

typedef void ActionItemCallback(String value, Category category);

class MapEditorWidget extends StatefulWidget{

  MapEditorWidget({this.settings});

  final Settings? settings;

  @override
  _MapEditorWidgetState createState() => new _MapEditorWidgetState(this.settings);
}

class _MapEditorWidgetState extends State<MapEditorWidget>{

  static const String ACTION_ADD = "add";
  static const String ACTION_EDIT = "edit";
  static const String ACTION_REMOVE = "remove";

  _MapEditorWidgetState(this.settings){
    categories = this.settings!.categories;
    setItems();
  }

  Settings? settings;
  List<Category>? categories;

  List<_MapExpansionItem>? items;

  Category? cat;

  void setItems(){
    items = categories?.map((Category value){
      return new _MapExpansionItem(category:value, actionHandler: this.itemCallBack);
    }).toList();
  }

  @override
  Widget build(BuildContext pContext){

    List<Widget> tree = [];

    items?.forEach((_MapExpansionItem items){
      tree.addAll(items.build(pContext, 0));
    });

    return new Scaffold(
      appBar: new AppBar(
        title: Dictionary.localizedText('categories.title'),
      ),
      body: new ListView(
        children: tree,
      )
    );
  }

  String? validateCategoryLabel(String? pValue){
    if(pValue!.isEmpty){
      return Dictionary.term("categories.dialog.name.error");
    }
    cat?.label = pValue;
    return null;
  }

  Future<Null> itemCallBack(String? pValue, Category? pCat) async{

    GlobalKey<FormState> formKey = new GlobalKey<FormState>();

    if(pValue == ACTION_ADD || pValue == ACTION_EDIT){
      cat = pValue==ACTION_ADD?new Category(Dictionary.term("categories.dialog.name.default_value"), Color.lerp(pCat?.color, Colors.white, 0.45)):new Category(pCat!.label, pCat.color);
      String dialogTitle = pValue==ACTION_ADD?Dictionary.term("categories.add_dialog.title"):Dictionary.term("categories.edit_dialog.title");
      String action = await showDialog(
        context: context,
        builder:(BuildContext pContext){
          return new AlertDialog(
            title: new Text(dialogTitle),
            content: new Form(
                key: formKey,
                child:
                new TextFormField(
                  validator: validateCategoryLabel,
                  decoration:new InputDecoration(
                    icon:const Icon(Icons.category),
                    labelText: Dictionary.term("categories.dialog.name.label"),
                  ),
                  controller: new TextEditingController(text:cat?.label),
                )
            ),
            actions: <Widget>[
              new TextButton(
                  onPressed: (){Navigator.pop(context, null);},
                  child: Dictionary.localizedText("categories.dialog.actions.cancel")
              ),
              new TextButton(
                  onPressed: (){Navigator.pop(context, "save");},
                  child: Dictionary.localizedText("categories.dialog.actions.save")
              ),
            ],
          );
        }
      );

      if(action == "save"){
        if(!formKey.currentState!.validate()){
          return;
        }
      }
    }

    walkTrough(List<Category>pCats){
      List<Category> cats = <Category>[];

      pCats.forEach((Category cat){

        var skip = false;

        var found = false;

        if(cat.compareTo(pCat!) == 1) {
          found = true;
          switch(pValue){
            case ACTION_ADD:
              cat.children.add(this.cat!);
              break;
            case ACTION_REMOVE:
              skip = true;
              break;
            case ACTION_EDIT:
              cat.label = this.cat!.label;
              cat.color = this.cat?.color;
              break;
          }
        }

        if(!found)
          cat.children = walkTrough(cat.children);

        if(!skip){
          cats.add(cat);
        }
      });

      return cats;
    }

    categories = walkTrough(categories!);

    settings?.categories = categories!;

    setState((){
      setItems();
    });
  }
}

class _MapExpansionItem{

  _MapExpansionItem({this.category, this.actionHandler}){
    this.category!.children.forEach((Category value){
      items.add(new _MapExpansionItem(category:value, actionHandler: this.actionHandler));
    });
  }

  ActionItemCallback? actionHandler;
  Category? category;
  bool isExpanded = false;
  List<_MapExpansionItem> items = [];

  List<Widget> build(BuildContext pContext, int pDeep){

    List<Widget> children = [];

    items.forEach((_MapExpansionItem item){
      children.addAll(item.build(pContext, pDeep+1));
    });

    double leftPadding = 20.0 + (25.0 * pDeep);
    double verticalPadding = 5.0;
    return [new Padding(
      padding: new EdgeInsets.only(left: leftPadding, top:verticalPadding, bottom:verticalPadding),
      child: new Row(
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(right:10.0),
            child: new CircleAvatar(backgroundColor: category?.color, radius: 10.0,),
          ),
          new Expanded(child: new Text(category!.label)),
          new PopupMenuButton(
            onSelected: (String pValue){
              actionHandler!(pValue, category!);
            },
            itemBuilder: (BuildContext pContext) => <PopupMenuEntry<String>>[
            new PopupMenuItem<String>(
              value: _MapEditorWidgetState.ACTION_ADD,
              child: new ListTile(
                leading: const Icon(Icons.add),
                title: Dictionary.localizedText("categories.submenu.add")
              )
            ),
            new PopupMenuItem<String>(
              value: _MapEditorWidgetState.ACTION_EDIT,
              child: new ListTile(
                leading: const Icon(Icons.edit),
                title: Dictionary.localizedText("categories.submenu.edit")
              )
            ),
            new PopupMenuItem<String>(
              value: _MapEditorWidgetState.ACTION_REMOVE,
              child: new ListTile(
                leading: const Icon(Icons.remove),
                title: Dictionary.localizedText("categories.submenu.remove")
              )
            )
          ])
        ],
      ),
    )]..addAll(children);
  }
}