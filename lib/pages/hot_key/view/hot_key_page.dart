import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/pages/common/status_view.dart';
import 'package:getx_study/pages/hot_key/controller/hot_key_controller.dart';

class HotKeyPage extends GetView<HotKeyController> {
  const HotKeyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("热词"),
      ),
      body: StatusView(
        controller: controller,
        contentBuilder: (_) {
          return Wrap(
            children: (controller.data ?? []).map(
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
          );
        },
      ),
    );
  }
}
