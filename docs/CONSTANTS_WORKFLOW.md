# 文本常量管理 - 标准工作流程

## 📋 添加新文本的标准流程

### 流程图

```
1. 添加到JSON配置
        ↓
2. 添加快捷访问方法（可选）
        ↓
3. 在代码中使用
        ↓
4. Hot Restart 测试
```

---

## 🎯 详细步骤

### 步骤 1: 添加到 JSON 配置

**文件**: `assets/config/strings_zh.json`

#### 1.1 确定分类

找到合适的分类，如果没有就创建一个：

```json
{
  "app": { ... },        // 应用相关
  "common": { ... },     // 通用文本
  "login": { ... },      // 登录相关
  "home": { ... },       // 首页相关
  "my": { ... },         // 我的页面
  "网络错误": { ... },    // 错误信息
  "新分类": {            // ← 添加新分类
  }
}
```

#### 1.2 添加键值对

```json
{
  "newCategory": {
    "newKey": "新的文本内容",
    "anotherKey": "另一个文本"
  }
}
```

**命名规范**:
- 使用 camelCase: `loginButton`, `networkErrorTimeout`
- 见名知意: `userName`, `passwordHint`
- 按功能分组: `login`, `home`, `my`

---

### 步骤 2: 添加快捷访问方法（可选）

**文件**: `lib/resource/app_resources.dart`

#### 2.1 找到对应的位置

```dart
class AppStrings {
  // ... 现有代码 ...

  // ========== 新分类 ==========
  static String get newKey => direct['newCategory']['newKey'];
  static String get anotherKey => direct['newCategory']['anotherKey'];
}
```

#### 2.2 或者直接使用（不添加快捷方法）

```dart
// 也可以不添加快捷方法，直接这样用：
Text(AppStrings.direct['newCategory']['newKey'])
```

**对比**:
```dart
// ✅ 有快捷方法 - 推荐，有代码补全
Text(AppStrings.loginTitle)

// ⚠️ 无快捷方法 - 需要手动输入，容易出错
Text(AppStrings.direct['login']['title'])
```

---

### 步骤 3: 在代码中使用

#### 3.1 确保已导入

```dart
import 'package:getx_study/resource/app_resources.dart';
```

#### 3.2 使用文本

```dart
// 方式1: 使用快捷方法（推荐）
Text(AppStrings.loginTitle)
ElevatedButton(
  child: Text(AppStrings.confirm),
)

// 方式2: 直接访问
Text(AppStrings.direct['login']['title'])

// 方式3: 动态访问
final strings = AppStrings.of(context);
Text(strings['login']['title'])
```

---

### 步骤 4: 测试

```bash
# 重要：修改JSON后需要 Hot Restart
# Hot Reload 不生效！
```

---

## 📝 实际示例

### 示例1: 添加一个新的提示文本

#### 场景
在"我的"页面添加一个新的菜单项"我的设置"

#### 步骤

**1. 更新 JSON:**
```json
{
  "my": {
    "title": "我的",
    "coins": "我的积分",
    "collect": "我的收藏",
    "settings": "我的设置"  // ← 新增
  }
}
```

**2. 添加快捷方法:**
```dart
// lib/resource/app_resources.dart
class AppStrings {
  // ...

  // My
  static String get myTitle => direct['my']['title'];
  static String get myCoins => direct['my']['coins'];
  static String get myCollect => direct['my']['collect'];
  static String get mySettings => direct['my']['settings'];  // ← 新增
}
```

**3. 使用:**
```dart
// lib/pages/my/view/my_page.dart
ListTile(
  title: Text(AppStrings.mySettings),
  trailing: Icon(Icons.settings),
)
```

---

### 示例2: 添加错误信息

#### 场景
添加一个新的错误提示："用户名或密码错误"

#### 步骤

**1. 更新 JSON:**
```json
{
  "login": {
    "title": "登录",
    "error_invalid": "用户名或密码错误"  // ← 新增
  }
}
```

**2. 添加快捷方法:**
```dart
static String get loginErrorInvalid => direct['login']['error_invalid'];
```

**3. 在 Controller 中使用:**
```dart
// lib/pages/my/controller/login_controller.dart
void login({required String username, required String password}) async {
  try {
    // ...
  } catch (e) {
    EasyLoading.showError(AppStrings.loginErrorInvalid);
  }
}
```

---

## 🔄 快速参考

### 常见分类和命名

| 分类 | 示例键名 | 示例值 |
|------|----------|--------|
| **通用** | `confirm`, `cancel`, `retry` | "确认", "取消", "重试" |
| **页面标题** | `xxxTitle` | "xxx页面" |
| **按钮** | `xxxButton` | "确定", "提交" |
| **输入提示** | `xxxHint` | "请输入xxx" |
| **错误信息** | `xxxError` | "xxx错误" |
| **成功信息** | `xxxSuccess` | "xxx成功" |
| **加载提示** | `xxxLoading` | "正在xxx..." |

### 命名规范

```dart
// 页面标题
homeTitle, loginTitle, myTitle

// 按钮
confirmButton, cancelButton, loginButton

// 提示信息
usernameHint, passwordHint, searchHint

// 状态
loading, success, error, failed

// 菜单项
myCoins, myCollect, mySettings

// 错误
loginFailed, networkErrorTimeout
```

---

## ✅ 检查清单

添加新文本时，确保：

- [ ] JSON 文件格式正确（逗号、大括号）
- [ ] 键名使用 camelCase
- [ ] 添加了快捷访问方法（推荐）
- [ ] 导入了 `app_resources.dart`
- [ ] 使用 `AppStrings.xxx` 访问
- [ ] Hot Restart 测试（不是 Hot Reload）

---

## 🚀 快速模板

### 复制这个模板

#### JSON 配置模板
```json
{
  "yourCategory": {
    "yourKey": "你的文本",
    "yourKeyButton": "按钮文本",
    "yourKeyHint": "提示文本",
    "yourKeySuccess": "成功提示",
    "yourKeyFailed": "失败提示"
  }
}
```

#### Dart 代码模板
```dart
// 1. 导入
import 'package:getx_study/resource/app_resources.dart';

// 2. 在 AppStrings 类中添加
// lib/resource/app_resources.dart
class AppStrings {
  // Your Category
  static String get yourKey => direct['yourCategory']['yourKey'];
  static String get yourKeyButton => direct['yourCategory']['yourKeyButton'];
}

// 3. 使用
Text(AppStrings.yourKey)
ElevatedButton(
  child: Text(AppStrings.yourKeyButton),
)
```

---

## 🎓 实战练习

### 练习1: 添加"删除成功"提示

**任务**: 在收藏页面添加删除成功的提示

**答案**:
```json
// 1. JSON
{
  "collect": {
    "title": "我的收藏",
    "deleteSuccess": "删除成功"  // ← 新增
  }
}

// 2. 快捷方法
static String get deleteSuccess => direct['collect']['deleteSuccess'];

// 3. 使用
EasyLoading.showSuccess(AppStrings.deleteSuccess);
```

---

### 练习2: 添加"加载失败"提示

**任务**: 添加一个通用的加载失败提示

**答案**:
```json
// 1. JSON
{
  "common": {
    "load_failed": "加载失败，请稍后重试"  // ← 新增
  }
}

// 2. 快捷方法
static String get loadFailed => direct['common']['load_failed'];

// 3. 使用
if (loadingFailed) {
  Text(AppStrings.loadFailed)
}
```

---

## 💡 最佳实践

### 1. 保持一致性

```dart
// ✅ 推荐：统一的命名
AppStrings.loginButton
AppStrings.registerButton
AppStrings.confirmButton

// ❌ 不推荐：混乱的命名
AppStrings.btnLogin
AppStrings.submitButton
AppStrings.ok
```

### 2. 使用快捷方法

```dart
// ✅ 推荐：有快捷方法
Text(AppStrings.loginTitle)

// ⚠️ 不推荐：每次都访问Map
Text(AppStrings.direct['login']['title'])
```

### 3. 分组管理

```json
{
  "login": {
    "title": "登录",
    "username": "用户名",
    "password": "密码"
  },
  "register": {
    "title": "注册",
    "username": "用户名",
    "password": "密码"
  }
}
```

### 4. 定期整理

- [ ] 删除未使用的文本
- [ ] 合并重复的文本
- [ ] 统一相似的表达

---

## 🔧 常见问题

**Q: 必须添加快捷方法吗？**
A: 不是必须的，但强烈推荐。好处：
- 有代码补全
- 避免拼写错误
- 更易重构

**Q: 如何知道是否已经存在某个文本？**
A:
```bash
# 搜索JSON文件
grep "你的文本" assets/config/strings_zh.json

# 搜索代码
grep "AppStrings\." lib/ -r
```

**Q: 修改JSON后需要重新编译吗？**
A: 不需要重新编译，但需要 Hot Restart

**Q: 可以动态修改语言吗？**
A: 可以，创建不同语言的JSON文件（如 strings_en.json），初始化时根据系统语言加载

---

## 📞 快速参考

```bash
# 1. 修改配置
vim assets/config/strings_zh.json

# 2. 添加快捷方法
vim lib/resource/app_resources.dart

# 3. 使用
# 在代码中: Text(AppStrings.yourKey)

# 4. 测试
# Hot Restart (不是 Hot Reload!)
```

---

**文档版本**: 1.0
**更新日期**: 2025年2月6日
**适用版本**: Flutter 3.0+
