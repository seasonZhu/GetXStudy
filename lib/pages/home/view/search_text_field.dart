import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getx_study/extension/theme_data_extension.dart';
import 'package:getx_study/base/resign_first_responder.dart';

class SearchTextField extends StatefulWidget {
  final ValueChanged<String> keywordCallback;

  const SearchTextField({super.key, required this.keywordCallback});

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final keyword = _controller.text.trim();
    if (keyword.isEmpty) return;
    ResignFirstResponder.unfocus();
    widget.keywordCallback(keyword);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CupertinoTextField(
            style: TextStyle(color: Theme.of(context).brightness.color),
            controller: _controller,
            placeholder: '请输入搜索关键字',
            onEditingComplete: _submit,
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, child) => Visibility(
            visible: value.text.trim().isNotEmpty,
            child: InkWell(
              onTap: _submit,
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                height: 30,
                alignment: Alignment.center,
                child: const Text('搜索', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SearchValueField extends SearchTextField {
  const SearchValueField({super.key, required super.keywordCallback});
}
