import 'package:flutter/material.dart';
import 'package:localdelivery_flutter/main/utils/Colors.dart';
import 'package:localdelivery_flutter/main/utils/Common.dart';
import 'package:localdelivery_flutter/main/utils/Constants.dart';
import 'package:localdelivery_flutter/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class RegisterScreen extends StatefulWidget {
  static String tag = '/RegisterScreen';

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FlutterLogo(size: 70),
          30.height,
          Container(
            width: context.width(),
            padding: EdgeInsets.only(left: 16, right: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  30.height,
                  Text('Create an account', style: boldTextStyle(size: headingSize)),
                  8.height,
                  Text('Sign up to continue', style: secondaryTextStyle(size: 16)),
                  30.height,
                  Text('Name', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    decoration: commonInputDecoration(),
                  ),
                  16.height,
                  Text('Email', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.EMAIL,
                    decoration: commonInputDecoration(),
                  ),
                  16.height,
                  Text('Phone Number', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.PHONE,
                    decoration: commonInputDecoration(),
                  ),
                  16.height,
                  Text('Password', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.PASSWORD,
                    decoration: commonInputDecoration(),
                  ),
                  30.height,
                  commonButton('Sign Up', () {}, width: context.width()),
                  16.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?', style: primaryTextStyle()),
                      4.width,
                      Text('Sign In', style: boldTextStyle(color: colorPrimary)).onTap(() {
                        finish(context);
                      }),
                    ],
                  ),
                  16.height,
                ],
              ),
            ),
          ).expand(),
        ],
      ).paddingOnly(top: 50),
    );
  }
}
