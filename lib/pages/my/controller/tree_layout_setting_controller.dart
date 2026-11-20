import 'package:get/get.dart';
import 'package:getx_study/app_service/tree_layout_service.dart';

class TreeLayoutSettingController extends GetxController {
  TreeLayoutSettingController(this._service);

  final TreeLayoutService _service;
  bool _saving = false;
  bool _saveFailed = false;

  TreeLayout get selected => _service.selected;
  bool get saving => _saving;
  bool get saveFailed => _saveFailed;

  Future<void> select(TreeLayout layout) async {
    if (_saving || layout == selected) return;
    _saving = true;
    _saveFailed = false;
    update();
    final saved = await _service.select(layout);
    if (isClosed) return;
    _saving = false;
    _saveFailed = !saved;
    update();
  }
}
