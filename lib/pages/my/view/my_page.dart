import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:getx_study/enum/my.dart';
import 'package:getx_study/routes/routes.dart';

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("我的"),
      ),
      body: ListView.separated(
          itemBuilder: (context, index) {
            if (index == 0) {
              return AspectRatio(
                aspectRatio: 16.0 / 9.0,
                child: Container(),
              );
            } else {
              final model = Ext.userDataSource[index];
              return ListTile(
                  leading: Icon(model.icon),
                  title: Text(model.title),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {});
            }
          },
          separatorBuilder: (context, index) {
            return const Divider(
              height: 1.0,
            );
          },
          itemCount: Ext.userDataSource.length),
    );
  }
}
