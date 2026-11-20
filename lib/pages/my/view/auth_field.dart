import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getx_study/i18n/app_text.dart';

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.textInputAction,
    this.enabled = true,
    this.obscureText = false,
    this.onSubmitted,
    this.onToggleVisibility,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final TextInputAction textInputAction;
  final bool enabled;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final accent = CupertinoTheme.of(context).primaryColor;
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: CupertinoTextField(
          controller: controller,
          focusNode: focusNode,
          placeholder: placeholder,
          textInputAction: textInputAction,
          enabled: enabled,
          obscureText: obscureText,
          onSubmitted: onSubmitted,
          padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 10, 14),
          decoration: BoxDecoration(
            color:
                CupertinoColors.secondarySystemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled && focusNode.hasFocus
                  ? CupertinoDynamicColor.resolve(accent, context)
                  : CupertinoColors.separator.resolveFrom(context),
            ),
          ),
          suffix: onToggleVisibility == null
              ? ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, child) => value.text.isEmpty
                      ? const SizedBox.shrink()
                      : _button(CupertinoIcons.clear_circled_solid,
                          'input.clear', controller.clear),
                )
              : _button(
                  obscureText ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                  obscureText ? 'input.show_password' : 'input.hide_password',
                  enabled ? onToggleVisibility : null,
                ),
        ),
      ),
    );
  }

  Widget _button(IconData icon, String label, VoidCallback? action) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(44, 44),
      onPressed: action,
      child: Icon(icon, size: 19, semanticLabel: AppText.t(label)),
    );
  }
}

ButtonStyle authSubmitStyle(BuildContext context) {
  final accent = CupertinoDynamicColor.resolve(
    CupertinoTheme.of(context).primaryColor,
    context,
  );
  return TextButton.styleFrom(
    backgroundColor: accent,
    foregroundColor:
        ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
            ? Colors.white
            : Colors.black,
    disabledBackgroundColor: CupertinoColors.systemGrey5.resolveFrom(context),
    disabledForegroundColor:
        CupertinoColors.secondaryLabel.resolveFrom(context),
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );
}
