import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mighty_delivery/main.dart';
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
      snackBar(context, title: 'Profile update sucessfully');
    }).catchError((error) {
      log(error);
      appStore.setLoading(false);
    });
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
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
              padding: EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 16),
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
                  16.height,
                  Text('Email', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    readOnly: true,
                    controller: emailController,
                    textFieldType: TextFieldType.EMAIL,
                    focus: emailFocus,
                    nextFocus: usernameFocus,
                    decoration: commonInputDecoration(),
                  ),
                  16.height,
                  Text('Username', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    readOnly: true,
                    controller: usernameController,
                    textFieldType: TextFieldType.USERNAME,
                    focus: usernameFocus,
                    nextFocus: nameFocus,
                    decoration: commonInputDecoration(),
                  ),
                  16.height,
                  Text('Name', style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: nameController,
                    textFieldType: TextFieldType.NAME,
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
                    readOnly: true,
                    textFieldType: TextFieldType.ADDRESS,
                    focus: addressFocus,
                    decoration: commonInputDecoration(),
                    onTap: () async {
                      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
                      log('get location ${placemarks.map((e) {
                        addressController.text = e.locality!;
                        return e.locality;
                      })}');
                    },
                  ),
                  AppButton(
                    text: 'location',
                    onTap: () async {
                      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                      log('get location ${position.speedAccuracy}');
                    },
                  )
                ],
              ),
            ),
          ),
          Observer(builder: (_) => Loader().visible(appStore.isLoading))
        ],
      ),
      bottomNavigationBar: commonButton('Save Changes', () {
        save();
      }).paddingAll(16),
    );
  }
}
