import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:getx_study/pages/my/controller/my_controller.dart';
import 'package:getx_study/routes/routes.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:getx_study/pages/common/info_cell.dart';
import 'package:getx_study/pages/common/refresh_status_view.dart';
import 'package:getx_study/pages/home/controller/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final myController = Get.find<MyController>();
    myController.autoLogin();
    return Scaffold(
      appBar: AppBar(
        title: const Text("首页", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0.1,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: (() => Get.toNamed(Routes.hotKey)),
          ),
        ],
      ),
      body: RefreshStatusView(
        controller: controller,
        contentBuilder: (_) {
          return SmartRefresher(
            enablePullUp: true,
            controller: controller.refreshController,
            onRefresh: controller.onRefresh,
            onLoading: controller.onLoadMore,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.dataSource.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return AspectRatio(
                    aspectRatio: 16.0 / 9.0,
                    child: Swiper(
                      itemBuilder: (BuildContext itemContext, int index) {
                        return CachedNetworkImage(
                          fit: BoxFit.fitWidth,
                          imageUrl: controller.banners[index].imagePath,
                          placeholder: (context, url) => Image.asset(
                            "assets/images/placeholder.png",
                          ),
                        );
                      },
                      itemCount: controller.banners.length,
                      pagination: const SwiperPagination(),
                      autoplay: true,
                      autoplayDisableOnInteraction: true,
                      onTap: (index) {
                        print(index);
                        Get.toNamed("/web/true",
                            arguments: controller.banners[index]);
                      },
                    ),
                  );
                } else {
                  final model = controller.dataSource[index - 1];

                  return InfoCell(
                    model: model,
                    callback: (_) {
                      print("点击了");
                      Get.toNamed(Routes.web, arguments: model);
                    },
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
