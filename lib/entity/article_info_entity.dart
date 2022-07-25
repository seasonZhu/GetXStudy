import 'package:getx_study/generated/json/base/json_field.dart';
import 'package:getx_study/generated/json/article_info_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class ArticleInfoEntity {

	int? curPage;
	List<ArticleInfoDatas>? datas;
	int? offset;
	bool? over;
	int? pageCount;
	int? size;
	int? total;
  
  ArticleInfoEntity();

  factory ArticleInfoEntity.fromJson(Map<String, dynamic> json) => $ArticleInfoEntityFromJson(json);

  Map<String, dynamic> toJson() => $ArticleInfoEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class ArticleInfoDatas {

	String? apkLink;
	int? audit;
	String? author;
	bool? canEdit;
	int? chapterId;
	String? chapterName;
	bool? collect;
	int? courseId;
	String? desc;
	String? descMd;
	String? envelopePic;
	bool? fresh;
	int? id;
	String? link;
	String? niceDate;
	String? niceShareDate;
	String? origin;
	String? prefix;
	String? projectLink;
	int? publishTime;
	int? selfVisible;
	int? shareDate;
	String? shareUser;
	int? superChapterId;
	String? superChapterName;
	List<ArticleInfoDatasTags>? tags;
	String? title;
	int? type;
	int? userId;
	int? visible;
	int? zan;
  
  ArticleInfoDatas();

  factory ArticleInfoDatas.fromJson(Map<String, dynamic> json) => $ArticleInfoDatasFromJson(json);

  Map<String, dynamic> toJson() => $ArticleInfoDatasToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class ArticleInfoDatasTags {

	String? name;
	String? url;
  
  ArticleInfoDatasTags();

  factory ArticleInfoDatasTags.fromJson(Map<String, dynamic> json) => $ArticleInfoDatasTagsFromJson(json);

  Map<String, dynamic> toJson() => $ArticleInfoDatasTagsToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}