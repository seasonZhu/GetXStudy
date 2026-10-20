import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:getx_study/app_service/language_service.dart';
import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'example_routes.dart';
import 'package:getx_study/extension/theme_data_extension.dart';

class GetXApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: AppText.locale,
      supportedLocales: LanguageService.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      getPages: Routes.routePage,
      initialBinding: GetXExampleBindings(),
      home: const GetXExamplePage(),
    );
  }
}

class GetXExamplePage extends GetView<GetXExampleController> {
  const GetXExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.t('example.getx_simple')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppText.t('example.counter_hint'),
            ),
            GetBuilder<GetXExampleController>(
              builder: ((controller) {
                return Text(
                  AppText.number(controller.count),
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              }),
            ),
            ElevatedButton(
              onPressed: controller.pushToNextPage,
              child: Text(AppText.t('common.next_page')),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        tooltip: AppText.t('example.increment'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GetXExampleController extends GetxController {
  var count = 0;

  void increment() {
    ++count;
    update();
  }

  void pushToNextPage() {
    Get.toNamed(Routes.getxRxExamplePage,
        arguments: {"message": 'example.message'});
  }
}

class GetXExampleBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetXExampleController());
  }
}

class GetxRxExamplePage extends GetView<GetxRxExampleController> {
  GetxRxExamplePage({super.key});

  final _easyController = Get.find<GetXExampleController>();

  @override
  Widget build(BuildContext context) {
    final map = Get.arguments;
    final message = map["message"];
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: AppBar(
        title: Text(AppText.t('example.getx_reactive')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppText.t('example.counter_hint'),
            ),
            Obx(() {
              return Text(
                AppText.number(controller.count.value),
                style: Theme.of(context).textTheme.headlineMedium,
              );
            }),
            /// 使用GetX<T>时,GetxRxExampleController必须继承GetxController
            // GetX<GetxRxExampleController>(
            //   builder: (s) {
            //     return Text(
            //       s.count.value.toString(),
            //       style: Theme.of(context).textTheme.headlineMedium,
            //     );
            //   },
            // ),
            Text(AppText.t(message)),
            ElevatedButton(
              onPressed: controller.pushToCoinRankPage,
              child: Text(AppText.t('common.next_page')),
            ),
            Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E5EC),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 12),
                      Text(AppText.t('common.share'))
                    ])).addNeumorphism(
              bottomShadowColor: const Color(0xFFA3B1C6),
              topShadowColor: Colors.white,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          controller.increment();
          /// 上一个页面的值也在进行添加
          _easyController.increment();
        }),
        tooltip: AppText.t('example.increment'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GetxRxExampleBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetxRxExampleController());
  }
}

/// 响应式不用继承GetxController: https://juejin.cn/post/7204854015463997496
class GetxRxExampleController {
  var count = 0.obs;

  void increment() {
    ++count;
  }

  void pushToCoinRankPage() {
    Get.toNamed(Routes.getXExamplePage);
  }
}
