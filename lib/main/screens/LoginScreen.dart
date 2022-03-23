import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/screens/ForgotPasswordScreen.dart';
import 'package:mighty_delivery/main/screens/RegisterScreen.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../components/UserCitySelectScreen.dart';

class LoginScreen extends StatefulWidget {
  static String tag = '/LoginScreen';

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
    setStatusBarColor(appStore.isDarkMode ? scaffoldSecondaryDark : colorPrimary, statusBarIconBrightness: Brightness.light);
    if (getStringAsync(PLAYER_ID).isEmpty) {
      await saveOneSignalPlayerId().then((value) {
        if (getStringAsync(PLAYER_ID).isEmpty) return toast(errorMessage);
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> LoginApiCall() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      appStore.setLoading(true);

      Map req = {
        "email": emailController.text,
        "password": passController.text,
        "player_id": getStringAsync(PLAYER_ID).validate(),
      };

      await logInApi(req).then((value) async {
        appStore.setLoading(false);
        if (getIntAsync(STATUS) == 1) {
            UserCitySelectScreen().launch(context, isNewTask: true);
        } else {
          toast(language.user_not_approve_msg);
        }
      }).catchError((e) {
        appStore.setLoading(false);

        toast(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? scaffoldSecondaryDark : colorPrimary,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: context.height() * 0.25,
                child: FlutterLogo(size: 70),
              ),
              Container(
                width: context.width(),
                padding: EdgeInsets.only(left: 24, right: 24),
                decoration: BoxDecoration(color: appStore.isDarkMode ? scaffoldColorDark : Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        30.height,
                        Text(language.sign_in_account, style: boldTextStyle(size: headingSize)),
                        8.height,
                        Text(language.sign_in_to_continue, style: secondaryTextStyle(size: 16)),
                        30.height,
                        Text(language.email, style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: emailController,
                          textFieldType: TextFieldType.EMAIL,
                          focus: emailFocus,
                          nextFocus: passFocus,
                          decoration: commonInputDecoration(),
                          errorThisFieldRequired: language.field_required_msg,
                          errorInvalidEmail: language.email_invalid,
                        ),
                        16.height,
                        Text(language.password, style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: passController,
                          textFieldType: TextFieldType.PASSWORD,
                          focus: passFocus,
                          decoration: commonInputDecoration(),
                          errorThisFieldRequired: language.field_required_msg,
                          errorMinimumPasswordLength: language.password_invalid,
                        ),
                        16.height,
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            child: Text(language.forgot_password_que, style: primaryTextStyle(color: colorPrimary)),
                            onPressed: () {
                              ForgotPasswordScreen().launch(context);
                            },
                          ),
                        ),
                        16.height,
                        commonButton(language.sign_in, () {
                          LoginApiCall();
                        }, width: context.width()),
                        16.height,
                       /* Row(
                          children: [
                            Divider().expand(),
                            8.width,
                            Text(language.or, style: secondaryTextStyle()),
                            8.width,
                            Divider().expand(),
                          ],
                        ),
                        16.height,
                        AppButton(
                          elevation: 0,
                          shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius), side: BorderSide(color: borderColor)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GoogleLogoWidget(),
                              16.width,
                              Text(language.continue_with_google, style: boldTextStyle()),
                            ],
                          ),
                          onTap: () {
                            //
                          },
                        ),
                        16.height,*/
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(language.do_not_have_account, style: primaryTextStyle()),
                            4.width,
                            Text(language.sign_up, style: boldTextStyle(color: colorPrimary)).onTap(() {
                              RegisterScreen().launch(context, duration: Duration(seconds: 1), pageRouteAnimation: PageRouteAnimation.Slide);
                            }),
                          ],
                        ),
                        16.height,
                      ],
                    ),
                  ),
                ),
              ).expand(),
            ],
          ),
          Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
