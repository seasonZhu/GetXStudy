import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'example_routes.dart';

class GetXApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: Routes.routePage,
      initialBinding: GetXExampleBindings(),
      home: const GetXExamplePage(),
    );
  }
}

class GetXExamplePage extends GetView<GetXExampleController> {
  const GetXExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GetX编写计数器"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            GetBuilder<GetXExampleController>(
              builder: ((controller) {
                return Text(
                  controller.count.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              }),
            ),
            ElevatedButton(
              onPressed: controller.pushToNextPage,
              child: const Text("下一页"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        tooltip: 'Increment',
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
    Get.toNamed(Routes.getxRxExamplePage, arguments: {"message": "我是GetXExamplePage传来的数据"});
  }
}

class GetXExampleBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetXExampleController());
  }
}

class GetxRxExamplePage extends GetView<GetxRxExampleController> {
  GetxRxExamplePage({Key? key}) : super(key: key);

  final _easyController = Get.find<GetXExampleController>();

  @override
  Widget build(BuildContext context) {
    final map = Get.arguments;
    final message = map["message"];
    return Scaffold(
      appBar: AppBar(
        title: const Text("GetX响应式编写计数器"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Obx(() {
              return Text(
                controller.count.value.toString(),
                style: Theme.of(context).textTheme.headlineMedium,
              );
            }),
            Text(message),
            ElevatedButton(
                onPressed: controller.pushToCoinRankPage,
                child: const Text("下一页"))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          controller.increment();
          _easyController.increment();
        }),
        tooltip: 'Increment',
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

class GetxRxExampleController extends GetxController {
  var count = 0.obs;

  void increment() {
    ++count;
  }

  void pushToCoinRankPage() {
    Get.toNamed(Routes.getXExamplePage);
  }
}