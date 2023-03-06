import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/base/resign_first_responder.dart';
import 'package:getx_study/routes/routes.dart';
import 'package:getx_study/pages/common/status_view.dart';
import 'package:getx_study/pages/hot_key/controller/hot_key_controller.dart';
import 'search_text_field.dart';

class HotKeyPage extends GetView<HotKeyController> {
  const HotKeyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() => ResignFirstResponder.unfocus()),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: SearchValueField(
                keywordCallback: (keyword) {
                  ResignFirstResponder.unfocus();
                  Get.toNamed(Routes.searchResult, arguments: keyword);
                },
              ),
            ),
          ),
        ),
        child: StatusView(
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
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        overlayColor: MaterialStateProperty.all(Colors.blue),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      child: Text(model.name.toString()),
                      onPressed: () {
                        ResignFirstResponder.unfocus();
                        Get.toNamed(Routes.searchResult,
                            arguments: model.name.toString());
                      },
                    ),
                  );
                },
              ).toList(),
            );
          },
        ),
      ),
    );
  }
}
