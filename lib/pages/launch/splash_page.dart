import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/routes/routes.dart';
import 'package:getx_study/pages/common/countdown_circle.dart';

/// 模拟的一个广告页面
class SplashPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        Container(
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
          top: 88,
          child: CountdownCircle(finished: (byUserClick) {
            Get.offAllNamed(Routes.main);
          },),
        ),
      ],
    );
  }
}

