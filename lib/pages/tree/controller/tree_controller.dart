import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/base/base_request_controller.dart';
import 'package:getx_study/entity/tab_entity.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/pages/tree/repository/tree_repository.dart';

class TreeController
    extends BaseRequestController<TreeRepository, List<TabEntity>>
    with ScrollMixin {
  TreeController(this.type);

  TagType type;

  @override
  void onInit() async {
    super.onInit();
    aRequest();
  }

  @override
  Future<void> aRequest({Map<String, dynamic>? parameters}) async {
    response = await request.getTab().catchError((_) {
      status = ResponseStatus.fail;
    });
    data = response?.data ?? [];
    status = response?.responseStatus ?? ResponseStatus.loading;
    update();
  }

  @override
  Future<void> onTopScroll() async {
    print("滑到了顶部");
  }

  @override
  Future<void> onEndScroll() async {
    print("滑到了底部");
  }
}
