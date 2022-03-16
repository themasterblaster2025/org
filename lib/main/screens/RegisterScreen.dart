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

      if (selectedUserType == null) return toast('Please select Usertype');

      appStore.setLoading(true);

      Map req = {
        "name": nameController.text.trim(),
        "username": userNameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passController.text.validate(),
        "user_type": selectedUserType,
        "contact_number": phoneController.text.trim(),
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
                        Text('Create an account', style: boldTextStyle(size: headingSize)),
                        8.height,
                        Text('Sign up to continue', style: secondaryTextStyle(size: 16)),
                        30.height,
                        Text('Name', style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: nameController,
                          textFieldType: TextFieldType.NAME,
                          focus: nameFocus,
                          nextFocus: userNameFocus,
                          decoration: commonInputDecoration(),
                        ),
                        16.height,
                        Text('Username', style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: userNameController,
                          textFieldType: TextFieldType.USERNAME,
                          focus: userNameFocus,
                          nextFocus: emailFocus,
                          decoration: commonInputDecoration(),
                        ),
                        16.height,
                        Text('Email', style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: emailController,
                          textFieldType: TextFieldType.EMAIL,
                          focus: emailFocus,
                          nextFocus: phoneFocus,
                          decoration: commonInputDecoration(),
                        ),
                        16.height,
                        Text('Contact Number', style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: phoneController,
                          textFieldType: TextFieldType.PHONE,
                          focus: phoneFocus,
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
                        Text('User Type', style: primaryTextStyle()),
                        8.height,
                        Row(
                          children: [
                            RadioListTile(
                              contentPadding: EdgeInsets.zero,
                              groupValue: selectedUserType,
                              value: CLIENT,
                              title: Text('Client'),
                              onChanged: (String? value) {
                                selectedUserType = value;
                                setState(() {});
                              },
                            ).expand(),
                            RadioListTile(
                              contentPadding: EdgeInsets.zero,
                              groupValue: selectedUserType,
                              value: DELIVERY_MAN,
                              title: Text('Delivery Boy'),
                              onChanged: (String? value) {
                                selectedUserType = value;
                                setState(() {});
                              },
                            ).expand(),
                          ],
                        ),
                        30.height,
                        commonButton('Sign Up', () {
                          RegisterApiCall();
                        }, width: context.width()),
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
                ),
              ).expand(),
            ],
          ),
          Observer(builder: (context) => Loader().visible(appStore.isLoading)),
        ],
      ).withHeight(context.height()),
    );
  }
}
