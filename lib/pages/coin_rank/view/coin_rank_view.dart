import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:getx_study/pages/coin_rank/controller/coin_rank_controller.dart';

class CoinRankView extends GetView<CoinRankController> {
  const CoinRankView({Key? key}) : super(key: key);

  @override
  void initState() {
    controller.getCoinRankList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("积分排名")),
      body: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: controller.dataSource.length,
        itemBuilder: (BuildContext context, int index) {
          return Text(
              controller.dataSource[index].rank.toString());
        },
      ),
    );
  }
}
