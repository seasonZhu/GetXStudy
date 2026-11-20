import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter/cupertino.dart';
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
          child: CupertinoSearchTextField(
            style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                fontSize: 15),
            backgroundColor:
                CupertinoColors.tertiarySystemFill.resolveFrom(context),
            borderRadius: BorderRadius.circular(12),
            suffixIcon: Icon(
              CupertinoIcons.xmark_circle_fill,
              semanticLabel: AppText.t('input.clear'),
            ),
            controller: _controller,
            placeholder: AppText.t('search.hint'),
            onSubmitted: (_) => _submit(),
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, child) => Visibility(
            visible: value.text.trim().isNotEmpty,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onPressed: _submit,
              child: Text(AppText.t('search.action'),
                  style: const TextStyle(fontSize: 14)),
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
