import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:getx_study/pages/coin_rank/controller/coin_rank_controller.dart';

class CoinRankPage extends GetView<CoinRankController> {
  const CoinRankPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("积分排名")),
      body: GetBuilder<CoinRankController>(
        builder: (controller) {
          return ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: controller.dataSource.length,
            itemBuilder: (BuildContext context, int index) {
              final model = controller.dataSource[index];
              
              return ListTile(
                leading: Text(model.rank.toString()),
                title: Text(model.username.toString()),
                trailing: Text('积分:${model.level.toString()}'),
              );
            },
          );
        },
      ),
    );
  }

  Widget _listView() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: controller.dataSource.length,
      itemBuilder: (BuildContext context, int index) {
        return Text(controller.dataSource[index].rank.toString());
      },
    );
  }
}
