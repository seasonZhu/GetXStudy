import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter/cupertino.dart';

class UnknownPage extends StatelessWidget {
  const UnknownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticBackgroundVisibility: false,
        middle: Text(AppText.t('page.unknown')),
      ),
      child: Center(
        child: Text(
          AppText.t('page.unknown'),
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
