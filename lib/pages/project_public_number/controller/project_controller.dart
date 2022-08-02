import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/base/base_request_controller.dart';
import 'package:getx_study/entity/tab_entity.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/pages/project_public_number/repository/project_repository.dart';
import 'package:getx_study/pages/tree/repository/tabs_repository.dart';

class ProjectController
    extends BaseRequestController<ProjectRepository, List<TabEntity>> {
  ProjectController(this.type);

  TagType type;

  @override
  void onInit() async {
    super.onInit();
    aRequest();
  }

  @override
  Future<void> aRequest({Map<String, dynamic>? parameters}) async {
    response = await request.getTab();
    data = response?.data ?? [];
    status = response?.responseStatus ?? ResponseStatus.loading;
    update();
  }
}