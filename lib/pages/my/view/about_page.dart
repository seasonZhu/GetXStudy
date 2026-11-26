import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:getx_study/enum/my.dart';
import 'package:getx_study/i18n/app_text.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late final _versionInfo = _loadVersionInfo();

  Future<({String version, String build})> _loadVersionInfo() async {
    final info = await PackageInfo.fromPlatform();
    var build = info.buildNumber;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        build = await const MethodChannel('getx_study/build_info')
                .invokeMethod<String>('buildNumber') ??
            build;
      } on PlatformException {
        // 渠道读取失败时使用安装包构建号。
      } on MissingPluginException {
        // 渠道不可用时使用安装包构建号。
      }
    }
    return (version: info.version, build: build);
  }

  @override
  Widget build(BuildContext context) {
    const links = [My.myGitHub, My.myJueJin];
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticBackgroundVisibility: false,
        middle: Text(AppText.t('my.about')),
      ),
      child: SafeArea(
        bottom: false,
        child: Material(
          type: MaterialType.transparency,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: links.length + 1,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0,
              color: CupertinoColors.separator.resolveFrom(context),
            ),
            itemBuilder: (context, index) {
              final Widget tile;
              if (index < links.length) {
                final item = links[index];
                tile = ListTile(
                  title: Text(item.title),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => Get.toNamed(item.path, arguments: item.entity),
                );
              } else {
                tile = FutureBuilder(
                  future: _versionInfo,
                  builder: (context, snapshot) {
                    final info = snapshot.data;
                    return ListTile(
                      title: Text(AppText.t('about.version')),
                      subtitle: Text(
                        snapshot.hasError
                            ? AppText.t('about.version_error')
                            : info == null
                                ? AppText.t('about.loading')
                                : AppText.t('about.version_details', {
                                    'version': info.version,
                                    'build': info.build,
                                  }),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                );
              }
              return SizedBox(height: 56, child: tile);
            },
          ),
        ),
      ),
    );
  }
}
