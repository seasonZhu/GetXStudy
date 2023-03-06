import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:getx_study/enum/scroll_view_action_type.dart';
import 'package:getx_study/pages/project_public_number/controller/public_number_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/extension/string_extension.dart';
import 'package:getx_study/pages/common/status_view.dart';
import 'package:getx_study/pages/tree/controller/tab_list_controller.dart';
import 'package:getx_study/pages/tree/view/tab_list_page.dart';

class PublicNumberPage extends StatefulWidget {
  const PublicNumberPage({Key? key}) : super(key: key);

  @override
  State<PublicNumberPage> createState() => _PublicNumberPageState();
}

class _PublicNumberPageState extends State<PublicNumberPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final _tabsController = Get.find<PublicNumberController>();

  final _alreadyRequestIndex = <int>{};

  final List<TabListController> _tabListControllers = [];

  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: StatusView<PublicNumberController>(
        controller: _tabsController,
        contentBuilder: (_) {
          _tabController = TabController(
              length: _tabsController.data?.length ?? 0, vsync: this);
          _tabController.addListener(() {
            final index = _tabController.index;
            final value = _tabController.animation?.value;

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
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: MaterialApp(
                home: _tabBar(_tabController),
                debugShowCheckedModeBanner: false,
              ), //_segmentedControl(), //Text(_tabsController.type.title),
              //bottom: _tabBar(_tabController),
            ),
            child: TabBarView(
              controller: _tabController,
              children: _createPublicNumberPage(),
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

  List<Widget> _createPublicNumberPage() {
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
