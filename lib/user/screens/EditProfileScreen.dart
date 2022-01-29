import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class EditProfileScreen extends StatefulWidget {
  static String tag = '/EditProfileScreen';

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  FocusNode nameFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();

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
          customAppBarWidget(context, 'Edit Profile', isShowBack: true),
          containerWidget(
            context,
            SingleChildScrollView(
              padding: EdgeInsets.only(left: 16, top: 30, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: <Widget>[
                      Image.asset('assets/profile.png', height: 90, width: 90).cornerRadiusWithClipRRect(50).paddingOnly(right: 4, bottom: 4),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(color: colorPrimary, shape: BoxShape.circle),
                        child: Icon(Icons.camera_alt_outlined, color: Colors.white),
                      ),
                    ],
                  ).center(),
                  30.height,
                  Text('Name', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: nameController,
                    textFieldType: TextFieldType.NAME,
                    focus: nameFocus,
                    nextFocus: phoneFocus,
                    decoration: commonInputDecoration(),
                  ),
                  30.height,
                  Text('Phone Number', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: phoneController,
                    textFieldType: TextFieldType.PHONE,
                    focus: phoneFocus,
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
