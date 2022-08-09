import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:getx_study/enum/scroll_view_action_type.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/extension/string_extension.dart';
import 'package:getx_study/pages/common/status_view.dart';
import 'package:getx_study/pages/tree/controller/tab_list_controller.dart';
import 'package:getx_study/pages/tree/controller/tabs_controller.dart';
import 'package:getx_study/pages/tree/view/tab_list_page.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({Key? key}) : super(key: key);

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final _tabsController = Get.find<TabsController>();

  final _alreadyRequestIndex = Set<int>();

  final _tabListControllers = <TabListController>[];

  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CupertinoPageScaffold(
      child: StatusView<TabsController>(
        controller: _tabsController,
        contentBuilder: (_) {
          _tabController = TabController(
              length: _tabsController.data?.length ?? 0, vsync: this);
          _tabController.addListener(() {
            var index = _tabController.index;
            var value = _tabController.animation?.value;

            ///修复执行2次的BUG,增加条件
            if (index == value && index == _tabController.length - 1) {
              if (!_alreadyRequestIndex.contains(index)) {
                _alreadyRequestIndex.add(index);
                _tabListControllers[index]
                    .aRequest(type: ScrollViewActionType.refresh);
              } else {
                print("已经包含不用请求");
              }
            }
          });
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: MaterialApp(home: _tabBar(_tabController)),//_segmentedControl(), //Text(_tabsController.type.title),
              //bottom: _tabBar(_tabController),
            ),
            child: TabBarView(
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
      tabs: (_tabsController.data ?? []).map(
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
      indicatorColor: Theme.of(context).primaryColor,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: const TextStyle(color: Colors.white, fontSize: 18),
      unselectedLabelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      labelColor: Colors.black,
      labelPadding: const EdgeInsets.all(0.0),
      indicatorPadding: const EdgeInsets.all(0.0),
      indicatorWeight: 2.3,
      unselectedLabelColor: Colors.grey,
    );
  }

  List<Widget> _createTabsPage() {
    return (_tabsController.data ?? []).map((model) {
      final controller = TabListController();
      controller.tagType = _tabsController.type;
      controller.id = model.id.toString();
      controller.request = Get.find();
      controller.refreshController = RefreshController(initialRefresh: true);
      controller.page = _tabsController.type.pageNum;
      controller.initPage = _tabsController.type.pageNum;
      Get.put(controller, tag: model.id.toString());
      _tabListControllers.add(controller);
      return TabListPage(
        controller: controller,
      );
    }).toList();
  }

  Widget _segmentedControl() {
    final array = _tabsController.data ?? [];

    if (array.isEmpty) {
      return Container();
    }

    var map = Map<int, Widget>();
    for (var i = 0; i < array.length; i++) {
      final model = array[i];
      final widget = Container(
        padding: const EdgeInsets.all(10),
        child: Text(model.name.toString().replaceHtmlElement),
      );
      map[i] = widget;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: CupertinoSegmentedControl<int>(
        groupValue: _tabController.animation?.value.toInt(),
        children: map,
        onValueChanged: ((value) {
          _tabController.animateTo(value);
        }),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
