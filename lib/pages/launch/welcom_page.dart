import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/account_manager/account_manager.dart';
import 'package:getx_study/routes/routes.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const ClampingScrollPhysics(),
        children: [
          _welcomeView(context, "welcome_2.jpg", false),
          _welcomeView(context, "welcome_1.png", true),
        ],
      ),
    );
  }

  Widget _welcomeView(BuildContext context, String imageName, bool visible) {
    var size = MediaQuery.of(context).size;
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            //设置背景图片
            image: DecorationImage(
              image: AssetImage("assets/images/$imageName"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Visibility(
          visible: visible,
          child: Positioned(
            left: 20,
            right: 20,
            bottom: 44,
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.grey),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                ),
              ),
              child: const Text("点击进入"),
              onPressed: () {
                AccountManager().saveNotFirstLaunch();
                Get.offAllNamed(Routes.main);
              },
            ),
          ),
        )
      ],
    );
  }
}
