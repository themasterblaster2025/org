import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../delivery/screens/DeliveryDashBoard.dart';
import '../../main.dart';
import '../components/UserCitySelectScreen.dart';
import '../models/CityListModel.dart';

class RegisterScreen extends StatefulWidget {
  final String? userType;
  static String tag = '/RegisterScreen';

  RegisterScreen({this.userType});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String countryCode = '+91';

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

      appStore.setLoading(true);

      Map req = {
        "name": nameController.text.trim(),
        "username": userNameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passController.text.validate(),
        "user_type": widget.userType.validate(),
        "contact_number":  '${countryCode} ${phoneController.text.trim()}',
        "player_id": getStringAsync(PLAYER_ID).validate(),
      };
      await signUpApi(req).then((value) async {
        appStore.setLoading(false);
        UserCitySelectScreen().launch(context, isNewTask: true);
      }).catchError((error) {
        appStore.setLoading(false);
        toast(error.toString());
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
                child: Container(
                    height: 90,
                    width: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset('assets/app_logo_primary.png', height: 70, width: 70)),
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
                          errorThisFieldRequired: language.field_required_msg,
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
                          errorThisFieldRequired: language.field_required_msg,
                          errorInvalidUsername: language.username_invalid,
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
                          errorThisFieldRequired: language.field_required_msg,
                          errorInvalidEmail: language.email_invalid,
                        ),
                        16.height,
                        Text(language.contact_number, style: primaryTextStyle()),
                        8.height,
                        Container(
                          height: 100,
                          child: Row(
                            children: [
                              CountryCodePicker(
                                initialSelection: countryCode,
                                showCountryOnly: false,
                                showFlag: false,
                                showFlagDialog: true,
                                showOnlyCountryWhenClosed: false,
                                alignLeft: false,
                                textStyle: primaryTextStyle(),
                                onInit: (c) {
                                  countryCode = c!.dialCode!;
                                },
                                onChanged: (c) {
                                  countryCode = c.dialCode!;
                                },
                              ),
                              8.width,
                              AppTextField(
                                controller: phoneController,
                                textFieldType: TextFieldType.PHONE,
                                focus: phoneFocus,
                                nextFocus: passFocus,
                                decoration: commonInputDecoration(),
                                validator: (s){
                                  if (s!.trim().isEmpty)
                                    return language.field_required_msg;
                                  if (s.trim().length > 15)
                                    return language.contact_number_validation;
                                  return null;
                                },
                              ).expand(),
                            ],
                          ),
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
