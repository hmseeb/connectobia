// responsive spacing constants
import 'package:flutter/material.dart';

class ScreenSize {
  static double kSpaceXS = 0.5;
  static double kSpaceS = 1;

  static double kSpaceM = 2;
  static double kSpaceL = 3;
  static double kSpaceXL = 4;
  static double kSpaceXXL = 5;
  static double kSpaceXXXL = 10;
  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height / 100;
  static double width(BuildContext context) =>
      MediaQuery.sizeOf(context).width / 100;
}
