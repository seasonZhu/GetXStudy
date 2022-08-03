import 'package:flutter/material.dart';
import 'package:getx_study/routes/routes.dart';

enum My {
  header,
  ranking,
  myGitHub,
  myJueJin,
  myCoin,
  myCollect,
  login,
  logout,
}

extension Ext on My {
  String get title {
    switch (this) {
      case My.header:
        return "";
      case My.login:
        return "登录";
      case My.logout:
        return "登出";
      case My.myCoin:
        return "我的积分";
      case My.myCollect:
        return "我的收藏";
      case My.myGitHub:
        return "我的GitHub";
      case My.myJueJin:
        return "我的掘金";
      case My.ranking:
        return "积分排名";
    }
  }

  String get path {
    switch (this) {
      case My.header:
        return "";
      case My.login:
        return Routes.login;
      case My.logout:
        return "登出";
      case My.myCoin:
        return "我的积分";
      case My.myCollect:
        return "我的收藏";
      case My.myGitHub:
        return "我的GitHub";
      case My.myJueJin:
        return "我的掘金";
      case My.ranking:
        return Routes.coinRink;
    }
  }

  IconData get icon {
    switch (this) {
      case My.header:
        return Icons.usb;
      case My.login:
        return Icons.login;
      case My.logout:
        return Icons.logout_outlined;
      case My.myCoin:
        return Icons.message;
      case My.myCollect:
        return Icons.collections;
      case My.myGitHub:
        return Icons.web;
      case My.myJueJin:
        return Icons.abc;
      case My.ranking:
        return Icons.kayaking;
    }
  }

  static final visitorDataSource = [
    My.header,
    My.myGitHub,
    My.myJueJin,
    My.ranking,
    My.login,
  ];

  static final userDataSource = [
    My.header,
    My.myGitHub,
    My.myJueJin,
    My.ranking,
    My.myCoin,
    My.myCollect,
    My.logout,
  ];
}
