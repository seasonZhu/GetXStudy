import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/base/resign_first_responder.dart';

class SearchTextField extends StatelessWidget {
  final searchKeyCtrl = TextEditingController(text: '');

  final ValueChanged<String> _keywordCallback;

  var changeString = "".obs;

  SearchTextField({Key? key, required ValueChanged<String> keywordCallback})
      : _keywordCallback = keywordCallback,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: CupertinoTextField(
            //style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.text,
            controller: searchKeyCtrl,
            cursorColor: Colors.white,
            placeholder: "请输入搜索关键字",
            onEditingComplete: () {
              _inputComplete(context);
            },
            onSubmitted: (input) {
              print(input);
            },
            onChanged: (value) {
              changeString.value = value;
            },
          ),
        ),
        Obx(
          (() {
            return Visibility(
              visible: changeString.isNotEmpty,
              child: InkWell(
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: 50,
                  height: 30,
                  alignment: Alignment.center,
                  child: const Text(
                    '搜索',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                onTap: () {
                  _inputComplete(context);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  void _inputComplete(BuildContext context) {
    ResignFirstResponder.unfocus();
    // if (searchKeyCtrl.text.trim().isEmpty) {
    //   Get.snackbar('', '搜索关键字不能为空');
    //   return;
    // }
    _keywordCallback(searchKeyCtrl.text.trim());
  }
}
