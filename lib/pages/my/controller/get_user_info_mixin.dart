import 'package:getx_study/account_manager/account_manager.dart';
import 'package:getx_study/base/base_request_controller.dart';
import 'package:getx_study/entity/account_info_entity.dart';
import 'package:getx_study/pages/my/repository/my_repository.dart';

mixin GetUserInfoMixin
    on BaseRequestController<MyRepository, AccountInfoEntity> {
  var userInfo = "等级 --  排名 --  积分 --";

  Future<String> getUserCoinInfo() async {
    final response = await request.getUserCoinInfo();
    final userInfo =
        "等级 ${response.data?.level ?? "--"}  排名 ${response.data?.rank ?? "--"}  积分 ${response.data?.coinCount ?? "--"}";
    this.userInfo = userInfo;
    AccountManager().userInfo = userInfo;
    return userInfo;
  }
}
