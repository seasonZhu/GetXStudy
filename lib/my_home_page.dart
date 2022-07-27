import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'routes/routes.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

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
            GetBuilder<CountEasyController>(
              builder: ((controller) {
                return Text(
                  controller.count.toString(),
                  style: Theme.of(context).textTheme.headline4,
                );
              }),
            ),
            ElevatedButton(
              onPressed: _easyController.pushToNextPage,
              child: const Text("下一页"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _easyController.increment,
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

class MyNextPage extends StatelessWidget {
  MyNextPage({Key? key, required this.title}) : super(key: key);

  final String title;

  final _rxController = Get.find<CountRxController>();

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
                _rxController.count.value.toString(),
                style: Theme.of(context).textTheme.headline4,
              );
            }),
            GetBuilder<CountRxController>(
              builder: (controller) {
                return Text(_rxController.message);
              },
            ),
            ElevatedButton(onPressed: _rxController.pushToCoinRankPage, child: const Text("下一页"))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          _rxController.increment();
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