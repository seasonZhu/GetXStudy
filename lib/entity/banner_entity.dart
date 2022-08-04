import 'package:getx_study/base/interface.dart';
import 'package:getx_study/generated/json/base/json_field.dart';
import 'package:getx_study/generated/json/banner_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class BannerEntity implements WebLoadInfo {
  String? desc;
  @override
  int? id;
  String? imagePath;
  double? isVisible;
  double? order;
  @override
  String? title;
  double? type;
  String? url;
  @override
  String? link;
  @override
  int? originId;

  BannerEntity();

  factory BannerEntity.fromJson(Map<String, dynamic> json) =>
      $BannerEntityFromJson(json);

  Map<String, dynamic> toJson() => $BannerEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
