import 'dart:math';

class Geom
{
  static toRadian(double pValue){
    return pValue * (pi / 180);
  }

  static toDegree(double pValue){
    return pValue * (180 / pi);
  }
}