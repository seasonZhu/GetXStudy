# 任务跟踪：GitHub

任务与规格保存在 seasonZhu/GetXStudy 的 GitHub Issues 中，使用 gh CLI 操作。

## 操作约定

- 创建：gh issue create --title "标题" --body-file <正文文件>
- 读取：gh issue view <编号> --json number,title,body,labels,comments
- 列表：gh issue list --state open --json number,title,body,labels,comments
- 评论：gh issue comment <编号> --body-file <正文文件>
- 添加或移除标签：gh issue edit <编号> --add-label "标签" / --remove-label "标签"
- 关闭：gh issue close <编号>

多行正文先写入临时文件，再通过 --body-file 传入。
在仓库内执行命令时，从 Git 远程地址确定仓库。

## PR 分诊入口

PRs as a request surface: no.

## 技能指令映射

“发布到任务跟踪系统”表示创建 GitHub Issue。
“获取相关任务”表示读取对应 GitHub Issue。

## 父子任务与依赖

优先使用当前 gh 版本支持的 GitHub 原生子任务和任务依赖。
不支持时，在子任务正文使用 Part of #<父任务编号>，
在父任务正文维护任务列表；依赖使用 Blocked by: #<编号>。
调用依赖 API 时使用任务的数据库 id，而非任务编号或 node_id。
所有阻塞任务关闭后，子任务才可执行。

## Wayfinder 约定

规划主任务使用 wayfinder:map 标签。
子任务使用 wayfinder:research、wayfinder:prototype、
wayfinder:grilling 或 wayfinder:task 标签。
按主任务中的顺序，选择没有未关闭依赖且尚未分配的子任务。
认领时分配给当前开发者；完成后评论结果、关闭子任务，
并在主任务中补充决策和结果链接。
