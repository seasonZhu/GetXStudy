# 使用 Talker 统一开发期日志

现有控制台日志无法在 App 内统一检索业务、网络和异常信息，因此采用 Talker，并保留原有业务日志入口以减少迁移。选择兼容现有 share_plus 12.x 的 talker_flutter、talker_dio_logger 5.1.16，不为日志功能升级分享组件，也不使用 dependency_overrides。

调试日志仅在 Debug 收集；Profile、Release 关闭收集和查看入口。历史只在本次运行内存中保留最近 300 条；使用者可主动分享，不做跨重启保存、自动上传或原生崩溃采集。相较 MXLogger，这一阶段优先满足开发期检索需求，避免引入二进制日志存储及解析流程。

网络日志持有独立副本，包含方法、URL、请求及响应 Header、状态码、耗时、错误摘要以及请求和响应正文，统一输出到 Flutter 控制台与 Talker 页面。根据调试需求，脱敏通过 LogConfig 配置：redactCookies 控制 Cookie/Set-Cookie，redactSensitiveData 控制密码、Token、Authorization 等其他敏感值；两项均默认 false，按原文打印，可以独立开启。配置改变只影响后续日志，不追溯处理历史；真实网络数据保持不变。开启脱敏后对对应字段进行遮盖，正文递归处理。上传文件和流仅记录说明，不读取原始内容。路由仅记录页面名称，不记录参数。异常记录追加到原有处理器，不吞掉系统默认错误。

“我的”页面向游客和已登录用户提供 Debug 专用入口。查看页面使用 TalkerBuilder 订阅历史；自带菜单触发 Flutter 3.47 的 ListTile 背景断言，因此采用简洁的中文查看界面。分享当前筛选结果的文本并提供 iPad 弹出位置，不写入文件；系统分享面板仍需设备验证。
