import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:getx_study/base/inferface.dart';
import 'package:getx_study/enum/scroll_view_action_type.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/page_entity.dart';

abstract class BaseRefreshController<R extends IRepository, T>
    extends GetxController {
  late R request;

  late RefreshController refreshController;

  late int page;

  late int initPage;

  ResponseStatus status = ResponseStatus.loading;

  BaseEntity<PageEntity<List<T>>>? response;

  List<T> dataSource = [];

  @override
  void onInit() async {
    super.onInit();
    request = Get.find<R>();
    refreshController = Get.find<RefreshController>();
    page = Get.find<int>();
    initPage = page;
  }

  Future<void> onRefresh() async {}

  Future<void> onLoadMore() async {}

  Future<void> aRequest({required ScrollViewActionType type}) async {}
}
