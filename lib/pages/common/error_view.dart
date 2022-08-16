import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  VoidCallback? retryAction;

  ErrorView({Key? key, this.retryAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '哎呀,出错了...',
              style: TextStyle(fontSize: 20),
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Theme.of(context).primaryColor),
              ),
              onPressed: () => retryAction,
              child: const Text("重试"),
            ),
          ],
        ),
      ),
    );
  }
}
