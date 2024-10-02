import 'package:flutter/material.dart';

class Pellet {
  static const Color kPrimary = Color(0xFFF22CAC);
  static const Color kSecondary = Color(0xFF53ABFF);
  static const Color kTertiary = Color(0xFFACDF3A);
  static const Color kWhite = Color(0xFFf5f5f7);
  static const Color kDark = Color.fromARGB(255, 27, 27, 28);
  static const Color kBlack = Color(0xff000000);
  static Color kGrey = kWhite.withOpacity(0.5);
  static const Color kBlue = Colors.blueAccent;
  static const Gradient kBackgroundGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xff1E0F28),
      Color(0xff000000),
      Color(0xff000000),
      Color(0xff0C1427),
    ],
  );
  static const Gradient kFlashBackgroundGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xffbc5eff),
      Color(0xff4385f8),
    ],
  );
}
