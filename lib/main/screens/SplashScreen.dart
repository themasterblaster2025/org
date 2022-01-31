import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/screens/WalkThroughScreen.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/user/screens/DashboardScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import 'LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    Future.delayed(
      Duration(seconds: 2),
      () {
        if (appStore.isLoggedIn) {
          DashboardScreen().launch(context, isNewTask: true);
        } else {
          if (getBoolAsync(IS_FIRST_TIME, defaultValue: true)) {
            WalkThroughScreen().launch(context, isNewTask: true);
          } else {
            LoginScreen().launch(context, isNewTask: true);
          }
        }
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlutterLogo(size: 100),
            16.height,
            Text('Local Delivery System', style: boldTextStyle(size: 20)),
          ],
        ),
      ),
    );
  }
}
