import 'package:getx_study/generated/json/base/json_convert_content.dart';
import 'package:getx_study/entity/tab_entity.dart';

TabEntity $TabEntityFromJson(Map<String, dynamic> json) {
	final TabEntity tabEntity = TabEntity();
	final List<TabChildren>? children = jsonConvert.convertListNotNull<TabChildren>(json['children']);
	if (children != null) {
		tabEntity.children = children;
	}
	final double? courseId = jsonConvert.convert<double>(json['courseId']);
	if (courseId != null) {
		tabEntity.courseId = courseId;
	}
	final double? id = jsonConvert.convert<double>(json['id']);
	if (id != null) {
		tabEntity.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		tabEntity.name = name;
	}
	final double? order = jsonConvert.convert<double>(json['order']);
	if (order != null) {
		tabEntity.order = order;
	}
	final double? parentChapterId = jsonConvert.convert<double>(json['parentChapterId']);
	if (parentChapterId != null) {
		tabEntity.parentChapterId = parentChapterId;
	}
	final bool? userControlSetTop = jsonConvert.convert<bool>(json['userControlSetTop']);
	if (userControlSetTop != null) {
		tabEntity.userControlSetTop = userControlSetTop;
	}
	final double? visible = jsonConvert.convert<double>(json['visible']);
	if (visible != null) {
		tabEntity.visible = visible;
	}
	return tabEntity;
}

Map<String, dynamic> $TabEntityToJson(TabEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['children'] =  entity.children?.map((v) => v.toJson()).toList();
	data['courseId'] = entity.courseId;
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['order'] = entity.order;
	data['parentChapterId'] = entity.parentChapterId;
	data['userControlSetTop'] = entity.userControlSetTop;
	data['visible'] = entity.visible;
	return data;
}

TabChildren $TabChildrenFromJson(Map<String, dynamic> json) {
	final TabChildren tabChildren = TabChildren();
	final List<TabChildren>? children = jsonConvert.convertListNotNull<TabChildren>(json['children']);
	if (children != null) {
		tabChildren.children = children;
	}
	final double? courseId = jsonConvert.convert<double>(json['courseId']);
	if (courseId != null) {
		tabChildren.courseId = courseId;
	}
	final double? id = jsonConvert.convert<double>(json['id']);
	if (id != null) {
		tabChildren.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		tabChildren.name = name;
	}
	final double? order = jsonConvert.convert<double>(json['order']);
	if (order != null) {
		tabChildren.order = order;
	}
	final double? parentChapterId = jsonConvert.convert<double>(json['parentChapterId']);
	if (parentChapterId != null) {
		tabChildren.parentChapterId = parentChapterId;
	}
	final bool? userControlSetTop = jsonConvert.convert<bool>(json['userControlSetTop']);
	if (userControlSetTop != null) {
		tabChildren.userControlSetTop = userControlSetTop;
	}
	final double? visible = jsonConvert.convert<double>(json['visible']);
	if (visible != null) {
		tabChildren.visible = visible;
	}
	return tabChildren;
}

Map<String, dynamic> $TabChildrenToJson(TabChildren entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['children'] =  entity.children?.map((v) => v.toJson()).toList();
	data['courseId'] = entity.courseId;
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['order'] = entity.order;
	data['parentChapterId'] = entity.parentChapterId;
	data['userControlSetTop'] = entity.userControlSetTop;
	data['visible'] = entity.visible;
	return data;
}