import 'package:flutter/cupertino.dart';

class SizeHandler {

  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double widthPercentage(BuildContext context, double percentage) {
    assert (percentage <= 1.0 && percentage >= 0.0);
    return MediaQuery.of(context).size.width * percentage;
  }

  static double heightPercentage(BuildContext context, double percentage) {
    assert (percentage <= 1.0 && percentage >= 0.0);
    return MediaQuery.of(context).size.height * percentage;
  }

  static double getCardHeight(double totalHeight, int cardsPerScreen, double marginPercentage){
     return totalHeight / cardsPerScreen - 2 * marginPercentage;
  }
}