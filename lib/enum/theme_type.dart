import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

enum ThemeType { light, dark, blue, green, red }

extension Ext on ThemeType {
  String get title {
    switch (this) {
      case ThemeType.light:
        return "浅色";
      case ThemeType.dark:
        return "深色";
      case ThemeType.blue:
        return "蓝色";
      case ThemeType.green:
        return "绿色";
      case ThemeType.red:
        return "红色";
    }
  }

  CupertinoThemeData get theme {
    switch (this) {
      case ThemeType.light:
        return const CupertinoThemeData(
            primaryColor: Colors.blue,
            barBackgroundColor: Colors.white,
            brightness: Brightness.light);
      case ThemeType.dark:
        return const CupertinoThemeData(
          primaryColor: Colors.white,
          brightness: Brightness.dark,
          textTheme: CupertinoTextThemeData(primaryColor: Colors.white),
        );
      case ThemeType.blue:
        return const CupertinoThemeData(
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
      case ThemeType.green:
        return const CupertinoThemeData(
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
      case ThemeType.red:
        return const CupertinoThemeData(
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
    }
  }
}
