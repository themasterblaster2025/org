import 'dart:io';
import 'dart:typed_data';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class ReceivedScreenOrderScreen extends StatefulWidget {
  final OrderData? orderData;

  ReceivedScreenOrderScreen({this.orderData});

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
  bool mIsUpdate = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    mIsUpdate = widget.orderData != null;
    if (mIsUpdate) {
      deliveryBoyNameController.text = widget.orderData!.deliveryManName!;
      clientController.text = widget.orderData!.clientName!;
    }
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

  Future<Widget> date() async {
    return DateTimePicker(
      type: DateTimePickerType.dateTimeSeparate,
      dateMask: 'd MMM, yyyy',
      initialValue: DateTime.now().toString(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      icon: Icon(Icons.event),
      dateLabelText: 'Date',
      timeLabelText: "Hour",
      selectableDayPredicate: (date) {
        // Disable weekend days to select from the calendar
        if (date.weekday == 6 || date.weekday == 7) {
          return false;
        }

        return true;
      },
      onChanged: (val) => print(val),
      validator: (val) {
        print(val);
        return null;
      },
      onSaved: (val) => print(val),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('Delivery PicUp', color: colorPrimary, textColor: white, elevation: 0),
      body: BodyCornerWidget(
        child: SingleChildScrollView(
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
                onTap: () async {
                  //
                },
                decoration: commonInputDecoration(
                  dateTime: IconButton(
                    onPressed: () {
                      //
                    },
                    icon: DateTimePicker(
                      type: DateTimePickerType.dateTime,
                      dateMask: 'd MMM, yyyy',
                      initialValue: DateTime.now().toString(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      icon: Icon(Icons.event),
                      dateLabelText: 'Date',
                      useRootNavigator: true,
                      timeLabelText: "Hour",
                      selectableDayPredicate: (date) {
                        if (date.weekday == 6 || date.weekday == 7) {
                          return false;
                        }

                        return true;
                      },
                      onChanged: (val) {
                        print(val);
                      },
                      validator: (val) {
                        print(val);
                        return null;
                      },
                      onSaved: (val) => print(val),
                    ),
                  ),
                ),
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
                readOnly: true,
                textFieldType: TextFieldType.NAME,
                decoration: commonInputDecoration(),
                controller: clientController,
              ),
              16.height,
              Text('Delivery boy name', style: boldTextStyle()),
              8.height,
              AppTextField(
                readOnly: true,
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
              Text('Delivery time Signature', style: boldTextStyle()).visible(widget.orderData!.status == ORDER_DEPARTED || widget.orderData!.status == ORDER_COMPLETED),
              8.height.visible(widget.orderData!.status == ORDER_DEPARTED || widget.orderData!.status == ORDER_COMPLETED),
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
              ).visible(widget.orderData!.status == ORDER_DEPARTED || widget.orderData!.status == ORDER_COMPLETED),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  child: Text('Clear', style: boldTextStyle(color: colorPrimary, decoration: TextDecoration.underline)),
                  onPressed: () async {
                    //
                  },
                ),
              ).visible(widget.orderData!.status == ORDER_DEPARTED || widget.orderData!.status == ORDER_COMPLETED),
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
              Row(
                children: [
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
                  ).expand(),
                  16.width,
                  AppButton(
                    width: context.width(),
                    text: 'Cancel',
                    textStyle: primaryTextStyle(color: white),
                    color: colorPrimary,
                    onTap: () async {
                      //
                    },
                  ).expand(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
