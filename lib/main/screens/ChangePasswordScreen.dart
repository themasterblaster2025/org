import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class ChangePasswordScreen extends StatefulWidget {
  static String tag = '/ChangePasswordScreen';

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  FocusNode oldPassFocus = FocusNode();
  FocusNode newPassFocus = FocusNode();
  FocusNode confirmPassFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
      Map req = {
        'old_password': oldPassController.text.trim(),
        'new_password': newPassController.text.trim(),
      };
      appStore.setLoading(true);

      await changePassword(req).then((value) {
        toast(value.message.toString());
        snackBar(context, title: value.message.validate());

        appStore.setLoading(false);

        finish(context);
      }).catchError((error) {
        appStore.setLoading(false);

        toast(error.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(language.change_password, color: appStore.isDarkMode ? scaffoldSecondaryDark : colorPrimary, textColor: white, elevation: 0),
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: BodyCornerWidget(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 16, top: 30, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(language.old_password, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                        controller: oldPassController,
                        textFieldType: TextFieldType.PASSWORD,
                        focus: oldPassFocus,
                        nextFocus: newPassFocus,
                        decoration: commonInputDecoration(),
                        errorThisFieldRequired: language.field_required_msg,
                        errorMinimumPasswordLength: language.password_invalid,
                    ),
                    16.height,
                    Text(language.new_password, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: newPassController,
                      textFieldType: TextFieldType.PASSWORD,
                      focus: newPassFocus,
                      nextFocus: confirmPassFocus,
                      decoration: commonInputDecoration(),
                      errorThisFieldRequired: language.field_required_msg,
                      errorMinimumPasswordLength: language.password_invalid,
                    ),
                    16.height,
                    Text(language.confirm_password, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: confirmPassController,
                      textFieldType: TextFieldType.PASSWORD,
                      focus: confirmPassFocus,
                      decoration: commonInputDecoration(),
                      errorThisFieldRequired: language.field_required_msg,
                      errorMinimumPasswordLength:language.password_invalid,
                      validator: (val) {
                        if (val!.isEmpty) return language.field_required_msg;
                        if (val != newPassController.text) return language.password_not_match;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: commonButton(language.save_changes, () {
          submit();
        }),
      ),
    );
  }
}
