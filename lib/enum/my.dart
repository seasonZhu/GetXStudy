import 'package:getx_study/i18n/app_text.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:getx_study/base/interface.dart';
import 'package:getx_study/routes/routes.dart';

enum My {
  header,
  ranking,
  myGitHub,
  myJueJin,
  myCoin,
  myCollect,
  themeSetting,
  languageSetting,
  login,
  logout;
}

extension Extension on My {
  String get title {
    switch (this) {
      case My.header:
        return "";
      case My.login:
        return AppText.t('login.title');
      case My.logout:
        return AppText.t('my.logout');
      case My.myCoin:
        return AppText.t('my.coins');
      case My.myCollect:
        return AppText.t('my.collect');
      case My.themeSetting:
        return AppText.t('my.theme');
      case My.languageSetting:
        return "language_setting".tr;
      case My.myGitHub:
        return AppText.t('my.github');
      case My.myJueJin:
        return AppText.t('my.juejin');
      case My.ranking:
        return AppText.t('coin.title');
    }
  }

  String get path {
    switch (this) {
      case My.header:
        return "";
      case My.login:
        return Routes.login;
      case My.logout:
        return Routes.unknown;
      case My.myCoin:
        return Routes.myCoinHistory;
      case My.myCollect:
        return Routes.myCollect;
      case My.themeSetting:
        return Routes.themeSetting;
      case My.languageSetting:
        return Routes.languageSetting;
      case My.myGitHub:
        return Routes.web;
      case My.myJueJin:
        return Routes.web;
      case My.ranking:
        return Routes.coinRink;
    }
  }

  WebLoadInfoEntity? get entity {
    if (this == My.myJueJin) {
      return WebLoadInfoEntity(
          AppText.t('my.juejin'), "https://juejin.cn/user/4353721778057997");
    } else if (this == My.myGitHub) {
      return WebLoadInfoEntity(AppText.t('my.github'), "https://github.com/seasonZhu");
    } else {
      return null;
    }
  }

  IconData get icon {
    switch (this) {
      case My.header:
        return Icons.usb;
      case My.login:
        return Icons.login;
      case My.logout:
        return Icons.logout;
      case My.myCoin:
        return Icons.trending_up;
      case My.myCollect:
        return Icons.local_offer;
      case My.themeSetting:
        return Icons.color_lens;
      case My.languageSetting:
        return Icons.language;
      case My.myGitHub:
        return Icons.link;
      case My.myJueJin:
        return Icons.looks;
      case My.ranking:
        return Icons.poll;
    }
  }

  static final visitorDataSource = [
    My.header,
    My.myGitHub,
    My.myJueJin,
    My.ranking,
    My.themeSetting,
    My.languageSetting,
    My.login,
  ];

  static final userDataSource = [
    My.header,
    My.myGitHub,
    My.myJueJin,
    My.ranking,
    My.myCoin,
    My.myCollect,
    My.themeSetting,
    My.languageSetting,
    My.logout,
  ];
}

class WebLoadInfoEntity implements IWebLoadInfo {
  WebLoadInfoEntity(this.title, this.link);
  @override
  int? id;
  @override
  int? originId;
  @override
  String? title;
  @override
  String? link;
}
