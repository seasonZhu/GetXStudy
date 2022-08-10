import 'dart:convert';

import 'package:getx_study/entity/account_info_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountManager {
  /// 以下字符串常量私有化比较好

  final kLastLoginUserName = "kLastLoginUserName";

  final kLastLoginPassword = "kLastLoginPassword";

  final kLastThemeSettingIndex = "kLastThemeSettingIndex";

  final kAccountInfo = "kAccountInfo";

  final kOpenDarkMode = "kOpenDarkMode";

  final kIsFirstLaunch = "kIsFirstLaunch";

  AccountInfoEntity? info;

  var isLogin = false;

  var myCoinInfo = "等级 --  排名 --  积分 --";

  Future<SharedPreferences> get userDefine async => await SharedPreferences.getInstance();

  // 只读计算属性
  String get cookieHeaderValue {
    if (info?.username != null && info?.password != null) {
      return "loginUserName=${info?.username};loginUserPassword=${info?.password}";
    } else {
      return "";
    }
  }

  Future<void> save(
      {required AccountInfoEntity info,
      required bool isLogin,
      required String password}) async {
    this.info = info;
    this.isLogin = true;
    this.info?.password = password;

    var userDefine = await SharedPreferences.getInstance();
    userDefine.setString(kLastLoginUserName, info.username ?? "");
    userDefine.setString(kLastLoginPassword, password);
    // 本来想尝试保存一个字典的,结果没这个方法,只有List<String>,但是我可以将Map转为String在存呀
    var infoJsonString = json.encode(info.toJson());
    userDefine.setString(kAccountInfo, infoJsonString);
  }

  Future<bool> saveLastThemeSettingIndex(int index) async {
    var userDefine = await SharedPreferences.getInstance();
    return userDefine.setInt(kLastThemeSettingIndex, index);
  }

  Future<bool> saveOpenDarkMode(bool isOpenDarkMode) async {
    var userDefine = await SharedPreferences.getInstance();
    return userDefine.setBool(kOpenDarkMode, isOpenDarkMode);
  }

  Future<bool> saveNotFirstLanuch() async {
    var userDefine = await SharedPreferences.getInstance();
    return userDefine.setBool(kIsFirstLaunch, false);
  }

  Future<String> getLastLoginUserName() async {
    var userDefine = await SharedPreferences.getInstance();
    return userDefine.getString(kLastLoginUserName) ?? "";
  }

  Future<String> getLastAccountInfo() async {
    var userDefine = await SharedPreferences.getInstance();
    return userDefine.getString(kAccountInfo) ?? "";
  }

  Future<int> getLastThemeSettingIndex() async {
    var userDefine = await SharedPreferences.getInstance();
    return userDefine.getInt(kLastThemeSettingIndex) ?? 0;
  }

  Future<String> getLastLoginPassword() async {
    var userDefine = await SharedPreferences.getInstance();
    return userDefine.getString(kLastLoginPassword) ?? "";
  }

  Future<bool> getIsOpenDardMode() async {
    var userDefine = await SharedPreferences.getInstance();
    return userDefine.getBool(kOpenDarkMode) ?? false;
  }

  Future<bool> getIsFirstLaunch() async {
    var userDefine = await SharedPreferences.getInstance();
    return userDefine.getBool(kIsFirstLaunch) ?? true;
  }

  void clear() async {
    info = null;
    myCoinInfo = "等级 --  排名 --  积分 --";
    isLogin = false;
    var userDefine = await SharedPreferences.getInstance();
    userDefine.remove(kLastLoginUserName);
    userDefine.remove(kLastLoginPassword);
  }

  // 单例模式写法
  // 类名._() 是将初始化方法私有化
  AccountManager._();

  /// 类似Swift的单例写法
  static final shared = AccountManager._();
}
