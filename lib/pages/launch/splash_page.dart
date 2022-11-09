import 'package:flutter/material.dart';
import 'dart:async';

import 'package:get/get.dart';

import 'package:getx_study/routes/routes.dart';
import 'package:getx_study/pages/common/countdown_circle.dart';

/// 模拟的一个广告页面
class SplashPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            //设置背景图片
            image: DecorationImage(
              image: AssetImage("assets/images/launchImage.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 20,
          top: 40,
          child: CountdownCircle(finished: (byUserClick) {
            Get.offAllNamed(Routes.main);
          },),
        ),
      ],
    );
  }
}

