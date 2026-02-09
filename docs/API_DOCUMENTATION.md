# API 文档

本文档详细说明项目中使用的网络请求 API、数据模型和客户端配置。

## 目录

1. [概述](#概述)
2. [基础配置](#基础配置)
3. [API 端点](#api-端点)
4. [数据模型](#数据模型)
5. [错误处理](#错误处理)
6. [使用示例](#使用示例)

---

## 概述

本项目使用玩安卓（WanAndroid）开放平台的 API，采用 Retrofit + Dio 进行网络请求。

### 技术栈

| 组件 | 版本/说明 |
|------|----------|
| Dio | ^5.9.0 - HTTP 客户端 |
| Retrofit | ^4.0.0 - REST API 客户端 |
| dio_cache_interceptor | ^3.5.1 - 网络缓存 |
| json_serializable | - JSON 序列化 |

### 基础 URL

```dart
// 开发环境
static const baseUrl = "https://www.wanandroid.com/";
```

---

## 基础配置

### 超时配置

```dart
const timeout = Duration(seconds: 60);
```

### 请求头

```dart
{
  HttpHeaders.cookieHeader: AccountService.find.cookieHeaderValue
}
```

### 缓存配置

```dart
static final _cacheOptions = CacheOptions(
  store: MemCacheStore(),
  policy: CachePolicy.request,
  hitCacheOnErrorExcept: [401, 403],
  maxStale: const Duration(days: 7),
  priority: CachePriority.high,
  allowPostMethod: false,
);
```

### 拦截器

```dart
interceptors.addAll([
  loggerPlugin,              // 日志记录
  networkActivityPlugin,     // 网络活动指示器
  responseInterceptorPlugin, // 响应拦截
]);
```

---

## API 端点

### 首页相关

#### 获取轮播图

```dart
@GET("banner/json")
Future<BaseEntity<List<BannerEntity>>> getBanner();
```

**响应示例：**
```json
{
  "data": [
    {
      "id": 1,
      "title": "标题",
      "desc": "描述",
      "type": 0,
      "url": "https://www.wanandroid.com/blog/show/0",
      "imagePath": "https://www.wanandroid.com/blogimgs/0.png"
    }
  ],
  "errorCode": 0,
  "errorMsg": ""
}
```

#### 获取首页文章列表

```dart
@GET("article/list/{page}/json")
Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getArticleList(
    @Path() int page);
```

**参数：**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | int | 是 | 页码，从 0 开始 |

#### 获取置顶文章

```dart
@GET("article/top/json")
Future<BaseEntity<List<ArticleInfoDatas>>> getTopArticleList();
```

---

### 搜索相关

#### 获取搜索热词

```dart
@GET("getSearchHotKey")
Future<BaseEntity<List<HotKeyEntity>>> getSearchHotKey();
```

#### 搜索文章

```dart
@POST("article/query/{page}/json")
Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> searchKeyword(
    @Path() int page,
    @Query("k") String keyword);
```

**参数：**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | int | 是 | 页码 |
| k | String | 是 | 搜索关键词 |

---

### 项目相关

#### 获取项目分类

```dart
@GET("project/tree/json")
Future<BaseEntity<List<TabEntity>>> getProjectTab();
```

#### 获取项目列表

```dart
@GET("project/list/{page}/json")
Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>>
    getCurrentProjectTabList(@Path() int page, @Query("cid") String id);
```

**参数：**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | int | 是 | 页码 |
| cid | String | 是 | 分类 ID |

---

### 公众号相关

#### 获取公众号列表

```dart
@GET("wxarticle/chapters/json")
Future<BaseEntity<List<TabEntity>>> getWXArticleTab();
```

#### 获取公众号文章

```dart
@GET("wxarticle/list/{id}/{page}/json")
Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>>
    getCurrentWXArticleTabList(@Path() String id, @Path() int page);
```

---

### 体系相关

#### 获取体系树

```dart
@GET("tree/json")
Future<BaseEntity<List<TabEntity>>> getTreeTab();
```

#### 获取体系下的文章

```dart
@GET("article/list/{id}/{page}/json")
Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getCurrentTreeTabList(
    @Path() String id,
    @Path() int page);
```

---

### 用户相关

#### 登录

```dart
@POST("user/login")
Future<BaseEntity<AccountInfoEntity>> login(
    @Query("username") String username,
    @Query("password") String password);
```

**参数：**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| username | String | 是 | 用户名 |
| password | String | 是 | 密码 |

**响应示例：**
```json
{
  "data": {
    "admin": false,
    "chapterTops": [],
    "collectIds": [],
    "email": "",
    "icon": "",
    "id": 1,
    "nickname": "用户昵称",
    "password": "",
    "publicName": "publicName",
    "token": "",
    "type": 0,
    "username": "用户名"
  },
  "errorCode": 0,
  "errorMsg": ""
}
```

#### 注册

```dart
@POST("user/register")
Future<BaseEntity<AccountInfoEntity>> register(
    @Query("username") String username,
    @Query("password") String password,
    @Query("repassword") String repassword);
```

#### 退出登录

```dart
@GET("user/logout/json")
Future<BaseEntity<Object?>> logout();
```

---

### 收藏相关

#### 收藏文章

```dart
@POST("lg/collect/{id}/json")
Future<BaseEntity<Object?>> collectAction(@Path() int originId);
```

#### 取消收藏

```dart
@POST("lg/uncollect_originId/{id}/json")
Future<BaseEntity<Object?>> unCollectAction(@Path() int originId);
```

#### 获取收藏列表

```dart
@GET("lg/collect/list/{page}/json")
Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getCollectArticleList(
    @Path() int page);
```

---

### 积分相关

#### 获取积分排行榜

```dart
@GET("coin/rank/{page}/json")
Future<BaseEntity<PageEntity<List<CoinRankDatas>>>> getCoinRankList(
    @Path() int page);
```

**响应示例：**
```json
{
  "data": {
    "curPage": 1,
    "datas": [
      {
        "coinCount": 10000,
        "level": 100,
        "rank": 1,
        "userId": 1,
        "username": "用户名"
      }
    ],
    "offset": 0,
    "over": false,
    "pageCount": 10,
    "size": 20,
    "total": 200
  },
  "errorCode": 0,
  "errorMsg": ""
}
```

#### 获取个人积分记录

```dart
@GET("lg/coin/list/{page}/json")
Future<BaseEntity<PageEntity<List<MyCoinHistoryDatas>>>> getMyCoinList(
    @Path() int page);
```

#### 获取个人信息

```dart
@GET("lg/coin/userinfo/json")
Future<BaseEntity<CoinRankDatas>> getUserCoinInfo();
```

---

## 数据模型

### BaseEntity<T>

统一响应基类

```dart
class BaseEntity<T> {
  T? data;
  int errorCode;
  String? errorMsg;
}
```

**字段说明：**
| 字段 | 类型 | 说明 |
|------|------|------|
| data | T? | 响应数据 |
| errorCode | int | 错误码，0 表示成功 |
| errorMsg | String? | 错误消息 |

### PageEntity<T>

分页数据基类

```dart
class PageEntity<T> {
  int curPage;      // 当前页码
  List<T> datas;    // 数据列表
  int offset;       // 偏移量
  bool over;        // 是否最后一页
  int pageCount;    // 总页数
  int size;         // 每页数量
  int total;        // 总数据量
}
```

### ArticleInfoDatas

文章信息模型

```dart
class ArticleInfoDatas {
  bool? adminAdd;
  String? apkLink;
  int? audit;
  String? author;
  bool? canEdit;
  int? chapterId;
  String? chapterName;
  bool? collect;
  int? courseId;
  String? desc;
  String? descMd;
  String? envelopePic;
  bool? fresh;
  String? host;
  int? id;
  bool? isAdminAdd;
  String? link;
  String? niceDate;
  String? niceShareDate;
  String? origin;
  String? prefix;
  String? projectLink;
  int? publishTime;
  int? realSuperChapterId;
  int? selfVisible;
  int? shareDate;
  String? shareUser;
  int? superChapterId;
  List<dynamic>? tags;
  String? title;
  int? type;
  int? userId;
  int? visible;
  int? zan;
}
```

### BannerEntity

轮播图模型

```dart
class BannerEntity {
  String desc;
  int id;
  String imagePath;
  int isVisible;
  int order;
  String title;
  int type;
  String url;
}
```

### HotKeyEntity

搜索热词模型

```dart
class HotKeyEntity {
  int id;
  String link;
  String name;
  int order;
  int visible;
}
```

### TabEntity

分类标签模型

```dart
class TabEntity {
  int? courseId;
  int? id;
  String? name;
  int? order;
  int? parentChapterId;
  bool? userControlSetTop;
  int? visible;
  List<TabEntity>? children;
}
```

### AccountInfoEntity

账户信息模型

```dart
class AccountInfoEntity {
  bool admin;
  List<dynamic> chapterTops;
  List<int> collectIds;
  String email;
  String icon;
  int id;
  String nickname;
  String password;
  String publicName;
  String token;
  int type;
  String username;
}
```

### CoinRankDatas

积分排行模型

```dart
class CoinRankDatas {
  int coinCount;
  int level;
  int rank;
  int userId;
  String username;
}
```

### MyCoinHistoryDatas

积分记录模型

```dart
class MyCoinHistoryDatas {
  int coinCount;
  String date;
  String desc;
  int id;
  int reason;
  int type;
  int userId;
  String userName;
}
```

---

## 错误处理

### 统一错误处理

项目在 `HttpUtils._handleDioError` 中统一处理 Dio 错误：

| 错误类型 | 说明 | 用户提示 |
|---------|------|---------|
| connectionTimeout | 连接超时 | "网络连接超时，请检查网络设置" |
| sendTimeout | 发送超时 | "网络连接超时，请检查网络设置" |
| receiveTimeout | 接收超时 | "网络连接超时，请检查网络设置" |
| badResponse (401) | 未授权 | "登录已过期，请重新登录" |
| badResponse (403) | 禁止访问 | "没有权限访问" |
| badResponse (404) | 资源不存在 | "请求的资源不存在" |
| badResponse (500+) | 服务器错误 | "服务器错误，请稍后重试" |
| cancel | 请求取消 | "请求已取消" |
| unknown (SocketException) | 网络失败 | "网络连接失败，请检查网络设置" |

### 错误码说明

| 错误码 | 说明 |
|--------|------|
| 0 | 成功 |
| -1 | 未知错误 |
| 401 | 未授权/登录过期 |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 500+ | 服务器错误 |

---

## 使用示例

### Repository 使用示例

```dart
class HomeRepository {
  final RequestClient _client = requestClient;

  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getArticleList({
    required int page,
  }) async {
    return await _client.getArticleList(page);
  }
}
```

### Controller 使用示例

```dart
class HomeController extends BaseRefreshController<HomeRepository, ArticleInfoDatas> {
  @override
  Future<void> onRefresh() async {
    page = initPage;
    await aRequest(type: ScrollViewActionType.refresh);
  }

  @override
  Future<void> aRequest({
    required ScrollViewActionType type,
    Map<String, dynamic>? parameters,
  }) async {
    response = await request.getArticleList(page: page).catchError((error) {
      return processError(type: type, error: error);
    });

    if (response?.errorCode == 0) {
      if (type == ScrollViewActionType.refresh) {
        dataSource.clear();
      }
      if (response?.data?.datas != null) {
        dataSource.addAll(response!.data!.datas!);
      }
      status = dataSource.isEmpty
          ? ResponseStatus.successNoData
          : ResponseStatus.successHasContent;
    } else {
      status = ResponseStatus.fail;
    }

    refreshControllerStatusUpdate(type);
    update();
  }
}
```

### 带缓存的请求

```dart
// 启用缓存（仅开发环境）
final data = await HttpUtils.get(
  api: "/article/list/0/json",
  enableCache: true,
);
```

---

## 代码生成

项目使用 `json_serializable` 和 `retrofit` 进行代码生成：

### 生成命令

```bash
# 单次生成
flutter pub run build_runner build

# 监听模式（推荐）
flutter pub run build_runner watch

# 清理后重新生成
flutter pub run build_runner build --delete-conflicting-outputs
```

### 生成的文件

- `*.g.dart` - JSON 序列化代码
- `request_client.g.dart` - Retrofit 客户端实现
