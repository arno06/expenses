import 'dart:math';

import 'package:observable/observable.dart';
import 'package:flutter/material.dart';
import 'package:expenses/utils/geom.dart';
import 'dart:ui' show lerpDouble;

import 'package:expenses/data/settings.dart';
import 'package:expenses/data/expense.dart';

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

  final Settings settings;
  
  int expensesCount = 0;
  int daysLeft = 0;
  int displaySalary = 0;

  double value = 0.0;
  AnimationController animation;

  @override
  void initState(){
    super.initState();
    this.refreshValues();
  }

  void refreshValues(){
    DateTime today = new DateTime.now();
    int daysLeft = settings.endDate.difference(today).inDays;
    animation = new AnimationController(vsync: this, duration:const Duration(milliseconds:5000));
    double total = settings.expenses.fold(0.0, (double value, Expense element)=>value+element.value);
    int currentPercentage = ((total / settings.salary) * 100).round();
    animation.addListener((){
      setState((){
        this.value = lerpDouble(this.value, currentPercentage, animation.value);
        this.expensesCount = lerpDouble(this.expensesCount.toDouble(), settings.expenses.length, animation.value).round();
        this.daysLeft = lerpDouble(this.daysLeft.toDouble(), daysLeft, animation.value).round();
        this.displaySalary = lerpDouble(this.displaySalary.toDouble(), settings.salary, animation.value).round();
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
      backgroundColor: const Color(0xFFeaeaea),
      body: new Column(
        children: <Widget>[
          new Container(
            padding:const EdgeInsets.only(top:60.0),
            decoration: new BoxDecoration(color: const Color(0xFF006978)),
            child:new Stack(
              children: <Widget>[
                new Container(
                  child:new Center(
                    child: new PieChart(value:this.value)
                  )
                ),
                new Container(
                  padding: const EdgeInsets.only(top:70.0),
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
                  new IndicatorWidget(count:this.expensesCount, label:"Dépenses enregistrées"),
                  new IndicatorWidget(count:this.daysLeft, label:"Jours restants"),
                  new IndicatorWidget(count:this.displaySalary, label:"€ de salaire")
              ]
            )
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
  const IndicatorWidget({Key key, this.count, this.label}):super(key:key);

  final int count;
  final String label;

  @override
  Widget build(BuildContext pContext){
    return new Column(
        children: <Widget>[
          new Text(this.count.toString(), style:new TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color:const Color(0xFF444444))),
          new Text(this.label, style:new TextStyle(fontSize: 10.0, color: Colors.grey))
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