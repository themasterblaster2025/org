import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/screens/EmailVerificationScreen.dart';
import '../../delivery/screens/DeliveryDashBoard.dart';
import 'UserCitySelectScreen.dart';
import '../../main/models/CityListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/screens/LoginScreen.dart';
import '../../main/screens/WalkThroughScreen.dart';
import '../../main/utils/Constants.dart';
import '../../user/screens/DashboardScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../utils/Images.dart';
import 'VerificationScreen.dart';

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
      Duration(seconds: 1),
      () async {
        if (appStore.isLoggedIn && getIntAsync(USER_ID) != 0) {
          await getUserDetail(getIntAsync(USER_ID)).then((value) {
            if (value.deletedAt != null) {
              logout(context);
            } else {
              if (!getBoolAsync(EMAIL_VERIFIED) && getStringAsync(IS_EMAIL_VERIFICATION) == '1') {
                EmailVerificationScreen().launch(context, isNewTask: true);
              } else if (value.otpVerifyAt.isEmptyOrNull) {
                VerificationScreen().launch(context, isNewTask: true);
              } else {
                if (CityModel.fromJson(getJSONAsync(CITY_DATA)).name.validate().isNotEmpty) {
                  if (getStringAsync(USER_TYPE) == CLIENT) {
                    DashboardScreen().launch(context, isNewTask: true);
                  } else {
                    DeliveryDashBoard().launch(context, isNewTask: true);
                  }
                } else {
                  UserCitySelectScreen().launch(context, isNewTask: true);
                }
              }
            }
          }).catchError((e) {
            log(e);
          });
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
      backgroundColor: context.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(ic_logo, height: 80, width: 80, fit: BoxFit.fill).cornerRadiusWithClipRRect(defaultRadius),
            16.height,
            Text(mAppName, style: boldTextStyle(size: 20), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
