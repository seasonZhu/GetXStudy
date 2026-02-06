# 常量管理 - 快速开始

## 🎯 快速理解

### Android vs Flutter 对比

#### Android 的方式
```xml
<!-- res/values/strings.xml -->
<resources>
    <string name="app_name">玩安卓</string>
</resources>
```

```kotlin
// 使用
textView.text = getString(R.string.app_name)
```

#### Flutter 的方式（我们的方案）
```json
// assets/config/strings_zh.json
{
  "app": { "name": "玩安卓" }
}
```

```dart
// 使用
Text(AppStrings.appName)
```

---

## 📁 文件结构

```
你的项目/
├── assets/
│   └── config/
│       ├── strings_zh.json    ← 字符串配置（类似 strings.xml）
│       ├── colors.json        ← 颜色配置（类似 colors.xml）
│       └── dimens.json        ← 尺寸配置（类似 dimens.xml）
├── lib/
│   └── resource/
│       └── app_resources.dart  ← 资源加载器（类似 R.java）
└── lib/
    └── main.dart               ← 启动时初始化
```

---

## 🚀 3步上手

### 第1步：配置文件已创建 ✅

```json
// assets/config/strings_zh.json
{
  "login": {
    "title": "登录",
    "button": "登录"
  }
}
```

### 第2步：初始化（已完成）✅

```dart
// lib/main.dart
void main() async {
  await AppResources.init();  // ← 已添加
  runApp(MyApp());
}
```

### 第3步：开始使用 ✅

```dart
// ❌ 之前
Text("登录")

// ✅ 现在
Text(AppStrings.loginTitle)

// ❌ 之前
Color(0xFF2196F3)

// ✅ 现在
AppColors.primary

// ❌ 之前
EdgeInsets.all(16.0)

// ✅ 现在
EdgeInsets.all(AppDimens.paddingMedium)
```

---

## 📖 实际例子

### 登录页面改造

#### 改造前（硬编码）
```dart
AppBar(
  title: Text("登录"),  // 硬编码
)
TextField(
  decoration: InputDecoration(
    labelText: "用户名",  // 硬编码
  ),
)
ElevatedButton(
  child: Text("登录"),  // 硬编码
)
```

#### 改造后（配置文件）
```dart
AppBar(
  title: Text(AppStrings.loginTitle),
)
TextField(
  decoration: InputDecoration(
    labelText: AppStrings.loginUsername,
  ),
)
ElevatedButton(
  child: Text(AppStrings.loginButton),
)
```

---

## 🔧 常用快捷方法

### 字符串
```dart
// 通用
AppStrings.loading
AppStrings.success
AppStrings.error
AppStrings.confirm
AppStrings.cancel

// 登录相关
AppStrings.loginTitle
AppStrings.loginUsername
AppStrings.loginPassword
AppStrings.loginButton

// 网络错误
AppStrings.networkErrorTimeout
AppStrings.networkErrorConnection
AppStrings.networkError401
```

### 颜色
```dart
// 主题色
AppColors.primary
AppColors.secondary
AppColors.success
AppColors.warning
AppColors.error

// 灰度
AppColors.grey50
AppColors.grey100
...
AppColors.grey900
```

### 尺寸
```dart
// 间距
AppDimens.paddingTiny      // 4.0
AppDimens.paddingSmall     // 8.0
AppDimens.paddingMedium    // 16.0
AppDimens.paddingLarge     // 24.0

// 字体
AppDimens.fontSizeSmall    // 12.0
AppDimens.fontSizeMedium   // 14.0
AppDimens.fontSizeLarge    // 16.0

// 组件
AppDimens.buttonHeight     // 44.0
AppDimens.inputHeight      // 48.0
```

---

## 💡 修改配置

### 修改字符串

1. 打开 `assets/config/strings_zh.json`
2. 修改内容
3. Hot Restart（不是 Hot Reload）

```json
{
  "login": {
    "title": "登录",  // ← 改成"用户登录"
    "button": "登录"   // ← 改成"立即登录"
  }
}
```

### 添加新字符串

```json
{
  "new_section": {
    "new_key": "新的字符串"
  }
}
```

```dart
// 使用
Text(AppStrings.direct['new_section']['new_key'])
```

---

## 🎨 进阶用法

### 1. 创建主题样式

```dart
class AppStyles {
  static ButtonStyle primaryButton(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.paddingLarge,
        vertical: AppDimens.paddingMedium,
      ),
      textStyle: TextStyle(
        fontSize: AppDimens.fontSizeLarge,
        color: AppColors.white,
      ),
    );
  }
}

// 使用
ElevatedButton(
  style: AppStyles.primaryButton(context),
  child: Text(AppStrings.confirm),
)
```

### 2. 统一的错误处理

```dart
void showError(String errorKey) {
  String message = AppStrings.direct['network'][errorKey];
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

// 使用
showError('error_timeout');  // 显示 "网络连接超时"
showError('error_401');     // 显示 "登录已过期"
```

---

## ⚠️ 注意事项

### 1. 必须先初始化

```dart
void main() async {
  await AppResources.init();  // ← 必须！否则会报错
  runApp(MyApp());
}
```

### 2. 配置文件修改后需要完全重启

- ❌ Hot Reload - 不生效
- ✅ Hot Restart - 生效
- ✅ 完全重新运行 - 生效

### 3. 类型安全

```dart
// ✅ 推荐：使用快捷方法（自动类型转换）
AppColors.primary

// ⚠️ 手动访问需要自己转换
Color(AppColors.direct['colors']['primary'])
```

---

## 📚 完整文档

详细内容请查看：
- [完整指南](docs/CONSTANTS_MANAGEMENT.md)
- [使用示例](examples/constants_migration_example.dart)
- [迁移对比](examples/constants_comparison.dart)

---

## 🤔 常见问题

**Q: 为什么不用纯Dart类？**
A: JSON配置文件更灵活，修改后不需要重新编译，类似Android的res文件夹。

**Q: 性能会受影响吗？**
A: 不会。资源在启动时一次性加载到内存，后续访问都是内存读取。

**Q: 如何支持多语言？**
A: 创建 `strings_en.json`，初始化时根据语言加载不同文件。

**Q: 可以动态修改配置吗？**
A: 可以。修改JSON后Hot Restart即可生效，无需重新编译。

---

**快速上手完成！** 🎉

现在你可以在代码中使用：
- `AppStrings.xxx` - 字符串
- `AppColors.xxx` - 颜色
- `AppDimens.xxx` - 尺寸

就像Android的 `R.string.xxx`、`R.color.xxx` 一样！
