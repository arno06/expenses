import 'package:flutter/material.dart';
import 'package:expenses/data/settings.dart';

class SettingsWidget extends StatefulWidget{

  SettingsWidget({this.settings});

  final Settings settings;

  @override
  _SettingsWidgetState createState() => new _SettingsWidgetState(this.settings);
}

class _SettingsWidgetState extends State<SettingsWidget>{
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  _SettingsWidgetState(this.settings);

  final Settings settings;

  String _validateSalary(String pValue){
    int value = int.parse(pValue);
    if(value < 0)
      value = 0;
    settings.salary = value;
    return null;
  }

  String _validateSalaryMonth(String pValue){
    int value = int.parse(pValue);

    if(value < 0)
      value = 1;

    if(value > 31)
      value = 31;

    settings.salaryDay = value;
    return null;
  }

  void showSettingsDialog<T>({BuildContext context, Widget child}){
    showDialog(context: context, child: child)
      .then<Null>((T value){
        if(value == "save"){
          final FormState f = _formKey.currentState;
          f.validate();
        }
      }
    );
  }

  @override
  Widget build(BuildContext pContext){
    String salary = settings == null || settings.salary == null ? "" : settings.salary.toString()+"€";
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Paramètres"),
      ),
      body: new ListView(
        children: <Widget>[
          new ListTile(
            title: new Text("Définir le salaire"),
            subtitle: new Text(salary),
            onTap: (){
              showSettingsDialog(
                context: context,
                child: new AlertDialog(
                  title: new Text("Définir le salaire"),
                  content: new Form(
                    key: _formKey,
                    child: new TextFormField(
                      decoration:new InputDecoration(
                        icon:const Icon(Icons.euro_symbol),
                        labelText: "Salaire",
                      ),
                      controller: new TextEditingController(text:this.settings.salary.toString()),
                      keyboardType: TextInputType.number,
                      validator: _validateSalary,
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
                )
              );
            },
          ),
          new Divider(),
          new ListTile(
            title: new Text("Afficher le salaire sur l'accueil"),
            trailing: new Checkbox(
              value: settings.displaySalary,
              onChanged: (pValue){
                setState((){
                  settings.displaySalary = pValue;
                });
              }),
            onTap: (){
              setState((){
                settings.displaySalary = !settings.displaySalary;
              });
            },
          ),
          new Divider(),
          new ListTile(
            title: new Text("Jour de réception du salaire"),
            subtitle: new Text(settings.salaryDay.toString()),
            onTap: (){
              showSettingsDialog(
                  context: context,
                  child: new AlertDialog(
                    title: new Text("Jour de réception du salaire"),
                    content: new Form(
                        key: _formKey,
                        child: new TextFormField(
                          decoration:new InputDecoration(
                            icon:const Icon(Icons.date_range),
                            labelText: "Jours du Mois",
                          ),
                          controller: new TextEditingController(text:this.settings.salaryDay.toString()),
                          keyboardType: TextInputType.number,
                          validator: _validateSalaryMonth,
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
                  )
              );
            },
          ),
          new Divider(),
        ]
      ),
    );
  }
}