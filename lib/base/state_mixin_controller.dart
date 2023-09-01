import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:getx_study/entity/hot_key_entity.dart';

class StateMixinController extends GetxController with StateMixin<HotKeyEntity> {}

class ExamplePage extends GetView<StateMixinController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller.obx(
        (entity) => Text(entity?.name?.toString() ?? ""),
        onLoading: const CupertinoActivityIndicator(),
        onEmpty: const Text('No data found'),
        onError: (error) => Text(error.toString()),
      ),
    );
  }
}
