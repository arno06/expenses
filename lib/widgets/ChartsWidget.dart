import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:expenses/data/settings.dart';
import 'package:expenses/data/expense.dart';
import 'package:expenses/utils/geom.dart';

class ChartsWidget extends StatefulWidget{

  ChartsWidget({this.settings});

  final Settings settings;

  @override
  _ChartsWidgetState createState() => new _ChartsWidgetState(this.settings);
}

class _ChartsWidgetState extends State<ChartsWidget>{
  _ChartsWidgetState(this.settings){
    this.expenses = this.settings.getExpenses((new DateTime.now().month));
    this.expenses.sort((Expense a, Expense b){
      return a.date.compareTo(b.date);
    });
  }

  final Settings settings;

  List<Expense> expenses = [];

  @override
  Widget build(BuildContext pContext){

    List<Color> colors = <Color>[
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.red,
      Colors.orange,
      Colors.lightGreen,
      Colors.lightBlue,
    ];

    Map categorizedMap = new Map();
    Map recurrentMap = new Map();

    recurrentMap['recurrent'] = new PiePart(label:"Frais fixes", value:0.0, color:const Color(0xffffee58));
    recurrentMap['nonrecurrent'] = new PiePart(label:"Frais variables", value:0.0, color:const Color(0xffff7043));

    List<PiePart> categorizedData = [];
    List<PiePart> recurrentData = [];

    Expense exp;
    for(var i = 0, max = this.expenses.length; i<max; i++){
      exp = this.expenses[i];
      String label = exp.categories.split("/").first;
      if(!categorizedMap.containsKey(label)){
        categorizedMap[label] = new PiePart(label:label, value:0.0, color:colors.removeAt(0));
      }
      categorizedMap[label].value += exp.value;

      if(exp.isRecurrent){
        recurrentMap['recurrent'].value += exp.value;
      }
      else{
        recurrentMap['nonrecurrent'].value += exp.value;
      }
    }
    categorizedMap.forEach((String pKey, PiePart pPart){
      categorizedData.add(pPart);
    });
    recurrentMap.forEach((String pKey, PiePart pPart){
      recurrentData.add(pPart);
    });

    DateFormat d = new DateFormat.yMMMM("FR_fr");
    DateTime today = new DateTime.now();
    return new Scaffold(
      backgroundColor: const Color(0xfff3f8f9),
      appBar: new AppBar(
        title: new Text("Statistiques ("+d.format(today)+")"),
      ),
      body: new ListView(
        children: <Widget>[
          new Column(
            children: <Widget>[
              new Container(
                margin:const EdgeInsets.only(top:20.0),
                child: new PieChart(data:categorizedData),
              ),
              new Container(
                margin:const EdgeInsets.only(top:20.0),
                child: new PieChart(data:recurrentData),
              )
            ],
          )
        ],
      ),
    );
  }
}


class PieChart extends StatelessWidget{
  PieChart({this.data});

  final List<PiePart> data;

  @override
  Widget build(BuildContext pContext){

    List<Widget> legend = [];

    this.data.forEach((PiePart pPart){
      legend.add(new Container(
        margin:const EdgeInsets.only(bottom:4.0),
        child: new Row(
          children: <Widget>[
            new Container(
              margin:const EdgeInsets.only(right:5.0),
              child: new CircleAvatar(
                radius: 7.0,
                backgroundColor: pPart.color,
              ),
            ),
            new Text(pPart.label, style:new TextStyle(color: const Color(0xff284a63), fontSize: 12.0))
          ],
        ),
      ));
    });

    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Container(
            width:250.0,
            height:250.0,
            child: new CustomPaint(
                painter:new PiePainter(data:data)
            )
        ),
        new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: legend,
        )
      ],
    );
  }
}

class PiePart{
  PiePart({this.label, this.value, this.color});

  Color color;
  double value;
  String label;
}

class PiePainter extends CustomPainter{
  PiePainter({this.data});

  List<PiePart> data;

  @override
  void paint(Canvas pCanvas, Size pSize){

    double circle = 360.0;
    double total = 0.0;
    data.forEach((PiePart pPart){
      total += pPart.value;
    });

    double currentAngle = 0.0;

    Offset center = pSize.center(new Offset(0.0, 0.0));
    data.forEach((PiePart pPart){
      double angle = circle * (pPart.value / total);
      double rad = Geom.toRadian(currentAngle);
      Paint p = new Paint()..color = pPart.color;
      Path path = new Path();
      Offset start = center + new Offset(cos(rad) * center.dx, sin(rad) * center.dy);
      path.moveTo(center.dx, center.dy);
      path.lineTo(start.dx, start.dy);

      path.arcTo(new Rect.fromCircle(center:center, radius:center.dx), Geom.toRadian(currentAngle), Geom.toRadian(angle), false);
      path.lineTo(center.dx, center.dy);
      path.close();

      pCanvas.drawPath(path, p);

      currentAngle += angle;
    });

    data.forEach((PiePart pPart){
      double angle = circle * (pPart.value / total);
      double rad = Geom.toRadian(currentAngle);
      Paint p = new Paint()..color = const Color(0xfff3f8f9);
      Offset start = center + new Offset(cos(rad) * center.dx, sin(rad) * center.dy);
      p.strokeWidth = 2.0;
      p.strokeCap = StrokeCap.round;

      pCanvas.drawLine(center, start, p);

      currentAngle += angle;
    });
  }

  @override
  bool shouldRepaint(PiePainter pPainter){
    return false;
  }
}