import 'dart:math';
import 'dart:async';

import 'package:observable/observable.dart';
import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;

import 'package:expenses/data/settings.dart';
import 'package:expenses/data/expense.dart';
import 'package:expenses/utils/geom.dart';

class HomeWidget extends StatefulWidget{
  const HomeWidget({Key key, this.settings}):super(key:key);

  final Settings settings;

  @override
  HomeState createState() => new HomeState(this.settings);
}

class HomeState extends State<HomeWidget> with TickerProviderStateMixin{
  HomeState(this.settings){
    this.settings.changes.listen((List<ChangeRecord> pChanges){
      refreshValues();
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final Settings settings;
  
  int expensesCount = 0;
  int daysLeft = 0;
  int displaySalary = 0;
  int savings = 0;

  double value = 0.0;
  AnimationController animation;

  @override
  void initState(){
    this.refreshValues();
    super.initState();
  }

  Future<Null> refreshValues() async{
    DateTime today = new DateTime.now();
    ExpensesData data = await settings.expensesData;
    int daysLeft = data.endDate.difference(today).inDays;
    animation = new AnimationController(vsync: this, duration:const Duration(milliseconds:5000));
    double total = data.expenses.fold(0.0, (double value, Expense element)=>value+element.value);
    int currentPercentage = ((total / data.salary) * 100).round();
    int totalSavings = (data.salary - total).round();
    animation.addListener((){
      setState((){
        this.value = lerpDouble(this.value, currentPercentage, animation.value);
        this.expensesCount = lerpDouble(this.expensesCount.toDouble(), data.expenses.length, animation.value).round();
        this.daysLeft = lerpDouble(this.daysLeft.toDouble(), daysLeft, animation.value).round();
        this.displaySalary = lerpDouble(this.displaySalary.toDouble(), data.salary, animation.value).round();
        this.savings = lerpDouble(this.savings, totalSavings, animation.value).round();
      });
    });
    animation.forward();
  }

  @override
  void dispose(){
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext pContext){
    return new Scaffold(
      key: _scaffoldKey,
      drawer: new HomeDrawer(),
      backgroundColor: const Color(0xFFeaeaea),
      body: new Column(
        children: <Widget>[
          new Container(
            padding:const EdgeInsets.only(top:30.0),
            decoration: new BoxDecoration(color: const Color(0xFF006978)),
            child:new Stack(
              children: <Widget>[
                new Container(
                  padding:const EdgeInsets.only(left:10.0),
                  child: new IconButton(icon: new Icon(Icons.menu, color: Colors.white), onPressed: (){
                    _scaffoldKey.currentState.openDrawer();
                  }),
                ),
                new Container(
                  padding: const EdgeInsets.only(top:50.0),
                  child:new Center(
                    child: new PieChart(value:this.value)
                  )
                ),
                new Container(
                  padding: const EdgeInsets.only(top:120.0),
                  child: new Center(
                    child: new Text(this.value.round().toString()+"%",
                        style: new TextStyle(
                            fontSize: 45.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        )
                    )
                  )
                )
              ]
            )
          ),
          new Container(
            padding:const EdgeInsets.only(top:50.0, bottom:50.0),
            child:
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new IndicatorWidget(count:this.expensesCount, label:"Dépenses", icon:Icons.list),
                  new IndicatorWidget(count:this.daysLeft, label:"Jours", icon:Icons.schedule),
                  new IndicatorWidget(count:this.displaySalary, label:"Salaire", icon:Icons.euro_symbol)
              ]
            )
          ),
          new Container(
            padding:const EdgeInsets.only(top:10.0),
            child: new Center(
              child: new Column(
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Icon(Icons.account_balance, color:Colors.grey, size:14.0),
                      new Text("Economies estimées", style: new TextStyle(color:Colors.grey, fontSize: 14.0)),
                    ],
                  ),
                  new Text(this.savings.toString(), style: new TextStyle(color:const Color(0xFF006978), fontSize: 80.0, fontWeight: FontWeight.bold))
                ],
              ),
            ),
          )
        ]
      ),
      floatingActionButton: new FloatingActionButton(child: const Icon(Icons.add), onPressed: (){
        Navigator.pushNamed(context, '/add');
      })
    );
  }
}

class IndicatorWidget extends StatelessWidget{
  const IndicatorWidget({Key key, this.count, this.label, this.icon}):super(key:key);

  final IconData icon;
  final int count;
  final String label;

  @override
  Widget build(BuildContext pContext){
    return new Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Container(
                margin:const EdgeInsets.only(right:5.0),
                child: new Icon(this.icon,size: 12.0, color:Colors.grey),
              ),
              new Text(this.label, style:new TextStyle(fontSize: 10.0, color: Colors.grey))
            ],
          ),
          new Text(this.count.toString(), style:new TextStyle(fontSize: 30.0, color:const Color(0xff00838f)))
        ]
    );
  }
}

class PieChart extends StatelessWidget{
  PieChart({Key key, this.value}):super(key:key);

  final double value;

  @override
  Widget build(BuildContext pContext){
    return new Container(
      width:200.0,
      height:200.0,
      child: new CustomPaint(
        painter:new PiePainter(value:this.value)
      )
    );
  }
}

class PiePainter extends CustomPainter{
  PiePainter({this.value}):super();

  double value;

  @override
  void paint(Canvas pCanvas, Size pSize){

    final double radius = pSize.shortestSide/2.0;

    final double maxAngle = 270.0;
    final double diff = 360.0 - maxAngle;
    final double s = 90.0 + (diff / 2.0);

    final double valueAngle = maxAngle * (this.value / 100.0);

    this._drawArc(pCanvas, s, maxAngle, Colors.white, radius);
    this._drawArc(pCanvas, s, valueAngle, const Color(0xff56c8d8), radius);

  }

  void _drawArc(Canvas pCanvas, double pStartAngle, double pAngle, Color pColor, double pRadius) {

    final double width = 15.0;

    final Offset center = new Offset(pRadius, pRadius);

    final double startAngle = Geom.toRadian(pStartAngle);
    final double endAngle = Geom.toRadian(pStartAngle + pAngle);

    pAngle = Geom.toRadian(pAngle);

    final Offset innerSPoint = center + (new Offset(cos(startAngle) * (pRadius - width), sin(startAngle) * (pRadius - width)));

    final Offset innerEPoint = center + (new Offset(cos(endAngle) * (pRadius - width), sin(endAngle) * (pRadius - width)));

    final Paint p = new Paint()..color = pColor;
    final Path path = new Path();

    path.moveTo(innerSPoint.dx, innerSPoint.dy);
    path.arcTo(new Rect.fromCircle(center:center, radius:pRadius - width), startAngle, pAngle, false);
    path.lineTo(innerEPoint.dx, innerEPoint.dy);
    path.arcTo(new Rect.fromCircle(center:center, radius:pRadius), startAngle + pAngle, -pAngle, false);
    path.close();

    pCanvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(PiePainter pOldPainter){
    return this.value  != pOldPainter.value;
  }
}

class HomeDrawer extends StatefulWidget{

  @override
  _HomeDrawerState createState() => new _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer>{

  @override
  Widget build(BuildContext pContext){

    List<Map> items = <Map>[
      {
        "label": "Accueil",
        "icon": Icons.home,
        "route": "/home"
      },
      {
        "label": "Dépenses",
        "icon": Icons.view_list,
        "route": "/expenses"
      },
      {
        "label": "Paramètres",
        "icon": Icons.settings,
        "route": "/settings"
      }
    ];

    return new Drawer(
      child: new ListView(
        children: <Widget>[
          new DrawerHeader(
              child: new Container(
                child: new Image.asset("assets/expenses_icon.png"),
              )
          ),
          new Column(
            children: items.map((Map pMap){
              return new ListTile(
                leading: new CircleAvatar(child: new Icon(pMap["icon"]),),
                title: new Text(pMap["label"]),
                onTap: (){
                  Navigator.pushNamed(pContext, "/expenses");
                },
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}