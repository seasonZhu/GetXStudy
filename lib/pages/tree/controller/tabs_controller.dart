import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/tree_layout_service.dart';

import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/base/base_request_controller.dart';
import 'package:getx_study/entity/tab_entity.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/logger/logger.dart';
import 'package:getx_study/pages/tree/repository/tabs_repository.dart';

class TabsController
    extends BaseRequestController<TabsRepository, List<TabEntity>>
    with ScrollMixin {
  TabsController(this.type);

  final TagType type;

  @override
  String get repositoryTag => type.toString();

  bool _isLoading = false;
  TreeLayout _layout = TreeLayout.wrap;

  TreeLayout get layout => _layout;

  TreeLayout get _preferredLayout => Get.isRegistered<TreeLayoutService>()
      ? Get.find<TreeLayoutService>().selected
      : TreeLayout.wrap;

  void applyLayoutPreference() {
    if (type != TagType.tree) return;
    final preferred = _preferredLayout;
    if (_layout == preferred) return;
    if (scroll.hasClients) scroll.jumpTo(0);
    _layout = preferred;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    if (type == TagType.tree) _layout = _preferredLayout;
    aRequest();
  }

  @override
  Future<void> aRequest({Map<String, dynamic>? parameters}) async {
    if (isClosed || _isLoading) return;
    _isLoading = true;
    if (data?.isNotEmpty != true) {
      status = ResponseStatus.loading;
      update();
    }
    try {
      final result = await request.getTab();
      if (isClosed) return;
      if (!result.isSuccess) {
        _handleFailure();
        return;
      }
      response = result;
      final categories = result.data ?? const <TabEntity>[];
      data = type == TagType.tree
          ? categories
              .where((category) => category.children?.isNotEmpty == true)
              .toList()
          : List.of(categories);
      status = data!.isEmpty
          ? ResponseStatus.successNoData
          : ResponseStatus.successHasContent;
    } catch (_) {
      if (!isClosed) _handleFailure();
    } finally {
      _isLoading = false;
      if (!isClosed) update();
    }
  }

  void _handleFailure() {
    if (data?.isNotEmpty == true) {
      status = ResponseStatus.successHasContent;
      EasyLoading.showToast(AppText.t('common.load_failed'));
    } else {
      status = ResponseStatus.fail;
    }
  }

  @override
  Future<void> onTopScroll() async {
    logger.d('滑到了顶部');
  }

  @override
  Future<void> onEndScroll() async {
    logger.d('滑到了底部');
  }
}
