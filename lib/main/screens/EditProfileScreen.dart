import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
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
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
        return commonCachedNetworkImage(getStringAsync(USER_PROFILE_PHOTO).validate(), fit: BoxFit.cover, height: 100, width: 100).cornerRadiusWithClipRRect(100).center();
      } else {
        return commonCachedNetworkImage('assets/profile.png', height: 90, width: 90).cornerRadiusWithClipRRect(50).paddingOnly(right: 4, bottom: 4).center();
      }
    }
  }

  Future<void> getImage() async {
    imageProfile = null;
    imageProfile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
    setState(() {});
  }

  Future<void> save() async {
    appStore.setLoading(true);
    await updateProfile(
      file: imageProfile != null ? File(imageProfile!.path.validate()) : null,
      name: nameController.text.validate(),
      userName: usernameController.text.validate(),
      userEmail: emailController.text.validate(),
      address: addressController.text.validate(),
      contactNumber: contactNumberController.text.validate(),
    ).then((value) {
      finish(context);
      appStore.setLoading(false);
      snackBar(context, title: language.profile_update_msg);
    }).catchError((error) {
      log(error);
      appStore.setLoading(false);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(language.edit_profile, color: appStore.isDarkMode ? scaffoldSecondaryDark : colorPrimary, textColor: white, elevation: 0),
      body: BodyCornerWidget(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        profileImage(),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: EdgeInsets.only(top: 60, left: 80),
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: colorPrimary),
                            child: IconButton(
                              onPressed: () {
                                getImage();
                              },
                              icon: Icon(
                                Icons.edit,
                                color: white,
                                size: 20,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    16.height,
                    Text(language.email, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      readOnly: true,
                      controller: emailController,
                      textFieldType: TextFieldType.EMAIL,
                      focus: emailFocus,
                      nextFocus: usernameFocus,
                      decoration: commonInputDecoration(),
                      onTap: () {
                        toast(language.not_change_email);
                      },
                    ),
                    16.height,
                    Text(language.username, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      readOnly: true,
                      controller: usernameController,
                      textFieldType: TextFieldType.USERNAME,
                      focus: usernameFocus,
                      nextFocus: nameFocus,
                      decoration: commonInputDecoration(),
                      onTap: () {
                        toast(language.not_change_username);
                      },
                    ),
                    16.height,
                    Text(language.name, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: nameController,
                      textFieldType: TextFieldType.NAME,
                      focus: nameFocus,
                      nextFocus: addressFocus,
                      decoration: commonInputDecoration(),
                      errorThisFieldRequired: language.field_required_msg,
                    ),
                    16.height,
                    Text(language.contact_number, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: contactNumberController,
                      textFieldType: TextFieldType.PHONE,
                      focus: contactFocus,
                      nextFocus: addressFocus,
                      decoration: commonInputDecoration(),
                      errorThisFieldRequired: language.field_required_msg,
                    ),
                    16.height,
                    Text(language.address, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: addressController,
                      textFieldType: TextFieldType.ADDRESS,
                      focus: addressFocus,
                      decoration: commonInputDecoration(),
                    ),
                    16.height,
                  ],
                ),
              ),
            ),
            Observer(builder: (_) => loaderWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: commonButton(language.save_changes, () {
         if(_formKey.currentState!.validate()){
           save();
         }
        }),
      ),
    );
  }
}
