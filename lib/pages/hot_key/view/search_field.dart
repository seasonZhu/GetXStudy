import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/base/resign_first_responder.dart';

class SearchField extends StatelessWidget {
  final searchKeyCtrl = TextEditingController(text: '');

  final ValueChanged<String> _keywordCallback;

  var changeString = "".obs;

  SearchField({Key? key, required ValueChanged<String> keywordCallback})
      : _keywordCallback = keywordCallback,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: TextField(
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.text,
            controller: searchKeyCtrl,
            cursorColor: Colors.white,
            decoration: const InputDecoration(
                focusColor: Colors.white,
                hintText: " 请输入搜索关键字",
                hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                border: OutlineInputBorder(
                  ///设置边框四个角的弧度
                  borderRadius: BorderRadius.all(Radius.circular(4)),

                  ///用来配置边框的样式
                  borderSide: BorderSide(
                    ///设置边框的颜色
                    color: Colors.white,

                    ///设置边框的粗细
                    width: 1.0,
                  ),
                ),

                ///设置输入框可编辑时的边框样式
                enabledBorder: OutlineInputBorder(
                  ///设置边框四个角的弧度
                  borderRadius: BorderRadius.all(Radius.circular(4)),

                  ///用来配置边框的样式
                  borderSide: BorderSide(
                    ///设置边框的颜色
                    color: Colors.white,

                    ///设置边框的粗细
                    width: 1.0,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  ///设置边框四个角的弧度
                  borderRadius: BorderRadius.all(Radius.circular(10)),

                  ///用来配置边框的样式
                  borderSide: BorderSide(
                    ///设置边框的颜色
                    color: Colors.red,

                    ///设置边框的粗细
                    width: 1.0,
                  ),
                ),

                ///用来配置输入框获取焦点时的颜色
                focusedBorder: OutlineInputBorder(
                  ///设置边框四个角的弧度
                  borderRadius: BorderRadius.all(Radius.circular(4)),

                  ///用来配置边框的样式
                  borderSide: BorderSide(
                    ///设置边框的颜色
                    color: Colors.transparent,

                    ///设置边框的粗细
                    width: 1.0,
                  ),
                ),
                contentPadding: EdgeInsets.all(4.0)),
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
