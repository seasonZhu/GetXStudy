import 'package:getx_study/generated/json/base/json_field.dart';
import 'package:getx_study/generated/json/hot_key_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class HotKeyEntity {

	double? id;
	String? link;
	String? name;
	double? order;
	double? visible;
  
  HotKeyEntity();

  factory HotKeyEntity.fromJson(Map<String, dynamic> json) => $HotKeyEntityFromJson(json);

  Map<String, dynamic> toJson() => $HotKeyEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}