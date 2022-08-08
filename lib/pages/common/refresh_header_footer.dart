import 'package:flutter/cupertino.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshHeader extends StatelessWidget {
  const RefreshHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const WaterDropHeader(
      complete: Center(
        child: Text("下拉刷新完成"),
      ),
    );
  }
}

class RefreshFooter extends StatelessWidget {
  const RefreshFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomFooter(
      builder: (context, mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = const Text("上拉加载");
        } else if (mode == LoadStatus.loading) {
          body = const CupertinoActivityIndicator();
        } else if (mode == LoadStatus.failed) {
          body = const Text("加载失败！点击重试！");
        } else if (mode == LoadStatus.canLoading) {
          body = const Text("松手,加载更多!");
        } else {
          body = const Text("没有更多数据了!");
        }
        return Center(child: body);
      },
    );
  }
}
