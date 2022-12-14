import 'package:getx_study/base/base_request_controller.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/entity/hot_key_entity.dart';
import 'package:getx_study/pages/hot_key/repository/hot_key_repository.dart';

class HotKeyController
    extends BaseRequestController<HotKeyRepository, List<HotKeyEntity>> {
  @override
  void onInit() async {
    super.onInit();
    aRequest();
  }

  @override
  Future<void> aRequest({Map<String, dynamic>? parameters}) async {
    response = await request.getHotKey().catchError((_) {
      status = ResponseStatus.fail;
    });
    data = response?.data ?? [];
    status = response?.responseStatus ?? ResponseStatus.loading;
    update();
  }
}
