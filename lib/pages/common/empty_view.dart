import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
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
