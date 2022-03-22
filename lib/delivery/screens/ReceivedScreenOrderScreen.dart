import 'dart:io';
import 'dart:typed_data';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/DataProviders.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class ReceivedScreenOrderScreen extends StatefulWidget {
  final OrderData? orderData;

  ReceivedScreenOrderScreen({this.orderData});

  @override
  ReceivedScreenOrderScreenState createState() => ReceivedScreenOrderScreenState();
}

class ReceivedScreenOrderScreenState extends State<ReceivedScreenOrderScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  GlobalKey<SfSignaturePadState> signaturePicUPPadKey = GlobalKey();
  GlobalKey<SfSignaturePadState> signatureDeliveryPadKey = GlobalKey();

  ScreenshotController picUpScreenshotController = ScreenshotController();
  ScreenshotController deliveryScreenshotController = ScreenshotController();

  TextEditingController picUpController = TextEditingController();
  TextEditingController deliveryDateController = TextEditingController();
  TextEditingController reasonController = TextEditingController();

  XFile? imageProfile;
  int val = 0;

  File? imageSignature;
  File? deliverySignature;
  bool mIsUpdate = false;
  int groupVal = 0;
  String? reason;

  List<AppModel> list = getReasonList();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    mIsUpdate = widget.orderData != null;
    if (mIsUpdate) {
      picUpController.text = widget.orderData!.pickupDatetime.validate();
      deliveryDateController.text = widget.orderData!.deliveryDatetime.validate();
      reasonController.text = widget.orderData!.reason.validate();
      reason = widget.orderData!.reason.validate();
    }
  }

  saveDelivery() async {
    appStore.setLoading(true);
    await updateOrder(
      orderId: widget.orderData!.id,
      pickupDatetime: picUpController.text,
      deliveryDatetime: deliveryDateController.text,
      clientName: imageSignature != null ? '1' : '0',
      deliveryman: deliverySignature != null ? '1' : '0',
      picUpSignature: imageSignature,
      reason: reasonController.text,
      deliverySignature: deliverySignature,
      orderStatus: widget.orderData!.status == ORDER_DEPARTED ? ORDER_COMPLETED : ORDER_PICKED_UP,
    ).then((value) {
      appStore.setLoading(false);

      toast(language.order_pickup_successfully);
      finish(context, true);
    }).catchError((error) {
      appStore.setLoading(false);

      log(error);
    });
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
                text: language.image_pick_to_camera,
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
                text: language.image_pic_to_gallery,
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
      appBar: appBarWidget(
        widget.orderData!.status == ORDER_DEPARTED ? language.order_deliver : language.order_pickup,
        color: colorPrimary,
        textColor: white,
        elevation: 0,
        backWidget: IconButton(
          onPressed: () {
            finish(context, false);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Form(
        key: formKey,
        child: Stack(
          children: [
            BodyCornerWidget(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.orderData!.paymentId == null)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black, blurRadius: 0.2),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(defaultRadius),
                                    bottomLeft: Radius.circular(defaultRadius),
                                  ),
                                  color: Color(0xffD9F5FF)),
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.info_outlined),
                            ),
                            16.width,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(language.info, style: boldTextStyle()),
                                4.height,
                                widget.orderData!.paymentCollectFrom == PAYMENT_ON_DELIVERY
                                    ? Text(language.payment_collect_from_delivery, style: secondaryTextStyle())
                                    : Text(language.payment_collect_from_pickup, style: secondaryTextStyle()),
                              ],
                            ),
                          ],
                        ),
                      ),
                    16.height,
                    Text(language.pickup_datetime, style: boldTextStyle()),
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
                            dateLabelText: language.date,
                            timeLabelText: language.hour,
                            onChanged: (val) {
                              picUpController.text = val;
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
                    if (widget.orderData!.status == ORDER_DEPARTED)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.delivery_datetime, style: boldTextStyle()),
                          8.height,
                          AppTextField(
                            readOnly: true,
                            textFieldType: TextFieldType.PHONE,
                            controller: deliveryDateController,
                            onTap: () {
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
                                  dateLabelText: language.date,
                                  timeLabelText: language.hour,
                                  /*selectableDayPredicate: (date) {
                                   if (date.weekday == 6 || date.weekday == 7) {
                                    return false;
                                  }
                                  return true;
                                  },*/
                                  onChanged: (val) {
                                    deliveryDateController.text = val;
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
                        ],
                      ),
                    16.height,
                    Text(language.pickup_time_signature, style: boldTextStyle()),
                    8.height,
                    widget.orderData!.pickupConfirmByClient == 1
                        ? commonCachedNetworkImage(widget.orderData!.pickupTimeSignature, fit: BoxFit.cover, height: 150, width: context.width())
                        : Container(
                            height: 150,
                            width: context.width(),
                            decoration: BoxDecoration(border: Border.all(color: colorPrimary), borderRadius: BorderRadius.circular(defaultRadius)),
                            child: Screenshot(
                              controller: picUpScreenshotController,
                              child: SfSignaturePad(
                                key: signaturePicUPPadKey,
                                minimumStrokeWidth: 1,
                                maximumStrokeWidth: 3,
                                strokeColor: colorPrimary,
                              ),
                            ),
                          ),
                    if (widget.orderData!.pickupConfirmByClient == 0)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: Text(language.save, style: boldTextStyle(color: colorPrimary, decoration: TextDecoration.underline)),
                              onPressed: () async {
                                await picUpScreenshotController.capture(delay: Duration(milliseconds: 10)).then((Uint8List? image) async {
                                  final tempDir = await getTemporaryDirectory();
                                  imageSignature = await File('${tempDir.path}/image.png').create();
                                  imageSignature!.writeAsBytesSync(image!);
                                  setState(() {});
                                }).catchError((onError) {
                                  print(onError);
                                });
                              },
                            ),
                            8.width,
                            TextButton(
                              child: Text(language.clear, style: boldTextStyle(color: colorPrimary, decoration: TextDecoration.underline)),
                              onPressed: () async {
                                signaturePicUPPadKey.currentState!.clear();
                              },
                            ),
                          ],
                        ),
                      ),
                    Text(language.delivery_time_signature, style: boldTextStyle()).visible(widget.orderData!.status == ORDER_DEPARTED || widget.orderData!.status == ORDER_COMPLETED),
                    8.height.visible(widget.orderData!.status == ORDER_DEPARTED || widget.orderData!.status == ORDER_COMPLETED),
                    if (widget.orderData!.status == ORDER_DEPARTED)
                      Container(
                        height: 150,
                        width: context.width(),
                        decoration: BoxDecoration(border: Border.all(color: colorPrimary), borderRadius: BorderRadius.circular(defaultRadius)),
                        child: Screenshot(
                          controller: deliveryScreenshotController,
                          child: SfSignaturePad(
                            key: signatureDeliveryPadKey,
                            minimumStrokeWidth: 1,
                            maximumStrokeWidth: 3,
                            strokeColor: colorPrimary,
                          ),
                        ),
                      ).visible(widget.orderData!.status == ORDER_DEPARTED || widget.orderData!.status == ORDER_COMPLETED),
                    if (widget.orderData!.status == ORDER_DEPARTED)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: Text(language.save, style: boldTextStyle(color: colorPrimary, decoration: TextDecoration.underline)),
                              onPressed: () async {
                                await deliveryScreenshotController.capture(delay: Duration(milliseconds: 10)).then((Uint8List? imageData) async {
                                  final tempDir = await getTemporaryDirectory();
                                  deliverySignature = await File('${tempDir.path}/image.png').create();
                                  deliverySignature!.writeAsBytesSync(imageData!);
                                  setState(() {});
                                }).catchError((onError) {
                                  log(onError);
                                });
                              },
                            ),
                            8.width,
                            TextButton(
                              child: Text(language.clear, style: boldTextStyle(color: colorPrimary, decoration: TextDecoration.underline)),
                              onPressed: () async {
                                signatureDeliveryPadKey.currentState!.clear();
                              },
                            ),
                          ],
                        ),
                      ).visible(widget.orderData!.status == ORDER_DEPARTED || widget.orderData!.status == ORDER_COMPLETED),
                    16.height,
                    Text(language.reason, style: boldTextStyle()),
                    8.height,
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: colorPrimary), borderRadius: BorderRadius.circular(defaultRadius)),
                      padding: EdgeInsets.only(left: 8, right: 8),
                      width: context.width(),
                      child: DropdownButton(
                          underline: SizedBox(),
                          style: primaryTextStyle(),
                          borderRadius: BorderRadius.circular(8),
                          isExpanded: true,
                          value: reason!.isNotEmpty ? reason : null,
                          items: list.map((e) {
                            return DropdownMenuItem(
                              value: e.name,
                              child: Text(e.name!),
                            );
                          }).toList(),
                          onChanged: (String? val) {
                            reason = val;
                            reasonController.text = val!;
                            setState(() {});
                          }),
                    ),
                    16.height,
                    Row(
                      children: [
                        AppButton(
                          width: context.width(),
                          text: widget.orderData!.status == ORDER_DEPARTED ? language.submit : language.pickup_delivery,
                          textStyle: primaryTextStyle(color: white),
                          color: colorPrimary,
                          onTap: () async {
                            if (picUpController.text.isEmpty) {
                              return toast(language.select_pickup_time_msg);
                            }
                            if (widget.orderData!.status == ORDER_DEPARTED) {
                              if (deliveryDateController.text.isEmpty) {
                                return toast(language.select_delivery_time_msg);
                              }
                            }

                            if (widget.orderData!.status == ORDER_ACTIVE || widget.orderData!.status == ORDER_ARRIVED) {
                              if (imageSignature == null) {
                                return toast(language.select_pickup_sign_msg);
                              }
                            }
                            if (widget.orderData!.status == ORDER_DEPARTED) {
                              if (deliverySignature == null) {
                                return toast(language.select_delivery_sign_msg);
                              }
                            }
                            if (widget.orderData!.paymentId == null &&
                                widget.orderData!.paymentCollectFrom == PAYMENT_ON_PICKUP &&
                                (widget.orderData!.status == ORDER_ACTIVE || widget.orderData!.status == ORDER_ARRIVED)) {
                              paymentConfirmDialog(widget.orderData!);
                            } else if (widget.orderData!.paymentId == null && widget.orderData!.paymentCollectFrom == PAYMENT_ON_DELIVERY && widget.orderData!.status == ORDER_DEPARTED) {
                              paymentConfirmDialog(widget.orderData!);
                            } else {
                              saveDelivery();
                            }
                          },
                        ).expand(),
                        16.width,
                        AppButton(
                          width: context.width(),
                          text: language.cancel,
                          textStyle: primaryTextStyle(color: white),
                          color: colorPrimary,
                          onTap: () async {
                            if (reasonController.text.isEmpty) {
                              return toast(language.select_reason_msg);
                            }
                            showConfirmDialogCustom(
                              context,
                              primaryColor: colorPrimary,
                              dialogType: DialogType.DELETE,
                              title: 'Are you sure you want to cancel this order?',
                              positiveText: language.yes,
                              negativeText: language.cancel,
                              onAccept: (c) async {
                                appStore.setLoading(true);
                                await updateOrder(orderId: widget.orderData!.id, reason: reasonController.text, orderStatus: ORDER_CANCELLED).then((value) {
                                  toast(language.order_cancelled_successfully);
                                  appStore.setLoading(false);
                                  finish(context, true);
                                }).catchError((error) {
                                  log(error);
                                  appStore.setLoading(false);
                                });
                              },
                            );
                          },
                        ).expand(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Observer(
              builder: (_) => loaderWidget().visible(appStore.isLoading),
            )
          ],
        ),
      ),
    );
  }

  Future<void> paymentConfirmDialog(OrderData orderData) {
    return showConfirmDialogCustom(
      context,
      primaryColor: colorPrimary,
      dialogType: DialogType.DELETE,
      title: language.collect_payment_confirmation_msg,
      positiveText: language.save,
      negativeText: language.cancel,
      onCancel: (c) async {
        await updateOrder(orderStatus: ORDER_CANCELLED, orderId: orderData.id);
        finish(context);
      },
      onAccept: (c) async {
        appStore.setLoading(true);
        Map req = {
          'order_id': orderData.id,
          'client_id': orderData.clientId,
          'datetime': picUpController.text,
          'total_amount': orderData.totalAmount,
          'payment_type': PAYMENT_TYPE_CASH,
          'payment_status': PAYMENT_PAID,
        };
        await savePayment(req).then((value) async {
          await saveDelivery().then((value) async {
            appStore.setLoading(false);
            finish(context);
          }).catchError((error) {
            appStore.setLoading(false);
            log(error);
          });
        }).catchError((error) {
          appStore.setLoading(false);
          log(error);
        });
      },
    );
  }
}
