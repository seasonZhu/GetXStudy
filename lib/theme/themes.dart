import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppThemes {
  static const lightTheme = CupertinoThemeData(
      primaryColor: Colors.blue,
      barBackgroundColor: Colors.white,
      brightness: Brightness.light);

  static const blueLightTheme = CupertinoThemeData(
      primaryColor: Colors.blue,
      barBackgroundColor: Colors.blue,
      textTheme: CupertinoTextThemeData(
        primaryColor: Colors.white,
        navTitleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      brightness: Brightness.light);

  static const greenLightTheme = CupertinoThemeData(
      primaryColor: Colors.green,
      barBackgroundColor: Colors.green,
      textTheme: CupertinoTextThemeData(
        primaryColor: Colors.white,
        navTitleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      brightness: Brightness.light);

  static const redLightTheme = CupertinoThemeData(
      primaryColor: Colors.red,
      barBackgroundColor: Colors.red,
      textTheme: CupertinoTextThemeData(
        primaryColor: Colors.white,
        navTitleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      brightness: Brightness.light);

  static const darkTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    textTheme: CupertinoTextThemeData(primaryColor: Colors.white),
  );
}
