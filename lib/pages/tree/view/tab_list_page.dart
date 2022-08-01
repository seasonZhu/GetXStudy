import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:getx_study/pages/tree/controller/tab_list_controller.dart';
import 'package:getx_study/pages/common/info_cell.dart';

class TabListPage extends StatelessWidget {
  final TabListController _controller;

  TabListPage({Key? key, required TabListController controller})
      : _controller = controller,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TabListController>(
      tag: _controller.id,
      builder: ((_) {
        return SmartRefresher(
          enablePullUp: true,
          controller: _controller.refreshController,
          onRefresh: _controller.onRefresh,
          onLoading: _controller.onLoadMore,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: _controller.dataSource.length,
            itemBuilder: (BuildContext context, int index) {
              final model = _controller.dataSource[index];
              return InfoCell(
                model: model,
                callback: (value) {
                  print(value.toString());
                },
              );
            },
          ),
        );
      }),
    );
  }
}
