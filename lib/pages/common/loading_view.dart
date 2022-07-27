import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final String? _message;

  const LoadingView({Key? key, String? message}) : 
    _message = message, 
    super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(_message ?? '正在加载...'),
          ],
        ),
      ),
    );
  }
}
