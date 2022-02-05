import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mighty_delivery/delivery/screens/ConfirmDeliveryScreen.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class ReceivedScreenOrderScreen extends StatefulWidget {
  @override
  ReceivedScreenOrderScreenState createState() => ReceivedScreenOrderScreenState();
}

class ReceivedScreenOrderScreenState extends State<ReceivedScreenOrderScreen> {
  GlobalKey<SfSignaturePadState> signaturePicUPPadKey = GlobalKey();
  GlobalKey<SfSignaturePadState> signatureDeliveryPadKey = GlobalKey();

  ScreenshotController screenshotController = ScreenshotController();

  TextEditingController picUpController = TextEditingController();
  TextEditingController deliveryDateController = TextEditingController();
  TextEditingController clientController = TextEditingController();
  TextEditingController deliveryBoyNameController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController statusController = TextEditingController();

  XFile? imageProfile;
  Uint8List? pigUpSign;
  int val = 0;

  File? imageSignature;

  List<String> nameData = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  Future<void> selectPic() async {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                color: colorPrimary,
                text: 'Image Pic to Camera',
                textStyle: primaryTextStyle(color: white),
                onTap: () {
                  val = 1;
                  getImage();
                  finish(context);
                },
              ),
              16.height,
              AppButton(
                color: colorPrimary,
                text: 'Image Pic to Gallery',
                textStyle: primaryTextStyle(color: white),
                onTap: () {
                  val = 2;
                  getImage();
                  finish(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getImage() async {
    if (val == 1) {
      imageProfile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 100);
    } else {
      imageProfile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
    }
    setState(() {});
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
          customAppBarWidget(context, 'Delivery PicUp', isShowBack: true),
          containerWidget(
            context,
            SingleChildScrollView(
              padding: EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PicUp Datetime', style: boldTextStyle()),
                  8.height,
                  AppTextField(
                    readOnly: true,
                    textFieldType: TextFieldType.PHONE,
                    controller: picUpController,
                    onTap: () {
                      toast('show dialog Data');
                    },
                    decoration: commonInputDecoration(suffixIcon: Icons.schedule_outlined),
                  ),
                  16.height,
                  Text('Delivery Datetime', style: boldTextStyle()),
                  8.height,
                  AppTextField(
                    readOnly: true,
                    textFieldType: TextFieldType.PHONE,
                    controller: deliveryDateController,
                    onTap: () {
                      toast('show dialog Data');
                    },
                    decoration: commonInputDecoration(suffixIcon: Icons.schedule_outlined),
                  ),
                  16.height,
                  Text('Client name', style: boldTextStyle()),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    decoration: commonInputDecoration(),
                    controller: clientController,
                  ),
                  16.height,
                  Text('Delivery boy name', style: boldTextStyle()),
                  8.height,
                  AppTextField(
                    controller: deliveryBoyNameController,
                    textFieldType: TextFieldType.NAME,
                    decoration: commonInputDecoration(),
                  ),
                  16.height,
                  Text('PicUp time Signature', style: boldTextStyle()),
                  8.height,
                  Container(
                    height: 150,
                    width: context.width(),
                    decoration: BoxDecoration(border: Border.all(color: colorPrimary), borderRadius: BorderRadius.circular(defaultRadius)),
                    child: SfSignaturePad(
                      key: signaturePicUPPadKey,
                      minimumStrokeWidth: 1,
                      maximumStrokeWidth: 3,
                      strokeColor: colorPrimary,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      child: Text('Clear', style: boldTextStyle(color: colorPrimary, decoration: TextDecoration.underline)),
                      onPressed: () {
                        signaturePicUPPadKey.currentState!.clear();
                      },
                    ),
                  ),
                  Text('Delivery time Signature', style: boldTextStyle()),
                  8.height,
                  Container(
                    height: 150,
                    width: context.width(),
                    decoration: BoxDecoration(border: Border.all(color: colorPrimary), borderRadius: BorderRadius.circular(defaultRadius)),
                    child: Screenshot(
                      controller: screenshotController,
                      child: SfSignaturePad(
                        key: signatureDeliveryPadKey,
                        minimumStrokeWidth: 1,
                        maximumStrokeWidth: 3,
                        strokeColor: colorPrimary,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      child: Text('Clear', style: boldTextStyle(color: colorPrimary, decoration: TextDecoration.underline)),
                      onPressed: () async {
                        //
                      },
                    ),
                  ),
                  16.height,
                  Text('Add a product image', style: boldTextStyle()),
                  16.height,
                  imageProfile == null
                      ? Container(
                          height: 250,
                          width: context.width(),
                          decoration: BoxDecoration(border: Border.all(color: colorPrimary), borderRadius: BorderRadius.circular(defaultRadius)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: colorPrimary),
                              16.width,
                              Text('Upload a \nproduct image', style: primaryTextStyle()),
                            ],
                          ),
                        ).onTap(() {
                          selectPic();
                        })
                      : Image.file(File(imageProfile!.path), height: 250, width: context.width(), fit: BoxFit.cover).cornerRadiusWithClipRRect(defaultRadius),
                  if (imageProfile != null)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        child: Text('Change Image', style: boldTextStyle(color: colorPrimary, decoration: TextDecoration.underline)),
                        onPressed: () {
                          selectPic();
                        },
                      ),
                    ),
                  if (imageProfile == null) 16.height,
                  Text('Reason', style: boldTextStyle()),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    decoration: commonInputDecoration(),
                    controller: reasonController,
                  ),
                  16.height,
                  AppButton(
                    width: context.width(),
                    text: 'PicUp Delivery',
                    textStyle: primaryTextStyle(color: white),
                    color: colorPrimary,
                    onTap: () async {
                      screenshotController.capture(delay: Duration(milliseconds: 10)).then((capturedImage) {
                        imageSignature = File.fromRawPath(capturedImage!);
                      }).catchError((onError) {
                        print(onError);
                      });
                    },
                  ),
                  16.height,
                  AppButton(
                    text: 'Confirm Order',
                    textStyle: primaryTextStyle(color: white),
                    color: colorPrimary,
                    width: context.width(),
                    onTap: () {
                      ConfirmDeliveryScreen().launch(context,pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
