import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class EditProfileScreen extends StatefulWidget {
  static String tag = '/EditProfileScreen';

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode usernameFocus = FocusNode();
  FocusNode nameFocus = FocusNode();
  FocusNode contactFocus = FocusNode();
  FocusNode addressFocus = FocusNode();

  XFile? imageProfile;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    emailController.text = getStringAsync(USER_EMAIL);
    usernameController.text = getStringAsync(USER_NAME);
    nameController.text = getStringAsync(NAME);
    contactNumberController.text = getStringAsync(USER_CONTACT_NUMBER);
    addressController.text = getStringAsync(USER_ADDRESS).validate();
  }

  Widget profileImage() {
    if (imageProfile != null) {
      return Image.file(File(imageProfile!.path), height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(100).center();
    } else {
      if (getStringAsync(USER_PROFILE_PHOTO).isNotEmpty) {
        return Image.network(getStringAsync(USER_PROFILE_PHOTO), fit: BoxFit.cover, height: 100, width: 100).cornerRadiusWithClipRRect(100).center();
      } else {
        return Image.asset('assets/profile.png', height: 90, width: 90).cornerRadiusWithClipRRect(50).paddingOnly(right: 4, bottom: 4);
      }

      //return commonCachedNetworkImage(getStringAsync(USER_PHOTO_URL), fit: BoxFit.cover, height: 100, width: 100).cornerRadiusWithClipRRect(100).center();
    }
  }

  Future<void> getImage() async {
    imageProfile = null;
    imageProfile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
    setState(() {});
  }

  Future<void> save() async {
    await updateProfile(
      file: File(imageProfile!.path.validate()),
      name: nameController.text.validate(),
      userName: usernameController.text.validate(),
      userEmail: emailController.text.validate(),
      address: addressController.text.validate(),
      contactNumber: contactNumberController.text.validate(),
    ).then((value) {
      finish(context);
      // snackBar(context,)
    }).catchError((error) {
      log(error);
    });
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
                    children: [
                      profileImage(),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: EdgeInsets.only(top: 50, left: 80),
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: grey.withOpacity(0.3)),
                          child: IconButton(
                            onPressed: () {
                              getImage();
                            },
                            icon: Icon(Icons.edit, color: colorPrimary),
                          ),
                        ),
                      )
                    ],
                  ),
                  /*Stack(
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
                  ).center(),*/
                  16.height,
                  Text('Email', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: emailController,
                    textFieldType: TextFieldType.NAME,
                    focus: emailFocus,
                    nextFocus: usernameFocus,
                    decoration: commonInputDecoration(),
                  ),
                  16.height,
                  Text('Username', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: usernameController,
                    textFieldType: TextFieldType.PHONE,
                    focus: usernameFocus,
                    nextFocus: nameFocus,
                    decoration: commonInputDecoration(),
                  ),
                  16.height,
                  Text('Name', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: nameController,
                    textFieldType: TextFieldType.PHONE,
                    focus: nameFocus,
                    nextFocus: addressFocus,
                    decoration: commonInputDecoration(),
                  ),
                  16.height,
                  Text('Contact number', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: contactNumberController,
                    textFieldType: TextFieldType.PHONE,
                    focus: contactFocus,
                    nextFocus: addressFocus,
                    decoration: commonInputDecoration(),
                  ),
                  16.height,
                  Text('Address', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: addressController,
                    textFieldType: TextFieldType.ADDRESS,
                    focus: addressFocus,
                    decoration: commonInputDecoration(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: commonButton('Save Changes', () {
        save();
      }).paddingAll(16),
    );
  }
}
