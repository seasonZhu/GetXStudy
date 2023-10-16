import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/pages/home/repository/hot_key_repository.dart';
import 'package:getx_study/entity/hot_key_entity.dart';

/// 在这里我使用Getx自带的StateMixin在Controller层改变状态,在Page层通过状态改变页面展示

class StateMixinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => StateMixinController(),
    );
  }
}

class StateMixinController extends GetxController
    with StateMixin<List<HotKeyEntity>> {

  late HotKeyRepository request;
  
  @override
  void onInit() async {
    super.onInit();
    request = HotKeyRepository();
    aRequest();
  }

  Future<void> aRequest({Map<String, dynamic>? parameters}) async {
    /// 这里这个可有可无
    change(null, status: RxStatus.loading());
    final response = await request.getHotKey().catchError((error) {
      change(null, status: RxStatus.error());
      return error;
    });
    final data = response.data ?? [];
    if (response.isSuccess) {
      if (data.isEmpty) {
        change(data, status: RxStatus.empty());
      } else {
        change(data, status: RxStatus.success());
      }
    } else {
      change(data, status: RxStatus.error(response.errorMsg));
    }
  }
}

class StateMixinExamplePage extends GetView<StateMixinController> {
  const StateMixinExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("StateMixin例子"),
      ),
      child: Center(
        child: controller.obx(
          (list) => Wrap(
            children: (list ?? []).map(
              (model) {
                return Container(
                  margin: const EdgeInsets.all(5),
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      overlayColor: MaterialStateProperty.all(Colors.blue),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    child: Text(model.name.toString()),
                    onPressed: () {},
                  ),
                );
              },
            ).toList(),
          ),
          onLoading: const CupertinoActivityIndicator(),
          onEmpty: const Text('No data found'),
          onError: (error) => Text(error.toString()),
        ),
      ),
    );
  }
}
