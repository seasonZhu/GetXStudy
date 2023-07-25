import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';

import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/pages/common/status_view.dart';
import 'package:getx_study/pages/tree/controller/tree_controller.dart';
import 'tree_cell.dart';

class TreePage extends GetView<TreeController> {
  const TreePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(controller.type.title),
      ),
      child: StatusView<TreeController>(
        contentBuilder: (controller) {
          return ListView.builder(
            /// 通过ScrollMixin的scoll,可以监听滑动到顶部与滑动到底部
            controller: controller.scroll,
            shrinkWrap: true,
            itemCount: controller.data?.length ?? 0,
            itemBuilder: ((context, index) {
              final model = controller.data?[index];
              if (model != null) {
                return TreeCell(model);
              } else {
                return Container();
              }
            }),
          );
        },
      ),
    );
  }
}