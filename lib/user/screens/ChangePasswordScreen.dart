import 'package:flutter/material.dart';
import 'package:localdelivery_flutter/main/utils/Colors.dart';
import 'package:localdelivery_flutter/main/utils/Common.dart';
import 'package:localdelivery_flutter/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:nb_utils/src/extensions/widget_extensions.dart';

class ChangePasswordScreen extends StatefulWidget {
  static String tag = '/ChangePasswordScreen';

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
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

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          customAppBarWidget(context, 'Change Password', isShowBack: true),
          containerWidget(
            context,
            SingleChildScrollView(
              padding: EdgeInsets.only(left: 16, top: 30, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Old Password', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: oldPassController,
                    textFieldType: TextFieldType.PASSWORD,
                    focus: oldPassFocus,
                    nextFocus: newPassFocus,
                    decoration: commonInputDecoration(),
                  ),
                  16.height,
                  Text('New Password', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: newPassController,
                    textFieldType: TextFieldType.PASSWORD,
                    focus: newPassFocus,
                    nextFocus: confirmPassFocus,
                    decoration: commonInputDecoration(),
                  ),
                  16.height,
                  Text('Confirm Password', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: confirmPassController,
                    textFieldType: TextFieldType.PASSWORD,
                    focus: confirmPassFocus,
                    decoration: commonInputDecoration(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: commonButton('Save Changes', () {}).paddingAll(16),
    );
  }
}
