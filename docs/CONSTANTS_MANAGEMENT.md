# Flutter 常量管理完整指南

## 📚 目录
1. [方案对比](#方案对比)
2. [推荐方案详解](#推荐方案详解)
3. [使用示例](#使用示例)
4. [与Android对比](#与android对比)
5. [最佳实践](#最佳实践)

---

## 方案对比

### Android 的方式
```
res/
├── values/
│   ├── strings.xml
│   ├── colors.xml
│   └── dimens.xml
└── zh/
    └── strings.xml
```

访问方式：`R.string.app_name`

### Flutter 的方式

| 方案 | 特点 | 适用场景 |
|------|------|----------|
| **Dart常量类** | 简单、类型安全 | 小项目 |
| **JSON+代码生成** | 动态、灵活 | **中大型项目（推荐）** |
| **国际化** | 支持多语言 | 需要国际化 |
| **env环境变量** | 安全、不同环境 | 配置管理 |

---

## 推荐方案详解

### 架构设计

```
assets/config/
├── strings_zh.json    # 中文字符串
├── colors.json        # 颜色配置
└── dimens.json        # 尺寸配置

lib/resource/
├── app_resources.dart # 资源加载器
├── app_strings.dart   # 字符串常量类（可选）
├── app_colors.dart    # 颜色常量类（可选）
└── app_dimens.dart    # 尺寸常量类（可选）
```

### 优势

✅ **类似Android**: 配置文件与代码分离
✅ **动态加载**: 修改JSON无需重新编译
✅ **类型安全**: 自动类型转换
✅ **易于维护**: 集中管理
✅ **支持国际化**: 扩展JSON即可

---

## 使用示例

### 1. 字符串资源

#### 配置文件 (strings_zh.json)
```json
{
  "app": {
    "name": "玩安卓"
  },
  "login": {
    "title": "登录",
    "button": "登录"
  }
}
```

#### 代码使用
```dart
// 方式1: 直接访问
Text(AppStrings.loginTitle)

// 方式2: 通过配置对象访问
final strings = AppStrings.of(context);
Text(strings['login']['title'])
```

#### 对比之前
```dart
// ❌ 之前：硬编码
Text("登录")
Text("登录成功，欢迎回来！")

// ✅ 现在：使用资源
Text(AppStrings.loginTitle)
Text(AppStrings.loginSuccess)
```

---

### 2. 颜色资源

#### 配置文件 (colors.json)
```json
{
  "colors": {
    "primary": "#2196F3",
    "success": "#4CAF50"
  }
}
```

#### 代码使用
```dart
// 方式1: 直接访问
Container(color: AppColors.primary)

// 方式2: 在主题中使用
MaterialApp(
  theme: ThemeData(
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
    ),
  ),
)
```

#### 对比之前
```dart
// ❌ 之前：硬编码颜色
Color(0xFF2196F3)

// ✅ 现在：使用资源
AppColors.primary
```

---

### 3. 尺寸资源

#### 配置文件 (dimens.json)
```json
{
  "dimens": {
    "padding_medium": 16.0,
    "font_size_large": 16.0
  }
}
```

#### 代码使用
```dart
// 间距
EdgeInsets.all(AppDimens.paddingMedium)
EdgeInsets.symmetric(horizontal: AppDimens.paddingLarge)

// 字体
TextStyle(fontSize: AppDimens.fontSizeLarge)

// 组件
SizedBox(
  height: AppDimens.buttonHeight,
)
```

#### 对比之前
```dart
// ❌ 之前：硬编码数字
EdgeInsets.all(16.0)
TextStyle(fontSize: 16.0)

// ✅ 现在：使用资源
EdgeInsets.all(AppDimens.paddingMedium)
TextStyle(fontSize: AppDimens.fontSizeLarge)
```

---

## 与Android对比

### Android

```xml
<!-- res/values/strings.xml -->
<resources>
    <string name="app_name">玩安卓</string>
    <string name="login_title">登录</string>
</resources>

<!-- res/values/colors.xml -->
<resources>
    <color name="primary">#2196F3</color>
</resources>
```

```kotlin
// 使用
textView.text = getString(R.string.app_name)
val color = ContextCompat.getColor(this, R.color.primary)
```

### Flutter

```json
// assets/config/strings_zh.json
{
  "app": { "name": "玩安卓" },
  "login": { "title": "登录" }
}
```

```dart
// 使用
Text(AppStrings.appName)
Container(color: AppColors.primary)
```

---

## 实际改造示例

### 示例1: 登录页面

#### 改造前
```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("登录"),  // 硬编码
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),  // 硬编码
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "用户名",  // 硬编码
                hintText: "请输入用户名",  // 硬编码
              ),
            ),
            SizedBox(height: 16.0),  // 硬编码
            ElevatedButton(
              onPressed: () {},
              child: Text("登录", style: TextStyle(fontSize: 16.0)),  // 硬编码
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 改造后
```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.loginTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: AppStrings.loginUsername,
                hintText: AppStrings.loginUsernameHint,
              ),
            ),
            SizedBox(height: AppDimens.paddingMedium),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                AppStrings.loginButton,
                style: TextStyle(fontSize: AppDimens.fontSizeLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 示例2: 错误处理

#### 改造前
```dart
// 硬编码的错误信息
showSnackBar("网络连接失败，请检查网络设置");
showSnackBar("登录已过期，请重新登录");
```

#### 改造后
```dart
// 使用资源文件
showSnackBar(AppStrings.networkErrorConnection);
showSnackBar(AppStrings.networkError401);
```

---

## 高级用法

### 1. 支持多语言

#### 目录结构
```
assets/config/
├── strings_zh.json    # 中文
├── strings_en.json    # 英文
└── strings_ja.json    # 日文
```

#### 配置类扩展
```dart
class AppStrings {
  static String _language = 'zh';  // 默认中文

  static void setLanguage(String language) {
    _language = language;
    _strings = null;  // 清除缓存
    init();  // 重新加载
  }

  static Future<void> init() async {
    String file = 'assets/config/strings_$_language.json';
    _strings ??= await _loadJson(file);
  }
}

// 使用
AppStrings.setLanguage('en');  // 切换为英文
AppStrings.setLanguage('zh');  // 切换为中文
```

---

### 2. 主题适配

```dart
class AppStyles {
  // 根据主题动态获取颜色
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }

  // 统一的文本样式
  static TextStyle getHeadlineStyle(BuildContext context) {
    return TextStyle(
      fontSize: AppDimens.fontSizeXlarge,
      color: Theme.of(context).textTheme.headline6?.color,
      fontWeight: FontWeight.bold,
    );
  }

  // 统一的按钮样式
  static ButtonStyle getPrimaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.paddingLarge,
        vertical: AppDimens.paddingMedium,
      ),
      textStyle: TextStyle(
        fontSize: AppDimens.fontSizeLarge,
      ),
    );
  }
}
```

---

### 3. 代码生成（进阶）

使用 `build_runner` 自动生成常量类：

#### 1. 添加依赖
```yaml
dependencies:
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.0
  json_serializable: ^6.6.2
```

#### 2. 创建模型类
```dart
import 'package:json_annotation/json_annotation.dart';

part 'app_strings.g.dart';

@JsonSerializable()
class AppStringsModel {
  final Map<String, dynamic> app;
  final Map<String, dynamic> common;
  final Map<String, dynamic> login;

  AppStringsModel({
    required this.app,
    required this.common,
    required this.login,
  });

  factory AppStringsModel.fromJson(Map<String, dynamic> json) =>
      _$AppStringsModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppStringsModelToJson(this);
}
```

#### 3. 运行生成
```bash
flutter pub run build_runner build
```

---

## 最佳实践

### ✅ 推荐做法

1. **统一命名规范**
   ```dart
   // 字符串: camelCase
   AppStrings.loginButton

   // 颜色: camelCase with Color后缀
   AppColors.primaryColor

   // 尺寸: camelCase
   AppDimens.paddingMedium
   ```

2. **分层组织**
   ```
   config/
   ├── strings/    # 字符串
   ├── colors/     # 颜色
   ├── dimens/     # 尺寸
   └── styles/     # 样式
   ```

3. **使用类型安全的方法**
   ```dart
   // ✅ 推荐：提供快捷方法
   static String get loginTitle => direct['login']['title'];

   // ❌ 不推荐：每次都从Map读取
   static String loginTitle => direct['login']['title'];
   ```

4. **初始化检查**
   ```dart
   static Map<String, dynamic> get direct {
     if (_strings == null) {
       throw Exception('未初始化！');
     }
     return _strings!;
   }
   ```

### ❌ 避免的做法

1. **过度嵌套**
   ```dart
   // ❌ 太深
   AppStrings.of(context)['login']['form']['username']['hint']

   // ✅ 提供快捷方法
   AppStrings.loginUsernameHint
   ```

2. **类型转换错误**
   ```dart
   // ❌ 可能抛出异常
   final value = direct['dimens']['padding'] as double

   // ✅ 安全转换
   final value = direct['dimens']['padding']?.toDouble() ?? 16.0;
   ```

3. **忘记初始化**
   ```dart
   void main() {
     runApp(MyApp());  // ❌ 忘记初始化
   }

   void main() async {
     await AppResources.init();  // ✅ 正确
     runApp(MyApp());
   }
   ```

---

## 迁移步骤

### 逐步迁移计划

#### 第1步：创建配置文件
```bash
mkdir -p assets/config
# 创建 strings_zh.json, colors.json, dimens.json
```

#### 第2步：创建资源类
```dart
// lib/resource/app_resources.dart
```

#### 第3步：修改 main.dart
```dart
void main() async {
  await AppResources.init();
  runApp(MyApp());
}
```

#### 第4步：逐步替换硬编码
```dart
// 从最常用的开始
"登录" → AppStrings.loginTitle
Color(0xFF2196F3) → AppColors.primary
16.0 → AppDimens.paddingMedium
```

#### 第5步：测试验证
```bash
flutter test
flutter run
```

---

## 性能优化

### 缓存机制
```dart
class AppStrings {
  static Map<String, dynamic>? _cache;

  static Future<void> init() async {
    _cache ??= await _loadJson();
  }

  // 只加载一次，后续从内存读取
}
```

### 懒加载
```dart
class AppStrings {
  static String _appName = '';

  static String get appName {
    if (_appName.isEmpty) {
      _loadAppName();
    }
    return _appName;
  }
}
```

---

## 故障排查

### 问题1: 找不到配置文件

**错误**: `Unable to load asset: assets/config/strings_zh.json`

**解决**:
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/config/  # ✅ 确保包含此行
```

### 问题2: 类型转换错误

**错误**: `type 'String' is not a subtype of type 'double'`

**解决**:
```dart
// 添加 .toDouble()
final value = direct['dimens']['padding']?.toDouble() ?? 16.0;
```

### 问题3: Hot Reload 不生效

**原因**: 配置文件修改后需要完全重启

**解决**:
```bash
# Hot Restart (不是 Hot Reload)
# 或完全重新运行
flutter run
```

---

## 总结

### 推荐方案选择

| 项目规模 | 推荐方案 | 原因 |
|----------|----------|------|
| 小型 | Dart常量类 | 简单直接 |
| 中型 | **JSON+代码生成** | 平衡灵活和性能 |
| 大型 | **JSON+国际化** | 支持多语言 |

### 关键要点

✅ 配置文件与代码分离
✅ 使用 init() 统一初始化
✅ 提供类型安全的快捷方法
✅ 支持动态加载和国际化
✅ 类似Android的资源管理

---

**文档版本**: 1.0
**更新日期**: 2025年2月6日
**适用版本**: Flutter 3.0+
