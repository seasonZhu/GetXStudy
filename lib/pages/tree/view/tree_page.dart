import 'package:getx_study/pages/common/scroll_to_top.dart';
import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:getx_study/app_service/tree_layout_service.dart';
import 'package:getx_study/entity/tab_entity.dart';
import 'package:getx_study/routes/routes.dart';

import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/pages/common/status_view.dart';
import 'package:getx_study/pages/tree/controller/tabs_controller.dart';
import 'tree_cell.dart';

class TreePage extends GetView<TabsController> {
  const TreePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticBackgroundVisibility: false,
        middle: Text(AppText.t('tree.title')),
      ),
      child: ScrollToTop(
          child: StatusView<TabsController>(
        tag: TagType.tree.toString(),
        keepInactiveViews: false,
        contentBuilder: (controller) {
          final categories = controller.data ?? const <TabEntity>[];
          if (controller.layout == TreeLayout.list) {
            return _buildTopicList(context, controller, categories);
          }
          return ListView.builder(
            /// 通过ScrollMixin的scoll,可以监听滑动到顶部与滑动到底部,
            /// 这里添加了ScrollMixin的scoll之后,iOS特有的点击顶部回到列表顶部就失效了
            controller: controller.scroll,
            itemCount: categories.length,
            itemBuilder: (context, index) => TreeCell(categories[index]),
          );
        },
      )),
    );
  }

  Widget _buildTopicList(
    BuildContext context,
    TabsController controller,
    List<TabEntity> categories,
  ) {
    final dark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final background = dark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F0F2);
    final separator = dark ? const Color(0xFF3A3A3C) : const Color(0xFFE0E0E3);
    return SafeArea(
      child: CustomScrollView(
        controller: controller.scroll,
        slivers: [
          for (final category in categories)
            SliverMainAxisGroup(
              slivers: [
                PinnedHeaderSliver(
                  child: ColoredBox(
                    color: background,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: separator, width: 0)),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                      child: DefaultTextStyle.merge(
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        child: Semantics(
                          header: true,
                          child: Text(category.name ?? ''),
                        ),
                      ),
                    ),
                  ),
                ),
                _buildTopicRows(category.children ?? const <TabEntity>[]),
              ],
            ),
        ],
      ),
    );
  }

  SliverList _buildTopicRows(List<TabEntity> topics) {
    return SliverList.builder(
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return CupertinoListTile(
          title: Text(topic.name ?? ''),
          trailing: const CupertinoListTileChevron(),
          onTap: () => Get.toNamed(Routes.treeList, arguments: topic),
        );
      },
    );
  }
}
