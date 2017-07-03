import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Dictionary{

  static const String DEFAULT_VALUE = "Undefined";

  static Dictionary _instance;

  static term(String pId){
    if(pId.isEmpty)
      return Dictionary.DEFAULT_VALUE;

    List<String> ids = pId.split('.');

    if(_instance == null || _instance.data == null)
      return Dictionary.DEFAULT_VALUE;

    Map stack = _instance.data;

    String id;
    for(int i = 0, max = ids.length; i<max;i++){
      id = ids[i];
      if(stack.containsKey(id)){

        if(stack[id] is Map){
          stack = stack[id];
        }
        else
          return stack[id];
      }
      else
        return Dictionary.DEFAULT_VALUE;
    }

    return stack.toString();
  }

  static Future setLocal(String pLocal) async{
    if(_instance == null)
      _instance = new Dictionary();
    await _instance.loadLocal(pLocal);
  }

  Map data;
  Future<Null> loadLocal(String pValue) async{
    String raw = await rootBundle.loadString('assets/localization/'+pValue+'.json');
    try{
      data = JSON.decode(raw);
    }
    on Exception{
      print("Erreur lors du parsing du fichier de localization : "+pValue);
    }
  }
}