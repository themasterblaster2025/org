import 'package:flutter/material.dart';
import 'package:localdelivery_flutter/user/screens/DashboardScreen.dart';
import 'package:localdelivery_flutter/main/screens/RegisterScreen.dart';
import 'package:localdelivery_flutter/main/utils/Colors.dart';
import 'package:localdelivery_flutter/main/utils/Common.dart';
import 'package:localdelivery_flutter/main/utils/Constants.dart';
import 'package:localdelivery_flutter/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class LoginScreen extends StatefulWidget {
  static String tag = '/LoginScreen';

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passFocus = FocusNode();

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
          Container(
            height: context.height() * 0.25,
            child: FlutterLogo(size: 70),
          ),
          Container(
            width: context.width(),
            padding: EdgeInsets.only(left: 24, right: 24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  30.height,
                  Text('Sign in Account', style: boldTextStyle(size: headingSize)),
                  8.height,
                  Text('Sign in to continue', style: secondaryTextStyle(size: 16)),
                  30.height,
                  Text('Email', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: emailController,
                    textFieldType: TextFieldType.EMAIL,
                    focus: emailFocus,
                    nextFocus: passFocus,
                    decoration: commonInputDecoration(),
                  ),
                  16.height,
                  Text('Password', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: passController,
                    textFieldType: TextFieldType.PASSWORD,
                    focus: passFocus,
                    decoration: commonInputDecoration(),
                  ),
                  16.height,
                  Align(alignment: Alignment.centerRight, child: Text('Forgot Password ?', style: primaryTextStyle(color: colorPrimary))),
                  30.height,
                  commonButton('Sign In', () {
                    DashboardScreen().launch(context);
                  }, width: context.width()),
                  16.height,
                  Row(
                    children: [
                      Divider().expand(),
                      8.width,
                      Text('Or', style: secondaryTextStyle()),
                      8.width,
                      Divider().expand(),
                    ],
                  ),
                  16.height,
                  AppButton(
                    elevation: 0,
                    shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius), side: BorderSide(color: Colors.grey.withOpacity(0.5))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GoogleLogoWidget(),
                        16.width,
                        Text('Continue with Google', style: boldTextStyle()),
                      ],
                    ),
                    onTap: () {},
                  ),
                  16.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Don\'t have an account?', style: primaryTextStyle()),
                      4.width,
                      Text('Sign Up', style: boldTextStyle(color: colorPrimary)).onTap(() {
                        RegisterScreen().launch(context,duration: Duration(seconds: 1),pageRouteAnimation: PageRouteAnimation.Slide);
                      }),
                    ],
                  ),
                  16.height,
                ],
              ),
            ),
          ).expand(),
        ],
      ),
      /* body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlutterLogo(size: 50),
            30.height,
            Text('Welcome Back!', style: primaryTextStyle(size: headingSize)),
            16.height,
            Text('Let\'s Get Start', style: secondaryTextStyle(size: 16)),
            30.height,
            Text('Email',style: primaryTextStyle()),
            8.height,
            AppTextField(
              textFieldType: TextFieldType.EMAIL,
              decoration: commonInputDecoration(),
            ),
            16.height,
            Text('Password',style: primaryTextStyle()),
            8.height,
            AppTextField(
              textFieldType: TextFieldType.PASSWORD,
              decoration: commonInputDecoration(),
            ),
            16.height,
            Align(alignment:Alignment.centerRight,child: Text('Forgot Password ?',style: primaryTextStyle())),
            30.height,
            commonButton('Login', (){},width: context.width()),
            16.height,
            Row(
              children: [
                Divider().expand(),
                8.width,
                Text('Or',style: secondaryTextStyle()),
                8.width,
                Divider().expand(),
              ],
            ),
            16.height,
            AppButton(
              elevation: 0,
              shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius),side: BorderSide(color: Colors.grey.withOpacity(0.5))),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GoogleLogoWidget(),
                  16.width,
                  Text('Continue with Google',style: boldTextStyle()),
                ],
              ),
              onTap: (){},
            ),
          ],
        ),
      ),*/
    );
  }
}
