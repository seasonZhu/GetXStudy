import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:getx_study/app_service/language_service.dart';
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
      locale: AppText.locale,
      supportedLocales: LanguageService.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
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
  String _category = 'logs.all';
  bool _sharing = false;

  String _categoryOf(TalkerData data) {
    return switch (data.key) {
      TalkerKey.httpRequest ||
      TalkerKey.httpResponse ||
      TalkerKey.httpError =>
        'logs.network',
      TalkerKey.route => 'logs.route',
      TalkerKey.error || TalkerKey.exception => 'logs.error',
      _ => 'logs.business',
    };
  }

  Future<void> _share(BuildContext context, List<String> entries) async {
    if (_sharing || entries.isEmpty) return;
    final box = context.findRenderObject()! as RenderBox;
    setState(() => _sharing = true);
    try {
      await SharePlus.instance.share(ShareParams(
        text: entries.reversed.join('\n\n'),
        subject: AppText.t('logs.subject'),
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      ));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppText.t('logs.share_failed'))),
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
                (data) => _category == 'logs.all' || _categoryOf(data) == _category)
            .map((data) => data.generateTextMessage())
            .where((text) => text.toLowerCase().contains(_query))
            .toList();
        return Scaffold(
          appBar: AppBar(
            title: Text(AppText.t('logs.title')),
            leading: BackButton(onPressed: widget.onBack),
            actions: [
              IconButton(
                tooltip: AppText.t('logs.clear'),
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(appTalker.cleanHistory),
              ),
              Builder(builder: (context) {
                return IconButton(
                  tooltip: AppText.t('logs.share'),
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
                  decoration: InputDecoration(
                    labelText: AppText.t('logs.search'),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (text) =>
                      setState(() => _query = text.toLowerCase()),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (final category in ['logs.all', 'logs.business', 'logs.network', 'logs.route', 'logs.error'])
                    ChoiceChip(
                      label: Text(AppText.t(category)),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                ],
              ),
              Expanded(
                child: entries.isEmpty
                    ? Center(child: Text(AppText.t('logs.empty')))
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
