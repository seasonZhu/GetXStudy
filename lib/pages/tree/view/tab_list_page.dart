import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:getx_study/pages/common/refresh_header_footer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:getx_study/pages/tree/controller/tab_list_controller.dart';
import 'package:getx_study/pages/common/info_cell.dart';
import 'package:getx_study/routes/routes.dart';

class TabListPage extends StatefulWidget {
  final TabListController _controller;

  const TabListPage({Key? key, required TabListController controller})
      : _controller = controller,
        super(key: key);

  @override
  State<TabListPage> createState() => _TabListPageState();
}

class _TabListPageState extends State<TabListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<TabListController>(
      tag: widget._controller.id,
      builder: ((_) {
        return SmartRefresher(
          enablePullUp: true,
          header: const RefreshHeader(),
          footer: const RefreshFooter(),
          controller: widget._controller.refreshController,
          onRefresh: widget._controller.onRefresh,
          onLoading: widget._controller.onLoadMore,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: widget._controller.dataSource.length,
            itemBuilder: (BuildContext context, int index) {
              if (widget._controller.dataSource.isEmpty) {
                return Container();
              }

              final model = widget._controller.dataSource[index];
              return InfoCell(
                model: model,
                callback: (_) {
                  Get.toNamed(Routes.web, arguments: model);
                },
              );
            },
          ),
        );
      }),
    );
  }
}

// class TabListPage extends StatelessWidget {
//   final TabListController _controller;

//   const TabListPage({Key? key, required TabListController controller})
//       : _controller = controller,
//         super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<TabListController>(
//       tag: _controller.id,
//       builder: ((_) {
//         return SmartRefresher(
//           enablePullUp: true,
//           controller: _controller.refreshController,
//           onRefresh: _controller.onRefresh,
//           onLoading: _controller.onLoadMore,
//           child: ListView.builder(
//             padding: EdgeInsets.zero,
//             shrinkWrap: true,
//             itemCount: _controller.dataSource.length,
//             itemBuilder: (BuildContext context, int index) {
//               if (_controller.dataSource.isEmpty) {
//                 return Container();
//               }

//               final model = _controller.dataSource[index];
//               return InfoCell(
//                 model: model,
//                 callback: (_) {
//                   Get.toNamed(Routes.web,
//                             arguments: model);
//                 },
//               );
//             },
//           ),
//         );
//       }),
//     );
//   }
// }