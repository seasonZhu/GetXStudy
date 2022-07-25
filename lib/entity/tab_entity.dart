import 'package:getx_study/generated/json/base/json_field.dart';
import 'package:getx_study/generated/json/tab_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class TabEntity {

	List<TabChildren>? children;
	double? courseId;
	double? id;
	String? name;
	double? order;
	double? parentChapterId;
	bool? userControlSetTop;
	double? visible;
  
  TabEntity();

  factory TabEntity.fromJson(Map<String, dynamic> json) => $TabEntityFromJson(json);

  Map<String, dynamic> toJson() => $TabEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class TabChildren {

	List<TabChildren>? children;
	double? courseId;
	double? id;
	String? name;
	double? order;
	double? parentChapterId;
	bool? userControlSetTop;
	double? visible;
  
  TabChildren();

  factory TabChildren.fromJson(Map<String, dynamic> json) => $TabChildrenFromJson(json);

  Map<String, dynamic> toJson() => $TabChildrenToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}