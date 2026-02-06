import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/base/resign_first_responder.dart';
import 'package:getx_study/routes/routes.dart';
import 'package:getx_study/pages/common/status_view.dart';
import 'package:getx_study/pages/home/controller/hot_key_controller.dart';
import 'package:getx_study/widgets/animated_button.dart';
import 'package:getx_study/widgets/staggered_animation.dart';
import 'search_text_field.dart';

class HotKeyPage extends GetView<HotKeyController> {
  const HotKeyPage({super.key});

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
        child: StatusView<HotKeyController>(
          contentBuilder: (controller) {
            return StaggeredWrap(
              spacing: 5,
              runSpacing: 5,
              children: (controller.data ?? []).map(
                (model) {
                  return AnimatedTextButton(
                    onPressed: () {
                      ResignFirstResponder.unfocus();
                      Get.toNamed(Routes.searchResult,
                          arguments: model.name.toString());
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(Colors.blue),
                      foregroundColor:
                          WidgetStateProperty.all(Colors.white),
                      overlayColor: WidgetStateProperty.all(Colors.blue),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                    child: Text(model.name.toString()),
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
