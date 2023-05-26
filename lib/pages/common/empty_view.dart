import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(10.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '暂无数据',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
