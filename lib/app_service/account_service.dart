import 'package:getx_study/i18n/app_text.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:getx_study/entity/account_info_entity.dart';
import 'package:getx_study/enum/theme_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 这个类就像一个 "GetxController"，它共享相同的生命周期 （"onInit()"、"onReady()"、"onClose()"） 。 但里面没有 "逻辑"。它只是通知GetX的依赖注入系统，这个子类不能从内存中删除。
/// 所以这对保持你的 "服务 "总是可以被Get.find()获取到并保持运行是超级有用的。比如 ApiService，StorageService，CacheService。
class AccountService extends GetxService {
  final _kLastLoginUserName = "kLastLoginUserName";

  final _kLastLoginPassword = "kLastLoginPassword";

  final _kLastThemeSettingIndex = "kLastThemeSettingIndex";

  final _kAccountInfo = "kAccountInfo";

  final _kOpenDarkMode = "kOpenDarkMode";

  final _kIsFirstLaunch = "kIsFirstLaunch";

  final _kThemeSetting = "kThemeSetting";

  AccountInfoEntity? info;

  var isLogin = false;

  int sessionRevision = 0;

  final _sessionChanges = StreamController<int>.broadcast(sync: true);
  Stream<int> get sessionChanges => _sessionChanges.stream;

  void _notifySessionChanged() => _sessionChanges.add(sessionRevision);

  @override
  void onClose() {
    _sessionChanges.close();
    super.onClose();
  }

  Future<void> _pendingPersistence = Future<void>.value();

  /// 按会话操作顺序落盘，避免旧登录写入覆盖随后发生的退出。
  Future<void> _persist(Future<void> Function() operation) {
    final result = _pendingPersistence.then((_) => operation());
    _pendingPersistence = result.catchError((Object _) {});
    return result;
  }

  Map<String, num?>? _coinSummary;
  String? _userInfoOverride;

  String get userInfo => _userInfoOverride ?? AppText.t('account.summary', {
    'level': AppText.number(_coinSummary?['level']),
    'rank': AppText.number(_coinSummary?['rank']),
    'points': AppText.number(_coinSummary?['points']),
  });

  set userInfo(String value) => _userInfoOverride = value;

  void updateCoinSummary({num? level, num? rank, num? points}) {
    _userInfoOverride = null;
    _coinSummary = {'level': level, 'rank': rank, 'points': points};
  }

  static AccountService get find => Get.find<AccountService>();

  // 使用安全存储来保存敏感信息（如密码）
  static const _secureStorage = FlutterSecureStorage(
    // 从旧版加密存储迁移时保留备份，支持迁移中断后的恢复。
    aOptions: AndroidOptions(migrateWithBackup: true),
  );

  Future<SharedPreferences> get userDefine async =>
      await SharedPreferences.getInstance();

  // 只读计算属性
  String get cookieHeaderValue {
    if (info?.username != null && info?.password != null) {
      return "loginUserName=${info?.username};loginUserPassword=${info?.password}";
    } else {
      return "";
    }
  }

  Future<void> save({
    required AccountInfoEntity info,
    required bool isLogin,
    required String password,
  }) async {
    final previousInfo = this.info;
    final previousIsLogin = this.isLogin;
    final previousUserInfo = _userInfoOverride;
    final previousCoinSummary = _coinSummary;
    final revision = ++sessionRevision;
    this.info = info;
    this.isLogin = isLogin;
    _userInfoOverride = null;
    _coinSummary = null;
    this.info?.password = password;
    _notifySessionChanged();

    try {
      await _persist(() async {
        final userDefine = await this.userDefine;
        // 使用普通存储保存用户名
        await userDefine.setString(_kLastLoginUserName, info.username ?? "");
        // 使用安全存储保存密码（加密存储）
        await _secureStorage.write(key: _kLastLoginPassword, value: password);
        // 本来想尝试保存一个字典的,结果没这个方法,只有List<String>,但是我可以将Map转为String在存呀
        final infoJsonString = json.encode(info.toJson());
        await userDefine.setString(_kAccountInfo, infoJsonString);
      });
    } catch (_) {
      if (sessionRevision == revision) {
        this.info = previousInfo;
        this.isLogin = previousIsLogin;
        _userInfoOverride = previousUserInfo;
        _coinSummary = previousCoinSummary;
        _notifySessionChanged();
      }
      rethrow;
    }
  }

  Future<bool> saveLastThemeSettingIndex(int index) async {
    final userDefine = await this.userDefine;
    return userDefine.setInt(_kLastThemeSettingIndex, index);
  }

  Future<bool> saveOpenDarkMode(bool isOpenDarkMode) async {
    final userDefine = await this.userDefine;
    return userDefine.setBool(_kOpenDarkMode, isOpenDarkMode);
  }

  Future<bool> saveNotFirstLaunch() async {
    final userDefine = await this.userDefine;
    return userDefine.setBool(_kIsFirstLaunch, false);
  }

  Future<bool> saveThemeSetting(ThemeType type) async {
    final userDefine = await this.userDefine;
    return userDefine.setInt(_kThemeSetting, type.index);
  }

  Future<String> getLastLoginUserName() async {
    final userDefine = await this.userDefine;
    return userDefine.getString(_kLastLoginUserName) ?? "";
  }

  Future<String> getLastAccountInfo() async {
    final userDefine = await this.userDefine;
    return userDefine.getString(_kAccountInfo) ?? "";
  }

  Future<int> getLastThemeSettingIndex() async {
    final userDefine = await this.userDefine;
    return userDefine.getInt(_kLastThemeSettingIndex) ?? 0;
  }

  Future<String> getLastLoginPassword() async {
    // 从安全存储中读取密码
    return await _secureStorage.read(key: _kLastLoginPassword) ?? "";
  }

  Future<bool> getIsOpenDarkMode() async {
    final userDefine = await this.userDefine;
    return userDefine.getBool(_kOpenDarkMode) ?? false;
  }

  Future<bool> getIsFirstLaunch() async {
    final userDefine = await this.userDefine;
    return userDefine.getBool(_kIsFirstLaunch) ?? true;
  }

  Future<ThemeType> getThemeSetting() async {
    final userDefine = await this.userDefine;
    final index = userDefine.getInt(_kThemeSetting) ?? 0;
    return ThemeType.values[index];
  }

  Future<void> clear() async {
    sessionRevision++;
    info = null;
    _userInfoOverride = null;
    _coinSummary = null;
    isLogin = false;
    _notifySessionChanged();
    await _persist(() async {
      final userDefine = await this.userDefine;
      await userDefine.remove(_kLastLoginUserName);
      await userDefine.remove(_kAccountInfo);
      // 从安全存储中删除密码
      await _secureStorage.delete(key: _kLastLoginPassword);
    });
  }
}
