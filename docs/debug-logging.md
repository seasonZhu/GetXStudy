# 调试日志使用

Debug 包打开“我的 → 调试日志”，游客无需登录即可使用。页面可筛选、搜索、清空以及分享当前筛选的本次运行日志。Profile、Release 不提供入口和收集。

业务代码继续引用 `package:getx_study/logger/logger.dart`：

```dart
logger.d('开始加载首页');
logger.i('首页加载完成');
logger.w('缓存已过期');
try {
  await loadData();
} catch (error, stackTrace) {
  logger.e(error, stackTrace, '首页加载失败');
  // 继续执行原有错误处理。
}
```

全部三个 Dio 实例均记录详细网络日志，包括普通查询参数、请求 JSON/表单、请求 Header、响应 Header、响应体、状态码、耗时和错误摘要，控制台与 App 内日志页面内容一致。不要再添加 PrettyDioLogger 或直接创建 Logger/Talker，避免重复输出及日志分散。新增 Dio 时添加 NetworkLogInterceptor；它只生成日志副本，不修改请求或响应。

日志默认不脱敏，Cookie、Set-Cookie、密码、Token、Authorization 等均按原文输出。需要脱敏时，在初始化前配置：

```dart
import 'package:getx_study/logger/log_config.dart';

LogConfig.redactCookies = true; // Cookie、Set-Cookie
LogConfig.redactSensitiveData = true; // 其他敏感字段、网址凭据等
```

两项默认均为 false，可以独立开启；修改后对新产生的日志生效，已有历史记录保持原样。开启其他敏感字段脱敏时，网络 URL 保留普通查询参数，敏感查询值、Header 和嵌套正文中的密码、Token、Authorization 等字段遮盖。文件与流仅显示说明，路由参数继续不记录。

日志仅保留最近 300 条，退出进程后清空。分享通过系统面板发送文本，不写日志文件。原生崩溃与远程监控另行接入。

选型与范围见 [ADR 0001](adr/0001-debug-logging.md)。
