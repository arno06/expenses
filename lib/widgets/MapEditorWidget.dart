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
  }

  Settings settings;
  Map<String, dynamic> categories;

  List<Widget> buildTree(Map<String, dynamic> pMap, [int pDeep = 0]){
    List<Widget> tree = <Widget>[];

    double paddingLeft = 35.0 * pDeep;

    pMap.forEach((String key, Map value){
      tree.add(new ListTile(
        title: new Container(
          padding:new EdgeInsets.only(left:paddingLeft),
          child: new Text(key),
        ),
      ));

      tree.addAll(buildTree(value, pDeep+1));
      if(pDeep == 0)
        tree.add(new Divider());
    });

    return tree;
  }

  @override
  Widget build(BuildContext pContext){

    List<Widget> items = buildTree(categories);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Gestion des catégories'),
      ),
      body: new ListView(
        children: items,
      ),
    );
  }
}