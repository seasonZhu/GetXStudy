import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/base/base_request_controller.dart';
import 'package:getx_study/entity/tab_entity.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/pages/tree/repository/tabs_repository.dart';
import 'package:getx_study/logger/logger.dart';

class TabsController
    extends BaseRequestController<TabsRepository, List<TabEntity>>
    with ScrollMixin {
  TabsController(this.type);

  final TagType type;

  @override
  String get repositoryTag => type.toString();

  bool _isLoading = false;

  @override
  void onInit() {
    super.onInit();
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
      data = List.of(result.data ?? []);
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
      EasyLoading.showToast('加载失败，请重试');
    } else {
      status = ResponseStatus.fail;
    }
  }

  @override
  Future<void> onTopScroll() async {
    logger.d("滑到了顶部");
  }

  @override
  Future<void> onEndScroll() async {
    logger.d("滑到了底部");
  }
}
