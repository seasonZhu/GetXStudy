import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GetxRefreshController extends GetxController {
  int page;

  RefreshController refreshController;

  GetxRefreshController(this.page, this.refreshController);

  void onRefresh() {

  }

  void onLoadMore() {

  }
}
