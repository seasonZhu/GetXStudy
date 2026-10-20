import 'package:flutter/cupertino.dart';
import 'package:getx_study/base/interface.dart';
import 'package:getx_study/pages/web/controller/web_controller.dart';
import 'package:getx_study/widgets/animated_button.dart';

/// 只重建收藏按钮，避免共享收藏变化触发 WebView 初始化。
class WebCollectionButton extends StatelessWidget {
  const WebCollectionButton({
    super.key,
    required this.controller,
    required this.webLoadInfo,
    this.hidden = false,
  });

  final WebController controller;
  final IWebLoadInfo webLoadInfo;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final collections = controller.collections;
    final id = webLoadInfo.originId ?? webLoadInfo.id;
    return StreamBuilder(
      stream: collections.changes,
      builder: (context, snapshot) => Visibility(
        visible: !hidden && id != null && collections.account.isLogin,
        child: AnimatedIconButton(
          icon: Icon(id != null && collections.isCollected(id)
              ? CupertinoIcons.heart_fill
              : CupertinoIcons.heart),
          onPressed: id == null || collections.isPending(id)
              ? null
              : () =>
                  controller.collectOrUnCollectAction(webLoadInfo: webLoadInfo),
        ),
      ),
    );
  }
}
