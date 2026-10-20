import 'package:get/get.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/base/base_request_controller.dart';
import 'package:getx_study/entity/account_info_entity.dart';
import 'package:getx_study/pages/my/controller/my_controller.dart';
import 'package:getx_study/pages/my/repository/my_repository.dart';

mixin GetUserInfoMixin
    on BaseRequestController<MyRepository, AccountInfoEntity> {
  String get userInfo => AccountService.find.userInfo;

  /// 积分失败不影响登录；旧会话的结果不能覆盖当前账户。
  Future<String> getUserCoinInfo() async {
    final account = AccountService.find;
    final info = account.info;
    final revision = account.sessionRevision;
    if (!account.isLogin || info == null) return account.userInfo;
    try {
      final response = await request.getUserCoinInfo();
      if (!response.isSuccess ||
          response.data == null ||
          !account.isLogin ||
          account.sessionRevision != revision ||
          !identical(account.info, info)) {
        return account.userInfo;
      }
      final data = response.data!;
      account.updateCoinSummary(level: data.level, rank: data.rank, points: data.coinCount);
      if (Get.isRegistered<MyController>()) {
        final controller = Get.find<MyController>();
        if (!controller.isClosed) controller.syncAccount();
      }
    } catch (_) {
      // 积分是登录后的补充信息，失败时保留占位或已有数据。
    }
    return account.userInfo;
  }
}
