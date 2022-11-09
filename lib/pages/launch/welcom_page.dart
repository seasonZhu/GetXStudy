import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/account_manager/account_manager.dart';
import 'package:getx_study/routes/routes.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int _selectedIndex = 0;

  get _pages {
    return PageView(
      physics: const ClampingScrollPhysics(),
      children: _views,
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  get _pageController {
    return PageController(initialPage: _selectedIndex);
  }

  get _views {
    return [
      _otherWelcomePage("welcome_2.jpg"),
      _lastWelcomePage("welcome_1.png"),
    ];
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages,
    );
  }

  Widget _otherWelcomePage(String imageName) {
    var size = MediaQuery.of(context).size;
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            //设置背景图片
            image: DecorationImage(
              image: AssetImage("assets/images/$imageName"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _lastWelcomePage(String imageName) {
    var size = MediaQuery.of(context).size;
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            //设置背景图片
            image: DecorationImage(
              image: AssetImage("assets/images/$imageName"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 44,
          child: TextButton(
            child: Text("点击进入"),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.grey),
              foregroundColor: MaterialStateProperty.all(Colors.white),
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
          ),
        ),
      ],
    );
  }

  void _goMainView() {
    AccountManager().saveNotFirstLaunch();
    Get.offAllNamed(Routes.main);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
