import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      child: StatusView(
        controller: controller,
        contentBuilder: (_) {
          return ListView.builder(
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