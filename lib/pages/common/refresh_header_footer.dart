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
        return Center(child: mode?.statusBody);
      },
    );
  }
}

extension on LoadStatus {
  Widget get statusBody {
    switch (this) {
      case LoadStatus.idle:
        return Text(AppText.t('refresh.load_more'));
      case LoadStatus.canLoading:
        return Text(AppText.t('refresh.release_to_load'));
      case LoadStatus.loading:
        return const CupertinoActivityIndicator();
      case LoadStatus.noMore:
        return Text(AppText.t('refresh.no_more_data'));
      case LoadStatus.failed:
        return Text(AppText.t('refresh.failed'));
    }
  }
}
