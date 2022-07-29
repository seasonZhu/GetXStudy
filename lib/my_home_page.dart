import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'routes/routes.dart';

class MyHomePage extends GetView<CountEasyController> {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  // final _easyController = Get.find<CountEasyController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            GetBuilder<CountEasyController>(
              builder: ((controller) {
                return Text(
                  controller.count.toString(),
                  style: Theme.of(context).textTheme.headline4,
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

class CountEasyController extends GetxController {
  var count = 0;

  void increment() {
    ++count;
    update();
  }

  void pushToNextPage() {
    Get.toNamed(Routes.myNextPage, arguments: {"message": "我是MyHomePage传来的数据"});
  }
}

class MyHomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CountEasyController());
  }
}

class MyNextPage extends GetView<CountRxController> {
  MyNextPage({Key? key, required this.title}) : super(key: key);

  final String title;

  final _easyController = Get.find<CountEasyController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
                style: Theme.of(context).textTheme.headline4,
              );
            }),
            GetBuilder<CountRxController>(
              builder: (controller) {
                return Text(controller.message);
              },
            ),
            ElevatedButton(onPressed: controller.pushToCoinRankPage, child: const Text("下一页"))
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

class MyNextBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CountRxController());
  }
}

class CountRxController extends GetxController {
  var count = 0.obs;

  var message = "";

  @override
  void onReady() {
    final map = Get.arguments;
    message = map["message"];
    update();

    super.onReady();
  }

  void increment() {
    ++count;
  }

  void pushToCoinRankPage() {
    Get.toNamed(Routes.coinRink);
  }
}
