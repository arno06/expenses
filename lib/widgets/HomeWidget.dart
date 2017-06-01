import 'dart:math';

import 'package:flutter/material.dart';
import 'package:expenses/utils/geom.dart';

class HomeWidget extends StatefulWidget{
  const HomeWidget({Key key}):super(key:key);

  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State<HomeWidget>{

  @override
  Widget build(BuildContext pContext){
    return new Scaffold(
      body: new Column(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(color: Colors.deepPurpleAccent),
            child:new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new Text("0%"),
                new PieChart(value:75.0),
                new Text("100%")
              ]
            )
          )
        ]
      )
    );
  }
}

class PieChart extends StatelessWidget{
  PieChart({Key key, this.value}):super(key:key);

  double value;

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
    print(value.toString());
    print(pSize.toString());

    final double radius = pSize.shortestSide/2.0;


    final double diff = 360.0 - 270.0;
    final double s = 90.0 + (diff / 2.0);

    this._drawArc(pCanvas, s, 270.0, Colors.white, radius);
    this._drawArc(pCanvas, s, 180.0, Colors.blue, radius);

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
    return false;
  }
}