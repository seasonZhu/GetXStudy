import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:getx_study/app_service/language_service.dart';
import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:getx_study/app_service/theme_service.dart';
import 'package:getx_study/entity/tab_entity.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/extension/string_extension.dart';
import 'package:getx_study/pages/common/status_view.dart';
import 'package:getx_study/pages/common/keep_alive_wrapper.dart';
import 'package:getx_study/pages/tree/controller/tab_list_controller.dart';
import 'package:getx_study/pages/tree/controller/tabs_controller.dart';
import 'package:getx_study/pages/tree/view/tab_list_page.dart';
import 'package:getx_study/pages/tree/view/elastic_tab_indicator.dart';

class TabsPage extends StatefulWidget {
  final TagType type;

  const TabsPage({super.key, required this.type});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CupertinoPageScaffold(
      child: StatusView<TabsController>(
        tag: widget.type.toString(),
        contentBuilder: (controller) => _TabsContent(
          key: ValueKey(widget.type),
          type: widget.type,
          tabs: List.of(controller.data ?? []),
        ),
      ),
    );
  }
}

class _TabsContent extends StatefulWidget {
  const _TabsContent({super.key, required this.type, required this.tabs});

  final TagType type;
  final List<TabEntity> tabs;

  @override
  State<_TabsContent> createState() => _TabsContentState();
}

class _TabsContentState extends State<_TabsContent>
    with TickerProviderStateMixin {
  TabController? _tabController;
  late final _rebound = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  int _settledIndex = 0;
  bool _tapSwitch = false;

  void _handleTabChange() {
    final controller = _tabController!;
    if (controller.indexIsChanging) {
      _tapSwitch = true;
      if (_rebound.value != 0) _rebound.reset();
    } else if (_tapSwitch) {
      _tapSwitch = false;
      _settleIndicator();
    }
  }

  void _settleIndicator() {
    final controller = _tabController!;
    if (controller.indexIsChanging || _settledIndex == controller.index) return;
    _settledIndex = controller.index;
    if (!MediaQuery.disableAnimationsOf(context)) _rebound.forward(from: 0);
  }

  bool _handlePageScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification is ScrollUpdateNotification && _rebound.isAnimating) {
      _rebound.reset();
    } else if (notification is ScrollEndNotification) {
      _settleIndicator();
    }
    return false;
  }

  List<String> _ids = [];
  final Map<String, Widget> _pages = {};
  final Map<String, TabListController> _ownedControllers = {};

  String _tag(String id) => '${widget.type.name}:$id';

  @override
  void initState() {
    super.initState();
    _syncTabs();
  }

  @override
  void didUpdateWidget(covariant _TabsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTabs();
  }

  void _syncTabs() {
    final ids = widget.tabs.map((tab) => tab.id.toString()).toList();
    if (listEquals(ids, _ids)) return;
    final selectedId = _tabController == null || _ids.isEmpty
        ? null
        : _ids[_tabController!.index];
    for (final id in _ids.where((id) => !ids.contains(id))) {
      _pages.remove(id);
      _release(id);
    }
    for (final id in ids.where((id) => !_pages.containsKey(id))) {
      final tag = _tag(id);
      if (!Get.isRegistered<TabListController>(tag: tag)) {
        final controller = TabListController()
          ..tagType = widget.type
          ..id = id
          ..refreshController = RefreshController(initialRefresh: true)
          ..initPage = widget.type.pageNum
          ..page = widget.type.pageNum;
        _ownedControllers[id] = Get.put(controller, tag: tag);
      }
      _pages[id] = KeepAliveWrapper(
        key: GlobalObjectKey(Get.find<TabListController>(tag: tag)),
        child: TabListPage(controllerTag: tag),
      );
    }
    final selectedIndex = selectedId == null ? -1 : ids.indexOf(selectedId);
    _tabController?.dispose();
    _rebound.reset();
    _tapSwitch = false;
    _settledIndex = selectedIndex < 0 ? 0 : selectedIndex;
    _ids = ids;
    _tabController = ids.isEmpty
        ? null
        : TabController(
            length: ids.length,
            initialIndex: _settledIndex,
            vsync: this,
          );
    _tabController?.addListener(_handleTabChange);
  }

  Widget _segmentedControl() {
    final array = widget.tabs;

    if (array.isEmpty) {
      return Container();
    }

    final map = <int, Widget>{};
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
        groupValue: _tabController!.animation?.value.toInt(),
        children: map,
        onValueChanged: ((value) {
          _tabController!.animateTo(value);
        }),
      ),
    );
  }

  void _release(String id) {
    final controller = _ownedControllers.remove(id);
    if (controller == null) return;
    final tag = _tag(id);
    if (Get.isRegistered<TabListController>(tag: tag) &&
        identical(Get.find<TabListController>(tag: tag), controller)) {
      Get.delete<TabListController>(tag: tag);
    } else if (!controller.isClosed) {
      controller.onDelete();
    }
  }

  @override
  void dispose() {
    for (final id in _ownedControllers.keys.toList()) {
      _release(id);
    }
    _tabController?.dispose();
    _rebound.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _tabController;
    if (controller == null) return const SizedBox.shrink();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final accent = CupertinoDynamicColor.resolve(
      ThemeService.find.indicatorColor,
      context,
    );
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticBackgroundVisibility: false,
        middle: MaterialApp(
          locale: AppText.locale,
          supportedLocales: LanguageService.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          debugShowCheckedModeBanner: false,
          home: TabBar(
            controller: _tabController,
            tabs: [
              for (final tab in widget.tabs)
                Tab(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 152),
                    child: Text(
                      (tab.name ?? '').replaceHtmlElement,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            dividerHeight: 0,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorAnimation: reduceMotion
                ? TabIndicatorAnimation.linear
                : TabIndicatorAnimation.elastic,
            indicator: reduceMotion
                ? BoxDecoration(
                    color: accent.withAlpha(32),
                    borderRadius: BorderRadius.circular(24),
                  )
                : ElasticTabIndicator(
                    controller: controller,
                    rebound: _rebound,
                    color: accent.withAlpha(32),
                  ),
            indicatorPadding: const EdgeInsets.symmetric(vertical: 5),
            labelPadding: const EdgeInsets.symmetric(horizontal: 12),
            labelStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 14),
            labelColor: CupertinoColors.label.resolveFrom(context),
            unselectedLabelColor:
                CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: NotificationListener<ScrollNotification>(
          onNotification: _handlePageScroll,
          child: TabBarView(
            key: ValueKey(_tabController),
            controller: _tabController,
            children: _ids.map((id) => _pages[id]!).toList(),
          ),
        ),
      ),
    );
  }
}
