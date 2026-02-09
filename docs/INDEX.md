# GetX Study 项目文档

欢迎来到 GetX Study 项目文档中心。这里包含项目的所有技术文档、使用指南和最佳实践。

## 📚 文档目录

### 🚀 快速开始

| 文档 | 说明 |
|------|------|
| [README.md](../README.md) | 项目介绍、功能特性、快速开始 |
| [架构说明](./ARCHITECTURE.md) | 项目架构、设计模式、目录结构 |
| [API 文档](./API_DOCUMENTATION.md) | 网络请求接口、数据模型、错误处理 |

### 📖 使用指南

| 文档 | 说明 |
|------|------|
| [微交互效果指南](./MICRO_INTERACTIONS_GUIDE.md) | 按钮缩放、页面动画、列表交错动画 |
| [常量管理指南](./CONSTANTS_MANAGEMENT.md) | 资源配置、字符串、颜色、尺寸管理 |
| [常量快速开始](./CONSTANTS_QUICK_START.md) | 5分钟快速上手常量管理 |
| [常量工作流程](./CONSTANTS_WORKFLOW.md) | 如何添加和使用新的常量 |

### 🔧 开发文档

| 文档 | 说明 |
|------|------|
| [优化报告](./OPTIMIZATION_REPORT.md) | 已完成的优化项详情 |
| [额外优化建议](./ADDITIONAL_OPTIMIZATION.md) | 待优化的项目列表 |
| [高优先级优化](./HIGH_PRIORITY_COMPLETED.md) | 已完成的高优先级优化 |

### 📝 示例代码

| 文档 | 说明 |
|------|------|
| [常量迁移示例](../examples/constants_migration_example.dart) | 完整的常量使用示例 |
| [常量对比示例](../examples/constants_comparison.dart) | 迁移前后对比 |

---

## 🎯 按角色查找文档

### 初级开发者

推荐阅读顺序：
1. [README.md](../README.md) - 了解项目
2. [架构说明](./ARCHITECTURE.md) - 理解项目结构
3. [常量快速开始](./CONSTANTS_QUICK_START.md) - 学习资源管理

### 中级开发者

推荐阅读顺序：
1. [架构说明](./ARCHITECTURE.md) - 深入理解架构
2. [API 文档](./API_DOCUMENTATION.md) - 掌握网络请求
3. [微交互效果指南](./MICRO_INTERACTIONS_GUIDE.md) - 学习动画实现

### 高级开发者

推荐阅读顺序：
1. [架构说明](./ARCHITECTURE.md) - 了解整体设计
2. [优化报告](./OPTIMIZATION_REPORT.md) - 已完成优化
3. [额外优化建议](./ADDITIONAL_OPTIMIZATION.md) - 潜在改进点

---

## 🏗️ 项目架构概览

```
GetX Study
├── 📱 Presentation Layer (展示层)
│   ├── Pages (页面)
│   ├── Widgets (组件)
│   └── Animations (动画)
│
├── 🧠 Business Logic Layer (业务逻辑层)
│   ├── Controllers (控制器)
│   └── ViewModels (视图模型)
│
└── 💾 Data Layer (数据层)
    ├── Repositories (仓库)
    ├── API Clients (API 客户端)
    └── Entities (实体类)
```

---

## 🔑 核心概念

### GetX 状态管理

项目使用 GetX 进行状态管理，支持：

- **响应式状态**: `Obx`、`GetX`
- **依赖注入**: `Get.put`、`Get.lazyPut`
- **路由管理**: `Get.toNamed`、`Get.offAllNamed`

### 分层架构

```
View (视图)
    ↓ 依赖
Controller (控制器)
    ↓ 依赖
Repository (仓库)
    ↓ 依赖
API Client (API 客户端)
```

### 设计模式

- **单例模式**: AppService (AccountService、ThemeService)
- **工厂模式**: GetPage 页面创建
- **观察者模式**: 响应式状态更新
- **仓储模式**: 数据访问抽象
- **策略模式**: 刷新策略、错误处理

---

## 📦 主要功能模块

### 首页模块
- 轮播图展示
- 文章列表
- 下拉刷新 / 上拉加载

### 搜索模块
- 热搜关键词
- 文章搜索

### 项目模块
- 项目分类
- 项目列表

### 体系模块
- 知识体系树
- 体系文章

### 我的模块
- 用户登录 / 注册
- 收藏管理
- 积分排行

### WebView 模块
- H5 页面展示
- 与 JS 交互
- 文章收藏

---

## 🛠️ 技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| 框架 | Flutter | 3.24+ |
| 语言 | Dart | 3.0+ |
| 状态管理 | GetX | ^4.6.6 |
| 网络请求 | Dio | ^5.9.0 |
| JSON 序列化 | json_serializable | ^6.7.1 |

---

## 📂 重要目录

| 目录 | 说明 |
|------|------|
| `lib/pages/` | 页面组件 |
| `lib/base/` | 基础类 |
| `lib/entity/` | 数据实体 |
| `lib/http_client/` | API 客户端 |
| `lib/routes/` | 路由配置 |
| `lib/widgets/` | 自定义组件 |
| `lib/app_service/` | 应用服务 |
| `docs/` | 项目文档 |

---

## 🚀 快速链接

### 运行项目

```bash
# 获取依赖
flutter pub get

# 运行项目
flutter run

# 生成代码
flutter pub run build_runner watch
```

### 常用命令

```bash
# 分析代码
flutter analyze

# 格式化代码
dart format .

# 运行测试
flutter test
```

---

## 📞 联系方式

如有问题或建议，欢迎提交 Issue 或 Pull Request。

---

## 📄 许可证

本项目采用 MIT 许可证。
