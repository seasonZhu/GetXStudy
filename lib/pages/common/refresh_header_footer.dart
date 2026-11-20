import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter/cupertino.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshHeader extends StatelessWidget {
  const RefreshHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return WaterDropHeader(
      complete: Center(
        child: Text(AppText.t('refresh.pull_complete')),
      ),
    );
  }
}

class RefreshFooter extends StatelessWidget {
  const RefreshFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomFooter(
      builder: (context, mode) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: mode?.statusBody(context),
          ),
        );
      },
    );
  }
}

extension on LoadStatus {
  Widget statusBody(BuildContext context) {
    switch (this) {
      case LoadStatus.idle:
        return Text(AppText.t('refresh.load_more'));
      case LoadStatus.canLoading:
        return Text(AppText.t('refresh.release_to_load'));
      case LoadStatus.loading:
        return const CupertinoActivityIndicator();
      case LoadStatus.noMore:
        final line = Container(
          width: 20,
          height: 1,
          color: CupertinoColors.separator.resolveFrom(context),
        );
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            line,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                AppText.t('refresh.no_more_data'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context)),
              ),
            ),
            const SizedBox(width: 8),
            line,
          ],
        );
      case LoadStatus.failed:
        return Text(AppText.t('refresh.failed'));
    }
  }
}
