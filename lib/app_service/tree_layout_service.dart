import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TreeLayout { wrap, list }

class TreeLayoutService extends GetxService {
  TreeLayoutService(this._preferences)
      : _selected = _preferences.get(preferenceKey) == TreeLayout.list.name
            ? TreeLayout.list
            : TreeLayout.wrap;

  static const preferenceKey = 'tree.layout';
  final SharedPreferences _preferences;
  TreeLayout _selected;

  TreeLayout get selected => _selected;

  Future<bool> select(TreeLayout layout) async {
    if (layout == _selected) return true;
    try {
      if (!await _preferences.setString(preferenceKey, layout.name)) {
        return false;
      }
    } catch (_) {
      return false;
    }
    _selected = layout;
    return true;
  }
}
