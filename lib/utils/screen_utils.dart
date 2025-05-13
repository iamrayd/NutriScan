import 'package:flutter/material.dart';

class ScreenUtils {
  static double halfScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.5;
  }

  static double quarterScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.25;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double imageHeight(BuildContext context) {
    return 450;
  }

  static double imageHeightHalf(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.22;
  }
}