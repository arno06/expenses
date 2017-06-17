import 'package:flutter/material.dart';

import 'package:expenses/data/settings.dart';

class MapEditorWidget extends StatefulWidget{

  MapEditorWidget({this.settings});

  final Settings settings;

  @override
  _MapEditorWidgetState createState() => new _MapEditorWidgetState(this.settings);
}

class _MapEditorWidgetState extends State<MapEditorWidget>{
  _MapEditorWidgetState(this.settings){
    categories = this.settings.categories;

    items = categories.map((Category value){
      return new _MapExpansionItem(category:value);
    }).toList();

  }

  Settings settings;
  List<Category> categories;

  List<_MapExpansionItem> items;

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
}

class _MapExpansionItem{

  _MapExpansionItem({this.category}){
    items = [];
    this.category.children.forEach((Category value){
      items.add(new _MapExpansionItem(category:value));
    });
  }

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
          new PopupMenuButton(itemBuilder: (BuildContext pContext) => <PopupMenuEntry<String>>[
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