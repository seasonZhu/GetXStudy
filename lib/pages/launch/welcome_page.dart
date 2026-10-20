import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/generated/assets.dart';
import 'package:getx_study/routes/routes.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const ClampingScrollPhysics(),
        children: [
          _welcomeView(Assets.assetsImagesWelcome1, false),
          _welcomeView(Assets.assetsImagesWelcome2, true),
        ],
      ),
    );
  }

  Widget _localizedIntro() {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.white,
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.developer_mode, size: 72, color: Colors.blue),
                    const SizedBox(height: 24),
                    Text(AppText.t('welcome.api'), textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 26, color: Colors.black)),
                    const SizedBox(height: 16),
                    Text(AppText.t('welcome.features'), textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, color: Colors.black54)),
                    const SizedBox(height: 32),
                    Text(AppText.t('welcome.subtitle'), textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, color: Colors.black)),
                    const SizedBox(height: 48),
                    Text(AppText.t('welcome.title'), textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 36, color: Colors.blue)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _welcomeView(String imageName, bool visible) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        if (imageName == Assets.assetsImagesWelcome1)
          _localizedIntro()
        else Container(
          decoration: BoxDecoration(
            //设置背景图片
            image: DecorationImage(
              image: AssetImage(imageName),
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
                backgroundColor: WidgetStateProperty.all(Colors.grey),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                shape: WidgetStateProperty.all(
                  const RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                ),
              ),
              child: Text(AppText.t('page.enter')),
              onPressed: () {
                AccountService.find.saveNotFirstLaunch();
                Get.offAllNamed(Routes.main);
              },
            ),
          ),
        )
      ],
    );
  }
}
