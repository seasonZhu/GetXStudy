import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:getx_study/entity/tab_entity.dart';
import 'package:getx_study/enum/scroll_view_action_type.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/pages/tree/controller/tab_list_controller.dart';
import 'package:getx_study/pages/tree/repository/tab_list_repository.dart';
import 'package:getx_study/pages/common/info_cell.dart';

class TabListPage extends StatelessWidget {
  final TagType _type;
  final TabEntity _model;
  final _controller = Get.find<TabListController>();

  TabListPage({Key? key, required TagType type, required TabEntity model})
      : _type = type,
        _model = model,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    _controller.tagType = _type;
    _controller.id = _model.id.toString();
    _controller.request = Get.find();
    _controller.refreshController = RefreshController(initialRefresh: false);
    _controller.page = _type.pageNum;
    _controller.initPage = _type.pageNum;
    _controller.aRequest(type: ScrollViewActionType.refresh);
    Get.put(_controller);
    return GetBuilder(
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
