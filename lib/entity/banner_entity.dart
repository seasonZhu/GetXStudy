import 'package:getx_study/generated/json/base/json_field.dart';
import 'package:getx_study/generated/json/banner_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class BannerEntity {

	String? desc;
	double? id;
	String? imagePath;
	double? isVisible;
	double? order;
	String? title;
	double? type;
	String? url;
  
  BannerEntity();

  factory BannerEntity.fromJson(Map<String, dynamic> json) => $BannerEntityFromJson(json);

  Map<String, dynamic> toJson() => $BannerEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}