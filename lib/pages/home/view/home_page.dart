import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:getx_study/pages/common/info_cell.dart';
import 'package:getx_study/pages/common/refresh_status_view.dart';
import 'package:getx_study/pages/home/controller/home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final _controller = Get.find<HomeController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("首页", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0.1,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _controller.pushToHotKeyPage,
          )
        ],
      ),
      body: RefreshStatusView(
        controller: _controller,
        contentBuilder: (_) {
          return SmartRefresher(
            enablePullUp: true,
            controller: _controller.refreshController,
            onRefresh: _controller.onRefresh,
            onLoading: _controller.onLoadMore,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _controller.dataSource.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return AspectRatio(
                    aspectRatio: 16.0 / 9.0,
                    child: Swiper(
                        itemBuilder: (BuildContext itemContext, int index) {
                          return CachedNetworkImage(
                            fit: BoxFit.fitWidth,
                            imageUrl: _controller.banners[index].imagePath,
                            placeholder: (context, url) => Image.asset(
                              "assets/images/placeholder.png",
                            ),
                          );
                        },
                        itemCount: _controller.banners.length,
                        pagination: const SwiperPagination(),
                        autoplay: true,
                        autoplayDisableOnInteraction: true,
                        onTap: (index) {}),
                  );
                } else {
                  final model = _controller.dataSource[index - 1];

                  return InfoCell(
                    model: model,
                    callback: (_) {},
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
