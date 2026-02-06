# 微交互效果优化指南

本文档说明项目中新增的微交互效果组件的使用方法。

## 目录

1. [按钮缩放动画](#按钮缩放动画)
2. [页面过渡动画](#页面过渡动画)
3. [列表交错入场动画](#列表交错入场动画)
4. [完整示例](#完整示例)

---

## 按钮缩放动画

### 功能说明

当用户点击按钮时，按钮会缩小到 95%（可配置），松开后恢复原大小。这种视觉反馈让用户明确感知到点击操作。

### 可用组件

| 组件 | 用途 |
|------|------|
| `AnimatedScaleButton` | 基础缩放容器，可包装任何 widget |
| `AnimatedTextButton` | 带缩放的 TextButton |
| `AnimatedElevatedButton` | 带缩放的 ElevatedButton |
| `AnimatedOutlinedButton` | 带缩放的 OutlinedButton |
| `AnimatedIconButton` | 带缩放的 IconButton |
| `AnimatedInkWell` | 带缩放的 InkWell（用于卡片、列表项） |

### 使用示例

#### 1. AnimatedTextButton

```dart
// 基础用法
AnimatedTextButton(
  onPressed: () {
    print('按钮被点击');
  },
  child: Text('点击我'),
)

// 自定义样式和动画
AnimatedTextButton(
  onPressed: () {},
  style: ButtonStyle(
    backgroundColor: WidgetStateProperty.all(Colors.blue),
    foregroundColor: WidgetStateProperty.all(Colors.white),
  ),
  duration: Duration(milliseconds: 150), // 动画时长
  scaleDown: 0.90, // 缩小到 90%
  child: Text('自定义动画按钮'),
)
```

#### 2. AnimatedIconButton

```dart
AnimatedIconButton(
  icon: Icon(CupertinoIcons.heart),
  onPressed: () {
    print('收藏按钮被点击');
  },
  scaleDown: 0.85, // 图标按钮通常缩小更多
)
```

#### 3. AnimatedInkWell（用于列表项）

```dart
AnimatedInkWell(
  onTap: () {
    Get.toNamed(Routes.detail);
  },
  borderRadius: BorderRadius.circular(8),
  child: Card(
    child: ListTile(
      title: Text('列表项'),
    ),
  ),
)
```

---

## 页面过渡动画

### 已配置的动画

项目中已为所有页面配置了过渡动画：

| 页面类型 | 过渡效果 | 时长 |
|---------|---------|------|
| 主页 | 淡入 | 250ms |
| 普通页面 | 从右向左滑入 | 300ms |
| 登录页 | 从下向上滑入 | 400ms |
| 欢迎/启动页 | 淡入 | 300-500ms |

### 使用内置过渡动画

在 `lib/routes/routes.dart` 中配置路由：

```dart
GetPage(
  name: Routes.myPage,
  page: () => MyPage(),
  transition: Transition.rightToLeft,  // 从右向左滑入
  transitionDuration: Duration(milliseconds: 300),
)
```

### 可用的内置过渡

| 过渡类型 | 说明 |
|---------|------|
| `Transition.fadeIn` | 淡入 |
| `Transition.rightToLeft` | 从右向左滑入（默认） |
| `Transition.leftToRight` | 从左向右滑入 |
| `Transition.upToDown` | 从上向下滑入 |
| `Transition.downToUp` | 从下向上滑入 |
| `Transition.zoomIn` | 缩放淡入 |
| `Transition.cupertino` | iOS 风格 |
| `Transition.native` | 原生风格 |

---

## 列表交错入场动画

### 功能说明

列表项按顺序依次淡入并从下方滑入，创造流畅的视觉层次感。

### 可用组件

| 组件 | 用途 |
|------|------|
| `StaggeredListView` | 列表视图的交错动画 |
| `StaggeredWrap` | Wrap 布局的交错动画 |
| `StaggeredColumn` | Column 布局的交错动画 |
| `StaggeredAnimationWrapper` | 单个组件的入场动画 |

### 使用示例

#### 1. StaggeredWrap（替换 Wrap）

```dart
// 原来的 Wrap
Wrap(
  spacing: 5,
  runSpacing: 5,
  children: items.map((item) => Chip(label: Text(item))).toList(),
)

// 改为 StaggeredWrap
StaggeredWrap(
  spacing: 5,
  runSpacing: 5,
  duration: Duration(milliseconds: 300),  // 单个动画时长
  staggerDelay: Duration(milliseconds: 50),  // 项之间的延迟
  children: items.map((item) => Chip(label: Text(item))).toList(),
)
```

#### 2. StaggeredAnimationWrapper（单个组件）

```dart
StaggeredAnimationWrapper(
  duration: Duration(milliseconds: 300),
  delay: Duration(milliseconds: 100),  // 延迟启动
  slideBeginOffset: Offset(0, 0.3),  // 从下方 30% 位置滑入
  child: Card(
    child: ListTile(title: Text('延迟出现的卡片')),
  ),
)
```

---

## 完整示例

### HotKeyPage 使用示例

```dart
class HotKeyPage extends GetView<HotKeyController> {
  const HotKeyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('热搜页面'),
      ),
      child: StatusView<HotKeyController>(
        contentBuilder: (controller) {
          return StaggeredWrap(  // 使用交错动画
            spacing: 5,
            runSpacing: 5,
            children: (controller.data ?? []).map((model) {
              return AnimatedTextButton(  // 使用动画按钮
                onPressed: () {
                  Get.toNamed(Routes.searchResult, arguments: model.name);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.blue),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                child: Text(model.name),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
```

### 列表项使用示例（InfoCell）

```dart
class InfoCell extends StatelessWidget {
  final ArticleInfoDatas model;
  final ValueChanged<ArticleInfoDatas> callback;

  const InfoCell({
    super.key,
    required this.model,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedInkWell(  // 使用动画 InkWell
      onTap: () => callback(model),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(model.title),
      ),
    );
  }
}
```

---

## 效果预览

### 按钮缩放动画
- 按下时：缩小到 95%
- 松开时：平滑恢复到 100%
- 动画时长：100ms（可配置）

### 列表交错动画
- 第一项：立即开始动画
- 第二项：延迟 50ms 开始
- 第三项：延迟 100ms 开始
- 以此类推...

### 页面过渡动画
- 主页：淡入效果，250ms
- 详情页：从右向左滑入，300ms
- 登录页：从下向上滑入，400ms

---

## 最佳实践

1. **合理使用动画**
   - 不要过度使用，避免动画疲劳
   - 重要的操作可以强调，次要操作可以简化

2. **动画时长建议**
   - 按钮点击反馈：100-150ms
   - 列表项入场：200-300ms
   - 页面过渡：250-400ms

3. **缩放比例建议**
   - 普通按钮：0.95
   - 图标按钮：0.85-0.90
   - 卡片/列表项：0.97-0.98

4. **交错延迟建议**
   - 列表项：30-50ms
   - 卡片：50-80ms
   - 复杂组件：100-150ms

---

## 已更新的文件

### 新增文件
- `lib/widgets/animated_button.dart` - 按钮缩放动画组件
- `lib/widgets/staggered_animation.dart` - 列表交错动画组件
- `lib/widgets/page_transitions.dart` - 页面过渡动画辅助类

### 更新文件
- `lib/routes/routes.dart` - 添加页面过渡动画配置
- `lib/pages/home/view/hot_key_page.dart` - 使用动画按钮和交错动画
- `lib/pages/common/info_cell.dart` - 使用动画 InkWell
- `lib/pages/tree/view/tree_cell.dart` - 使用动画 InkWell
- `lib/pages/my/view/login_page.dart` - 使用动画按钮
- `lib/pages/my/view/register_page.dart` - 使用动画按钮
- `lib/pages/web/view/web_page.dart` - 使用动画图标按钮

---

## 故障排除

### 动画不生效

1. 检查是否正确导入组件：
```dart
import 'package:getx_study/widgets/animated_button.dart';
import 'package:getx_study/widgets/staggered_animation.dart';
```

2. 检查 onPressed 是否为 null（AnimatedInkWell 需要 onTap 不为 null 才会显示波纹）

3. 检查父组件是否约束了动画（如 SizedBox 固定大小）

### 性能问题

如果列表项过多导致卡顿，可以：
1. 增加交错延迟（减少同时播放的动画数量）
2. 减少单个动画时长
3. 使用 `ListView.builder` 的缓存机制
