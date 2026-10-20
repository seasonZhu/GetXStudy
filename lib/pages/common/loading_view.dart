import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter/cupertino.dart';

class LoadingView extends StatelessWidget {
  final String? _message;

  const LoadingView({super.key, String? message})
      : _message = message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CupertinoActivityIndicator(radius: 20),
            const SizedBox(
              height: 10.0,
            ),
            Text(_message ?? AppText.t('common.loading')),
          ],
        ),
      ),
    );
  }
}
