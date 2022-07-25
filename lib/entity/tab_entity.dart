import 'package:getx_study/generated/json/base/json_field.dart';
import 'package:getx_study/generated/json/tab_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class TabEntity {

	List<TabEntity>? children;
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