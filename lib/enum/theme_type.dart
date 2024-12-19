enum ThemeType { light, blue, green, red }

extension Ext on ThemeType {
  String get title {
    switch (this) {
      case ThemeType.light:
        return "浅色";
      case ThemeType.blue:
        return "蓝色";
      case ThemeType.green:
        return "绿色";
      case ThemeType.red:
        return "红色";
    }
  }

  static final dataSource = [
    ThemeType.light,
    ThemeType.blue,
    ThemeType.green,
    ThemeType.red
  ];
}
