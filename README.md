# getx_study

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 参考文章
[Flutter GetX使用---简洁的魅力！](https://juejin.cn/post/6924104248275763208)

[Flutter应用框架搭建(一)GetX集成及使用详解](https://juejin.cn/post/7039637076962181157)

[Flutter iOS风格中Widget内容滑到了顶部导航栏后面与其重叠](https://blog.csdn.net/ww897532167/article/details/111093988)

## 没有使用const页面无法加载

TabsPage没有使用const进行修饰,结果无法加载页面

## pubspec.yaml

所有的插件于2022年8月4日进行了检查,都是此时的最新版本为准.

因为没有指定webview_flutter的版本好,结果空安全检查没有过.

让我同时考虑之前没有编译过的插件,我删除了,应该是版本问题导致,而并非空安全没有进行处理导致.