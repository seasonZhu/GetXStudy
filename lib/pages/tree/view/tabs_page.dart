import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:getx_study/enum/scroll_view_action_type.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/extension/string_extension.dart';
import 'package:getx_study/pages/common/status_view.dart';
import 'package:getx_study/pages/tree/controller/tab_list_controller.dart';
import 'package:getx_study/pages/tree/controller/tree_controller.dart';
import 'package:getx_study/pages/tree/view/tab_list_page.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({Key? key}) : super(key: key);

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final _treeController = Get.find<TabsController>();

  var _alreadyRequestIndex = Set<int>();

  List<TabListController> _tabListControllers = [];

  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: StatusView<TreeController>(
        controller: _treeController,
        contentBuilder: (_) {
          _tabController = TabController(
              length: _treeController.data?.length ?? 0, vsync: this);
          _tabController.addListener(() {
            var index = _tabController.index;
            var value = _tabController.animation?.value;

            ///修复执行2次的BUG,增加条件
            if (index == value) {
              if (!_alreadyRequestIndex.contains(index)) {
                _alreadyRequestIndex.add(index);
                _tabListControllers[index]
                    .aRequest(type: ScrollViewActionType.refresh);
              } else {
                print("已经包含不用请求");
              }
            }
          });
          return Scaffold(
            appBar: AppBar(
              title: Text(_treeController.type.title),
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0.1,
              bottom: _tabBar(_tabController),
            ),
            body: TabBarView(
              controller: _tabController,
              children: _createTabsPage(),
            ),
          );
        },
      ),
    );
  }

  TabBar _tabBar(TabController controller) {
    return TabBar(
      tabs: (_treeController.data ?? []).map(
        (model) {
          return Tab(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Text(model.name.toString().replaceHtmlElement),
            ),
          );
        },
      ).toList(),
      controller: controller,
      isScrollable: true,
      indicatorColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: const TextStyle(color: Colors.white, fontSize: 20),
      unselectedLabelStyle: const TextStyle(color: Colors.grey, fontSize: 18),
      labelColor: Colors.white,
      labelPadding: const EdgeInsets.all(0.0),
      indicatorPadding: const EdgeInsets.all(0.0),
      indicatorWeight: 2.3,
      unselectedLabelColor: Colors.white,
    );
  }

  List<Widget> _createTabsPage() {
    return (_treeController.data ?? []).map((model) {
      final controller = TabListController();
      controller.tagType = _treeController.type;
      controller.id = model.id.toString();
      controller.request = Get.find();
      controller.refreshController = RefreshController(initialRefresh: true);
      controller.page = _treeController.type.pageNum;
      controller.initPage = _treeController.type.pageNum;
      Get.put(controller, tag: model.id.toString());
      _tabListControllers.add(controller);
      return TabListPage(
        controller: controller,
      );
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}