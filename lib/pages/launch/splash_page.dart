import 'package:flutter/material.dart';
import 'dart:async';

import 'package:get/get.dart';

import 'package:getx_study/routes/routes.dart';

// 这里其实是模拟的一个广告页面
class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;
  int seconds = 5;

  @override
  void initState() {
    super.initState();
    //countDown();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            //设置背景图片
            image: DecorationImage(
              image: AssetImage("assets/images/launchImage.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
            right: 20,
            top: 40,
            child: TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(Colors.grey),
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                ),
              ),
              onPressed: () {
                _goMainView();
              },
              child: Text("跳过$seconds s"),
            )),
      ],
    );
  }

  // 延时执行
  void countDown() {
    var duration = const Duration(seconds: 1);
    Future.delayed(duration, _goMainView);
  }

  void _goMainView() {
    Get.offAllNamed(Routes.main);
  }

  // 倒计时执行
  void startTimer() {
    //设置 1 秒回调一次
    const period = Duration(seconds: 1);
    _timer = Timer.periodic(period, (timer) {
      //更新界面
      setState(() {
        //秒数减一，因为一秒回调一次
        seconds--;
      });
      if (seconds == 0) {
        //倒计时秒数为0，取消定时器
        cancelTimer();
        _goMainView();
      }
    });
  }

  void cancelTimer() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }
}
