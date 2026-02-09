# 架构说明文档

本文档详细说明项目的整体架构、设计模式、目录结构和最佳实践。

## 目录

1. [项目概述](#项目概述)
2. [技术栈](#技术栈)
3. [架构设计](#架构设计)
4. [目录结构](#目录结构)
5. [核心模块](#核心模块)
6. [设计模式](#设计模式)
7. [状态管理](#状态管理)
8. [路由管理](#路由管理)
9. [最佳实践](#最佳实践)

---

## 项目概述

### 项目简介

GetX Study 是一个基于 Flutter 和 GetX 框架的移动应用，集成了玩安卓 API 的内容展示功能。

### 主要功能

- 📱 **首页**：轮播图、文章列表、下拉刷新、上拉加载
- 🔍 **搜索**：热搜关键词、文章搜索
- 🏗️ **项目**：项目分类、项目列表
- 📰 **公众号**：公众号列表、文章浏览
- 🌳 **体系**：知识体系树、体系文章
- 👤 **我的**：登录注册、收藏管理、积分排行
- 🌐 **WebView**：H5 页面展示、与 JS 交互

---

## 技术栈

### 核心框架

| 技术 | 版本 | 用途 |
|------|------|------|
| Flutter | 3.24+ | UI 框架 |
| Dart | 3.0+ | 编程语言 |
| GetX | ^4.6.6 | 状态管理、路由、依赖注入 |

### 网络请求

| 技术 | 版本 | 用途 |
|------|------|------|
| Dio | ^5.9.0 | HTTP 客户端 |
| Retrofit | ^4.9.0 | REST API 客户端 |
| dio_cache_interceptor | ^3.5.1 | 网络缓存 |

### UI 组件

| 技术 | 版本 | 用途 |
|------|------|------|
| cupertino_icons | - | iOS 风格图标 |
| pull_to_refresh | ^2.0.0 | 下拉刷新 |
| cached_network_image | ^3.4.1 | 图片缓存 |
| flutter_easyloading | ^3.0.0 | Loading 提示 |
| share_plus | ^9.0.0 | 分享功能 |
| marqueer | ^2.3.1 | 跑马灯效果 |

### 数据存储

| 技术 | 版本 | 用途 |
|------|------|------|
| shared_preferences | ^2.3.3 | 本地存储 |
| flutter_secure_storage | ^9.2.4 | 加密存储 |

### 工具库

| 技术 | 版本 | 用途 |
|------|------|------|
| json_serializable | ^6.7.1 | JSON 序列化 |
| lpinyin | ^2.0.3 | 拼音转换 |
| webview_flutter | ^4.13.0 | WebView |

---

## 架构设计

### 整体架构

项目采用 **分层架构 + MVVM 模式**：

```
┌─────────────────────────────────────────────┐
│              Presentation Layer             │
│  (Pages、Widgets、Components、Animations)   │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────┴──────────────────────────┐
│              Business Logic Layer           │
│           (Controllers、ViewModels)          │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────┴──────────────────────────┐
│               Data Layer                    │
│      (Repositories、API、Entities)          │
└─────────────────────────────────────────────┘
```

### 架构原则

1. **单一职责原则 (SRP)**
   - Controller 只负责业务逻辑
   - View 只负责 UI 渲染
   - Repository 只负责数据获取

2. **依赖倒置原则 (DIP)**
   - 上层不依赖下层，都依赖抽象
   - 通过接口定义契约

3. **开闭原则 (OCP)**
   - 对扩展开放，对修改关闭
   - 使用继承和组合实现功能扩展

4. **KISS 原则**
   - 保持简单直接
   - 避免过度设计

---

## 目录结构

```
lib/
├── account_manager/          # 账户管理
│   └── account_manager.dart
├── app_service/             # 应用服务
│   ├── account_service.dart # 账户服务（单例）
│   └── theme_service.dart   # 主题服务（单例）
├── base/                    # 基础类
│   ├── base_controller.dart         # 控制器基类
│   ├── base_refresh_controller.dart # 刷新控制器基类
│   ├── get_bind_widget.dart         # GetX 绑定组件
│   ├── interface.dart               # 接口定义
│   ├── pure_get_cupertino_app.dart  # GetX Cupertino 应用
│   ├── resign_first_responder.dart  # 键盘响应处理
│   └── resign_first_view.dart       # 自动收起键盘的组件
├── entity/                  # 数据实体
│   ├── account_info_entity.dart
│   ├── article_info_entity.dart
│   ├── banner_entity.dart
│   ├── coin_rank_entity.dart
│   ├── hot_key_entity.dart
│   ├── my_coin_history_entity.dart
│   ├── page_entity.dart
│   ├── tab_entity.dart
│   ├── base_entity.dart
│   ├── common_response.dart
│   ├── pageable.dart
│   └── *.g.dart                      # JSON 序列化生成文件
├── enum/                   # 枚举定义
│   ├── collect_action_type.dart
│   ├── main_tag_type.dart
│   ├── my.dart
│   ├── response_status.dart
│   ├── scroll_view_action_type.dart
│   ├── tag_type.dart
│   └── theme_type.dart
├── extension/               # 扩展方法
│   ├── future_extension.dart
│   ├── get_route_extension.dart
│   ├── string_extension.dart
│   └── theme_data_extension.dart
├── generated/              # 生成文件
│   ├── assets.dart                # 资源路径
│   └── json/                     # JSON 序列化
├── http_client/            # HTTP 客户端
│   ├── request_client.dart        # Retrofit API 定义
│   ├── login_client.dart          # 登录 API
│   └── *.g.dart                   # 生成文件
├── http_util/              # HTTP 工具
│   ├── api.dart                   # API 地址
│   ├── http_util.dart             # HTTP 工具类
│   ├── plugins.dart               # Dio 插件
│   └── http_status.dart           # HTTP 状态码
├── i18n/                   # 国际化
│   └── localized_strings.dart
├── logger/                 # 日志
│   └── logger.dart
├── pages/                  # 页面
│   ├── common/                    # 公共页面组件
│   │   ├── countdown_circle.dart  # 倒计时圆圈
│   │   ├── empty_view.dart        # 空视图
│   │   ├── error_view.dart        # 错误视图
│   │   ├── floating_widget.dart   # 浮动按钮
│   │   ├── info_cell.dart         # 文章列表项
│   │   ├── keep_alive_wrapper.dart # 页面缓存
│   │   ├── loading_view.dart      # 加载视图
│   │   ├── marquee_label.dart     # 跑马灯标签
│   │   ├── my_list_view.dart      # 自定义列表
│   │   ├── refresh_header_footer.dart # 下拉刷新组件
│   │   ├── status_view.dart       # 状态视图
│   │   ├── tree_cell.dart         # 体系列表项
│   │   └── unknown_page.dart      # 未知页面
│   ├── coin_rank/                # 积分排行
│   │   ├── binding/
│   │   ├── controller/
│   │   └── view/
│   ├── home/                     # 首页
│   │   ├── binding/
│   │   ├── controller/
│   │   ├── repository/
│   │   └── view/
│   ├── launch/                   # 启动页
│   │   ├── splash_page.dart
│   │   └── welcome_page.dart
│   ├── main/                     # 主页
│   │   ├── binding/
│   │   ├── controller/
│   │   └── view/
│   ├── my/                       # 我的
│   │   ├── binding/
│   │   ├── controller/
│   │   └── view/
│   │       ├── login_page.dart
│   │       ├── my_page.dart
│   │       ├── my_collect_page.dart
│   │       ├── my_coin_history_page.dart
│   │       ├── register_page.dart
│   │       └── theme_setting_page.dart
│   ├── tree/                     # 体系
│   │   ├── bindings/
│   │   ├── controller/
│   │   └── view/
│   └── web/                      # WebView
│       ├── binding/
│       ├── controller/
│       └── view/
├── resource/                # 资源配置
│   └── app_resources.dart         # 应用资源（字符串、颜色、尺寸）
├── routes/                 # 路由
│   ├── routes.dart                # 路由定义
│   ├── getx_router_observer.dart  # 路由观察者
│   ├── history_router_observer.dart # 历史路由观察者
│   └── middleware/                # 中间件
│       ├── login_middleware.dart  # 登录中间件
│       └── web_middleware.dart    # WebView 中间件
├── util/                   # 工具类
│   └── error_handler.dart         # 错误处理
├── widgets/                # 自定义组件
│   ├── animated_button.dart       # 动画按钮
│   ├── staggered_animation.dart  # 交错动画
│   └── page_transitions.dart      # 页面过渡
├── main.dart               # 应用入口
└── my_app.dart             # 应用配置
```

---

## 核心模块

### 1. 应用服务层 (AppService)

#### AccountService

账户服务，使用单例模式管理用户登录状态和账户信息。

```dart
class AccountService extends GetxService {
  static AccountService get find => Get.find<AccountService>();

  final RxBool isLogin = false.obs;
  final Rx<AccountInfoEntity?> accountInfo = Rx<AccountInfoEntity?>(null);

  Future<void> login({required String username, required String password}) async;
  Future<void> logout() async;
  Future<void> autoLogin() async;
  Future<bool> saveNotFirstLaunch() async;
}
```

#### ThemeService

主题服务，管理应用主题切换。

```dart
class ThemeService extends GetxService {
  static ThemeService get find => Get.find<ThemeService>();

  final Rx<ThemeType> rxCurrentThemeType = ThemeType.system.obs;
  CupertinoThemeData get themeData;

  void switchTheme(ThemeType type);
}
```

### 2. 控制器层 (Controller)

#### BaseController

所有控制器的基类，定义了通用的状态和行为。

```dart
abstract class BaseController extends GetxController
    implements IRetry, IEmptyTap {
  ResponseStatus status = ResponseStatus.loading;

  void retry();
  void emptyTap();
}
```

#### BaseRefreshController

带刷新功能的控制器基类，处理下拉刷新和上拉加载。

```dart
abstract class BaseRefreshController<R extends IRepository, T>
    extends BaseController {
  late R request;
  late RefreshController refreshController;
  late int page;
  late int initPage;
  List<T> dataSource = [];

  Future<void> onRefresh();
  Future<void> onLoadMore();
  Future<void> aRequest({required ScrollViewActionType type});
}
```

### 3. 数据层 (Repository)

#### IRepository

数据仓库接口，定义数据获取规范。

```dart
abstract class IRepository {
  Future<dynamic> getArticleList({required int page});
  Future<dynamic> getBanner();
  // ... 其他数据获取方法
}
```

#### 具体实现

```dart
class HomeRepository implements IRepository {
  final RequestClient _client = requestClient;

  @override
  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getArticleList({
    required int page,
  }) async {
    return await _client.getArticleList(page);
  }
}
```

### 4. 视图层 (View)

#### StatusView

统一的状态视图组件，根据数据状态显示不同的 UI。

```dart
StatusView<T extends BaseController>(
  tag: String?,
  contentBuilder: Widget Function(T controller),
  loadingView: Widget?,
  errorViewBuilder: Widget Function(T)?,
  emptyViewBuilder: Widget Function(T)?,
)
```

#### 状态类型

| 状态 | 说明 |
|------|------|
| ResponseStatus.loading | 加载中 |
| ResponseStatus.fail | 加载失败 |
| ResponseStatus.successNoData | 加载成功但无数据 |
| ResponseStatus.successHasContent | 加载成功有数据 |

---

## 设计模式

### 1. 单例模式 (Singleton)

**应用场景：** 全局唯一的服务

```dart
class AccountService extends GetxService {
  static AccountService get find => Get.find<AccountService>();
}

// 使用
final accountService = AccountService.find;
```

### 2. 工厂模式 (Factory)

**应用场景：** 页面创建、依赖注入

```dart
GetPage(
  name: Routes.home,
  page: () => const HomePage(),
  binding: HomeBinding(),
)
```

### 3. 观察者模式 (Observer)

**应用场景：** 状态响应式更新

```dart
// Controller
final RxBool isLoading = false.obs;

// View
Obx(() => isLoading.value ? CircularProgressIndicator() : Text('数据'))
```

### 4. 仓储模式 (Repository)

**应用场景：** 数据访问抽象

```dart
abstract class IRepository {
  Future<dynamic> getData();
}

class HomeRepository implements IRepository {
  @override
  Future<dynamic> getData() {
    return requestClient.getData();
  }
}
```

### 5. 策略模式 (Strategy)

**应用场景：** 不同的刷新策略

```dart
switch (type) {
  case ScrollViewActionType.refresh:
    // 刷新逻辑
    break;
  case ScrollViewActionType.loadMore:
    // 加载更多逻辑
    break;
}
```

### 6. 适配器模式 (Adapter)

**应用场景：** 网络请求适配

```dart
class RequestClient {
  factory RequestClient(Dio dio, {String baseUrl}) = _RequestClient;
}
```

---

## 状态管理

### GetX 状态管理

项目使用 GetX 进行状态管理，支持以下几种方式：

#### 1. Obx - 响应式状态

最简单的响应式状态更新方式。

```dart
// Controller
final count = 0.obs;

// View
Obx(() => Text('${controller.count}'))
```

#### 2. GetX - 精细控制

可以更精细地控制更新时机。

```dart
// Controller
final count = 0.obs;

// View
GetX<HomeController>(
  builder: (controller) => Text('${controller.count}'),
)
```

#### 3. GetBuilder - 手动更新

需要手动调用 `update()` 来更新 UI。

```dart
// Controller
int count = 0;
void increment() {
  count++;
  update();
}

// View
GetBuilder<HomeController>(
  builder: (controller) => Text('${controller.count}'),
)
```

#### 4. GetView - 简化访问

不需要 `Get.find()` 即可访问 Controller。

```dart
class MyPage extends GetView<MyController> {
  @override
  Widget build(BuildContext context) {
    return Text('${controller.data}');
  }
}
```

### 依赖注入

使用 GetX 的依赖注入管理 Controller 生命周期。

#### Binding

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => HomeRepository());
  }
}
```

#### 路由中注入

```dart
GetPage(
  name: Routes.home,
  page: () => const HomePage(),
  binding: HomeBinding(),
)
```

---

## 路由管理

### 路由定义

所有路由在 `Routes` 类中集中定义。

```dart
abstract class Routes {
  static const home = '/home';
  static const login = '/login';
  static const web = '/web';
  // ...
}
```

### 页面配置

使用 `GetPage` 配置路由信息。

```dart
GetPage(
  name: Routes.home,              // 路由名称
  page: () => const HomePage(),    // 页面构建
  binding: HomeBinding(),          // 依赖注入
  transition: Transition.fadeIn,   // 过渡动画
  transitionDuration: Duration(milliseconds: 300),
  middlewares: [LoginMiddleware()], // 中间件
)
```

### 路由跳转

```dart
// 普通跳转
Get.toNamed(Routes.home);

// 带参数跳转
Get.toNamed(Routes.web, arguments: webLoadInfo);

// 替换当前页面
Get.offNamed(Routes.home);

// 清空栈并跳转
Get.offAllNamed(Routes.main);

// 获取返回参数
final result = await Get.toNamed(Routes.login);
```

### 中间件

#### LoginMiddleware - 登录拦截

```dart
class LoginMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return AccountService.find.isLogin
        ? super.redirect(route)
        : const RouteSettings(name: Routes.login);
  }
}
```

---

## 最佳实践

### 1. 命名规范

| 类型 | 命名规则 | 示例 |
|------|---------|------|
| 文件名 | 小写加下划线 | `home_page.dart` |
| 类名 | 大驼峰 | `HomePage` |
| 变量名 | 小驼峰 | `userName` |
| 常量名 | 小驼峰 | `maxRetry` |
| 私有成员 | 下划线前缀 | `_privateMethod` |
| 回调方法 | on + 动作 | `onPressed`、`onTap` |

### 2. 文件组织

#### 按功能分组

每个功能模块包含以下目录：

```
pages/feature_name/
├── binding/        # 依赖注入
├── controller/     # 控制器
├── repository/     # 数据仓库
└── view/          # 视图
```

#### 共享组件放在 common/

```
pages/common/
├── loading_view.dart
├── error_view.dart
├── empty_view.dart
└── status_view.dart
```

### 3. 代码复用

#### 使用基类

```dart
class HomeController extends BaseRefreshController<HomeRepository, ArticleInfoDatas> {
  // 自动继承刷新、分页等功能
}
```

#### 使用组件

```dart
StatusView<HomeController>(
  tag: 'home',
  contentBuilder: (controller) => ListView(...),
)
```

### 4. 错误处理

#### 统一错误处理

```dart
try {
  response = await request.getData();
} catch (e) {
  ErrorHandler.showToast(e.toString());
  status = ResponseStatus.fail;
  update();
}
```

#### 网络错误处理

在 `HttpUtils._handleDioError` 中统一处理网络错误。

### 5. 资源管理

#### 使用 AppResources

```dart
// 定义
class AppStrings {
  static String get loginTitle => _strings['app_name'] ?? '登录';
}

// 使用
Text(AppStrings.loginTitle)
```

### 6. 日志规范

```dart
import 'package:getx_study/logger/logger.dart' as logger;

logger.d('调试信息');
logger.i('普通信息');
logger.w('警告信息');
logger.e('错误信息');
```

### 7. 代码生成

#### JSON 序列化

```dart
@JsonSerializable()
class User {
  final String name;
  final int age;

  User(this.name, this.age);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

#### 运行生成命令

```bash
flutter pub run build_runner watch
```

---

## 性能优化

### 1. 图片缓存

使用 `cached_network_image` 缓存网络图片。

```dart
CachedNetworkImage(
  imageUrl: model.envelopePic,
  placeholder: (context, url) => Image.asset(Assets.assetsImagesPlaceholder),
)
```

### 2. 列表优化

- 使用 `ListView.builder` 而非 `ListView`
- 使用 `const` 构造函数
- 避免在 `build` 中创建对象

### 3. 状态更新优化

- 使用 `Obx` 替代 `GetX`（更轻量）
- 只更新需要更新的部分
- 避免在 `build` 中调用 `update()`

### 4. 网络缓存

使用 `dio_cache_interceptor` 缓存响应。

```dart
final data = await HttpUtils.get(
  api: "/article/list/0/json",
  enableCache: true,
);
```

### 5. 页面缓存

使用 `AutomaticKeepAliveClientMixin` 保持页面状态。

```dart
class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
}
```

---

## 安全建议

### 1. 敏感数据存储

使用 `flutter_secure_storage` 存储敏感信息（如密码）。

```dart
const _secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
);
```

### 2. Token 管理

- Token 存储在安全存储中
- 自动处理 Token 过期
- 401 错误自动跳转登录

### 3. 数据验证

```dart
if (controller.userNameTextFiledController.text.isEmpty) {
  ErrorHandler.showToast('用户名不能为空');
  return;
}
```

---

## 测试建议

### 单元测试

```dart
test('Calculator adds two numbers', () {
  final calculator = Calculator();
  expect(calculator.add(1, 2), equals(3));
});
```

### Widget 测试

```dart
testWidgets('HomePage displays title', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('首页'), findsOneWidget);
});
```

### 集成测试

```dart
testWidgets('Login flow', (tester) async {
  // 输入用户名密码
  // 点击登录
  // 验证跳转
});
```

---

## 相关文档

- [API 文档](./API_DOCUMENTATION.md)
- [微交互效果指南](./MICRO_INTERACTIONS_GUIDE.md)
- [常量管理指南](./CONSTANTS_MANAGEMENT.md)
