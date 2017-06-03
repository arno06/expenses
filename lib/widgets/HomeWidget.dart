import 'dart:math';

import 'package:flutter/material.dart';
import 'package:expenses/utils/geom.dart';
import 'dart:ui' show lerpDouble;

class HomeWidget extends StatefulWidget{
  const HomeWidget({Key key}):super(key:key);

  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State<HomeWidget> with TickerProviderStateMixin{

  int expenses = 0;
  int days = 0;
  int salary = 0;

  double value = 0.0;
  AnimationController animation;

  @override
  void initState(){
    super.initState();
    animation = new AnimationController(vsync: this, duration:const Duration(milliseconds:5000));
    animation.addListener((){
      setState((){
        this.value = lerpDouble(this.value, 75.0, animation.value);
        this.expenses = lerpDouble(this.expenses.toDouble(), 200, animation.value).round();
        this.days = lerpDouble(this.days.toDouble(), 19, animation.value).round();
        this.salary = lerpDouble(this.salary.toDouble(), 2897, animation.value).round();
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
            child:new Center(
              child: new PieChart(value:this.value)
            )
          ),
          new Container(
            padding:const EdgeInsets.only(top:50.0, bottom:50.0),
            child:
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new IndicatorWidget(count:this.expenses, label:"Dépenses enregistrées"),
                  new IndicatorWidget(count:this.days, label:"Jours restants"),
                  new IndicatorWidget(count:this.salary, label:"€ de salaire")
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

  void _displayAddForm(){
    print("bouboup");
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