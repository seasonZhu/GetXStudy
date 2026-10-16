import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'logger.dart';

class DebugLogsPage extends StatelessWidget {
  const DebugLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    // Cupertino 应用下局部补齐弹窗、主题、本地化及消息提示。
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: MediaQuery.platformBrightnessOf(context)),
      home: _LogViewer(onBack: () => Navigator.of(context).pop()),
    );
  }
}

class _LogViewer extends StatefulWidget {
  const _LogViewer({required this.onBack});

  final VoidCallback onBack;

  @override
  State<_LogViewer> createState() => _LogViewerState();
}

class _LogViewerState extends State<_LogViewer> {
  String _query = '';
  String _category = '全部';
  bool _sharing = false;

  String _categoryOf(TalkerData data) {
    return switch (data.key) {
      TalkerKey.httpRequest ||
      TalkerKey.httpResponse ||
      TalkerKey.httpError =>
        '网络',
      TalkerKey.route => '页面',
      TalkerKey.error || TalkerKey.exception => '异常',
      _ => '业务',
    };
  }

  Future<void> _share(BuildContext context, List<String> entries) async {
    if (_sharing || entries.isEmpty) return;
    final box = context.findRenderObject()! as RenderBox;
    setState(() => _sharing = true);
    try {
      await SharePlus.instance.share(ShareParams(
        text: entries.reversed.join('\n\n'),
        subject: 'GetXStudy 调试日志',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      ));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('日志分享失败，请稍后重试')),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TalkerBuilder(
      talker: appTalker,
      builder: (context, history) {
        final entries = history.reversed
            .where(
                (data) => _category == '全部' || _categoryOf(data) == _category)
            .map((data) => data.generateTextMessage())
            .where((text) => text.toLowerCase().contains(_query))
            .toList();
        return Scaffold(
          appBar: AppBar(
            title: const Text('调试日志'),
            leading: BackButton(onPressed: widget.onBack),
            actions: [
              IconButton(
                tooltip: '清空日志',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(appTalker.cleanHistory),
              ),
              Builder(builder: (context) {
                return IconButton(
                  tooltip: '分享当前筛选日志',
                  icon: const Icon(Icons.ios_share_outlined),
                  onPressed: entries.isEmpty || _sharing
                      ? null
                      : () => _share(context, entries),
                );
              }),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: '搜索日志',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (text) =>
                      setState(() => _query = text.toLowerCase()),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (final category in ['全部', '业务', '网络', '页面', '异常'])
                    ChoiceChip(
                      label: Text(category),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                ],
              ),
              Expanded(
                child: entries.isEmpty
                    ? const Center(child: Text('暂无匹配日志'))
                    : ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) => Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: SelectableText(entries[index]),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
