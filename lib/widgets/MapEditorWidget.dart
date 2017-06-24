import 'package:flutter/material.dart';
import 'dart:async';
import 'package:expenses/data/settings.dart';

typedef void ActionItemCallback(String value, Category category);

class MapEditorWidget extends StatefulWidget{

  MapEditorWidget({this.settings});

  final Settings settings;

  @override
  _MapEditorWidgetState createState() => new _MapEditorWidgetState(this.settings);
}

class _MapEditorWidgetState extends State<MapEditorWidget>{
  _MapEditorWidgetState(this.settings){
    categories = this.settings.categories;
    setItems();
  }

  Settings settings;
  List<Category> categories;

  List<_MapExpansionItem> items;

  Category cat;

  void setItems(){
    items = categories.map((Category value){
      return new _MapExpansionItem(category:value, actionHandler: this.itemCallBack);
    }).toList();
  }

  @override
  Widget build(BuildContext pContext){

    List<Widget> tree = [];

    items.forEach((_MapExpansionItem items){
      tree.addAll(items.build(pContext, 0));
    });

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Gestion des catégories'),
      ),
      body: new ListView(
        children: tree,
      )
    );
  }

  String validateCategoryLabel(String pValue){
    if(pValue.isEmpty){
      return "Merci de préciser un nom de catégorie";
    }
    cat.label = pValue;
    return null;
  }

  Future<Null> itemCallBack(String pValue, Category pCat) async{

    GlobalKey<FormState> formKey = new GlobalKey<FormState>();

    if(pValue == "new" || pValue == "edit"){
      cat = pValue=="new"?new Category('Catégorie', Color.lerp(pCat.color, Colors.white, 0.45)):new Category(pCat.label, pCat.color);
      String dialogTitle = pValue=="new"?"Nouvelle catégorie":"Modification d'une catégorie";
      String action = await showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text(dialogTitle),
          content: new Form(
            key: formKey,
            child:
            new TextFormField(
              validator: validateCategoryLabel,
              decoration:new InputDecoration(
                icon:const Icon(Icons.category),
                labelText: "Libellé",
              ),
              controller: new TextEditingController(text:cat.label),
            )
          ),
          actions: <Widget>[
            new FlatButton(
                onPressed: (){Navigator.pop(context, null);},
                child: const Text("Annuler")
            ),
            new FlatButton(
                onPressed: (){Navigator.pop(context, "save");},
                child: const Text("Enregistrer")
            ),
          ],
        ),
      );

      if(action == "save"){
        if(!formKey.currentState.validate()){
          return;
        }
      }
    }

    walkTrough(List<Category>pCats){
      List<Category> cats = <Category>[];

      pCats.forEach((Category cat){

        var skip = false;

        var found = false;

        if(cat.compareTo(pCat) == 1) {
          found = true;
          switch(pValue){
            case "new":
              cat.children.add(this.cat);
              break;
            case "remove":
              skip = true;
              break;
            case "edit":
              cat.label = this.cat.label;
              cat.color = this.cat.color;
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

    categories = walkTrough(categories);

    settings.categories = categories;

    setState((){
      setItems();
    });
  }
}

class _MapExpansionItem{

  _MapExpansionItem({this.category, this.actionHandler}){
    items = [];
    this.category.children.forEach((Category value){
      items.add(new _MapExpansionItem(category:value, actionHandler: this.actionHandler));
    });
  }

  ActionItemCallback actionHandler;
  Category category;
  bool isExpanded = false;
  List<_MapExpansionItem> items;

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
            child: new CircleAvatar(backgroundColor: category.color, radius: 10.0,),
          ),
          new Expanded(child: new Text(category.label)),
          new PopupMenuButton(
            onSelected: (String pValue){
              actionHandler(pValue, category);
            },
            itemBuilder: (BuildContext pContext) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'new',
              child: const ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Sous catégorie')
              )
            ),
            const PopupMenuItem<String>(
              value: 'edit',
              child: const ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Modifier')
              )
            ),
            const PopupMenuItem<String>(
              value: 'remove',
              child: const ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Supprimer')
              )
            )
          ])
        ],
      ),
    )]..addAll(children);
  }
}