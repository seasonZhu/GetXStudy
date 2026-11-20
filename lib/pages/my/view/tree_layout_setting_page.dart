import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/tree_layout_service.dart';
import 'package:getx_study/i18n/app_text.dart';

import 'package:getx_study/pages/my/controller/tree_layout_setting_controller.dart';

class TreeLayoutSettingPage extends GetView<TreeLayoutSettingController> {
  const TreeLayoutSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticBackgroundVisibility: false,
        middle: Text(AppText.t('tree.layout_setting')),
      ),
      child: GetBuilder<TreeLayoutSettingController>(
        builder: (controller) => ListView(
          children: [
            for (final layout in TreeLayout.values)
              Semantics(
                selected: controller.selected == layout,
                child: CupertinoListTile(
                  title: Text(AppText.t('tree.layout_${layout.name}')),
                  trailing: controller.selected == layout
                      ? const Icon(CupertinoIcons.check_mark)
                      : null,
                  onTap: controller.saving
                      ? null
                      : () => controller.select(layout),
                ),
              ),
            if (controller.saveFailed)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Semantics(
                  liveRegion: true,
                  child: Text(AppText.t('tree.layout_save_failed')),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
