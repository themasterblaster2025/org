import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/screens/LoginScreen.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:mighty_delivery/user/screens/DashboardScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';

class RegisterScreen extends StatefulWidget {
  static String tag = '/RegisterScreen';

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();

  FocusNode nameFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode passFocus = FocusNode();

  String? selectedUserType;

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

  Future<void> RegisterApiCall() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      if (selectedUserType == null) return toast(language.select_usertype_msg);

      appStore.setLoading(true);

      Map req = {
        "name": nameController.text.trim(),
        "username": userNameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passController.text.validate(),
        "user_type": selectedUserType,
        "contact_number": phoneController.text.trim(),
        "player_id": getStringAsync(PLAYER_ID).validate(),
      };
      await signUpApi(req).then((value) async {
        appStore.setLoading(false);
        if (getStringAsync(USER_TYPE) == CLIENT) {
          DashboardScreen().launch(context, isNewTask: true);
        } else {
          LoginScreen().launch(context);
        }
      }).catchError((error) {
        appStore.setLoading(false);
        toast(error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
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
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        30.height,
                        Text(language.create_an_account, style: boldTextStyle(size: headingSize)),
                        8.height,
                        Text(language.sign_up_to_continue, style: secondaryTextStyle(size: 16)),
                        30.height,
                        Text(language.name, style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: nameController,
                          textFieldType: TextFieldType.NAME,
                          focus: nameFocus,
                          nextFocus: userNameFocus,
                          decoration: commonInputDecoration(),
                        ),
                        16.height,
                        Text(language.username, style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: userNameController,
                          textFieldType: TextFieldType.USERNAME,
                          focus: userNameFocus,
                          nextFocus: emailFocus,
                          decoration: commonInputDecoration(),
                        ),
                        16.height,
                        Text(language.email, style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: emailController,
                          textFieldType: TextFieldType.EMAIL,
                          focus: emailFocus,
                          nextFocus: phoneFocus,
                          decoration: commonInputDecoration(),
                        ),
                        16.height,
                        Text(language.contact_number, style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: phoneController,
                          textFieldType: TextFieldType.PHONE,
                          focus: phoneFocus,
                          nextFocus: passFocus,
                          decoration: commonInputDecoration(),
                        ),
                        16.height,
                        Text(language.password, style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: passController,
                          textFieldType: TextFieldType.PASSWORD,
                          focus: passFocus,
                          decoration: commonInputDecoration(),
                        ),
                        16.height,
                        Text(language.user_type, style: primaryTextStyle()),
                        8.height,
                        Row(
                          children: [
                            RadioListTile(
                              contentPadding: EdgeInsets.zero,
                              groupValue: selectedUserType,
                              value: CLIENT,
                              title: Text(language.client),
                              onChanged: (String? value) {
                                selectedUserType = value;
                                setState(() {});
                              },
                            ).expand(),
                            RadioListTile(
                              contentPadding: EdgeInsets.zero,
                              groupValue: selectedUserType,
                              value: DELIVERY_MAN,
                              title: Text(language.delivery_man),
                              onChanged: (String? value) {
                                selectedUserType = value;
                                setState(() {});
                              },
                            ).expand(),
                          ],
                        ),
                        30.height,
                        commonButton(language.sign_up, () {
                          RegisterApiCall();
                        }, width: context.width()),
                        16.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(language.already_have_an_account, style: primaryTextStyle()),
                            4.width,
                            Text(language.sign_in, style: boldTextStyle(color: colorPrimary)).onTap(() {
                              finish(context);
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
      ).withHeight(context.height()),
    );
  }
}
