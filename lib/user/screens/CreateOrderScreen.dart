import 'dart:core';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/CityListModel.dart';
import 'package:mighty_delivery/main/models/CountryListModel.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'package:mighty_delivery/main/models/ParcelTypeListModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:mighty_delivery/user/components/CreateOrderConfirmationDialog.dart';
import 'package:mighty_delivery/user/components/PaymentScreen.dart';
import 'package:mighty_delivery/user/components/SearchAddressWidget.dart';
import 'package:mighty_delivery/user/screens/DashboardScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main/components/OrderSummeryWidget.dart';
import '../../main/models/ExtraChargeRequestModel.dart';

class CreateOrderScreen extends StatefulWidget {
  static String tag = '/CreateOrderScreen';

  final OrderData? orderData;

  CreateOrderScreen({this.orderData});

  @override
  CreateOrderScreenState createState() => CreateOrderScreenState();
}

class CreateOrderScreenState extends State<CreateOrderScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CityModel? cityData;
  List<ParcelTypeData> parcelTypeList = [];

  TextEditingController parcelTypeCont = TextEditingController();
  TextEditingController weightController = TextEditingController(text: '1');

  TextEditingController pickAddressCont = TextEditingController();
  TextEditingController pickPhoneCont = TextEditingController();
  TextEditingController pickDesCont = TextEditingController();
  TextEditingController pickDateController = TextEditingController();
  TextEditingController pickFromTimeController = TextEditingController();
  TextEditingController pickToTimeController = TextEditingController();

  TextEditingController deliverAddressCont = TextEditingController();
  TextEditingController deliverPhoneCont = TextEditingController();
  TextEditingController deliverDesCont = TextEditingController();
  TextEditingController deliverDateController = TextEditingController();
  TextEditingController deliverFromTimeController = TextEditingController();
  TextEditingController deliverToTimeController = TextEditingController();

  DateTime? pickFromDateTime, pickToDateTime, deliverFromDateTime, deliverToDateTime;
  DateTime? pickDate, deliverDate;
  TimeOfDay? pickFromTime, pickToTime, deliverFromTime, deliverToTime;

  String? pickLat, pickLong, deliverLat, deliverLong;

  int selectedTabIndex = 0;

  bool isCashPayment = true;
  bool isDeliverNow = true;

  String paymentCollectFrom = PAYMENT_ON_PICKUP;

  DateTime? currentBackPressTime;

  num totalDistance = 0;
  num totalAmount = 0;

  num weightCharge = 0;
  num distanceCharge = 0;
  num totalExtraCharge = 0;

  List<ExtraChargeRequestModel> extraChargeList = [];

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  Future<void> init() async {
    await getCityDetailApiCall(getIntAsync(CITY_ID));
    getParcelTypeListApiCall();
    extraChargesList();

    if (widget.orderData != null) {
      if (widget.orderData!.totalWeight != 0) weightController.text = widget.orderData!.totalWeight!.toString();
      parcelTypeCont.text = widget.orderData!.parcelType.validate();

      pickAddressCont.text = widget.orderData!.pickupPoint!.address.validate();
      pickLat = widget.orderData!.pickupPoint!.latitude.validate();
      pickLong = widget.orderData!.pickupPoint!.longitude.validate();
      pickPhoneCont.text = widget.orderData!.pickupPoint!.contactNumber.validate();
      pickDesCont.text = widget.orderData!.pickupPoint!.description.validate();

      deliverAddressCont.text = widget.orderData!.deliveryPoint!.address.validate();
      pickLat = widget.orderData!.deliveryPoint!.latitude.validate();
      pickLong = widget.orderData!.deliveryPoint!.longitude.validate();
      deliverPhoneCont.text = widget.orderData!.deliveryPoint!.contactNumber.validate();
      deliverDesCont.text = widget.orderData!.deliveryPoint!.description.validate();

      paymentCollectFrom = widget.orderData!.paymentCollectFrom.validate(value: PAYMENT_ON_PICKUP);
    }
  }

  extraChargesList() {
    extraChargeList.clear();
    extraChargeList.add(ExtraChargeRequestModel(key: FIXED_CHARGES, value: cityData!.fixedCharges, valueType: ""));
    extraChargeList.add(ExtraChargeRequestModel(key: MIN_DISTANCE, value: cityData!.minDistance, valueType: ""));
    extraChargeList.add(ExtraChargeRequestModel(key: MIN_WEIGHT, value: cityData!.minWeight, valueType: ""));
    extraChargeList.add(ExtraChargeRequestModel(key: PER_DISTANCE_CHARGE, value: cityData!.perDistanceCharges, valueType: ""));
    extraChargeList.add(ExtraChargeRequestModel(key: PER_WEIGHT_CHARGE, value: cityData!.perWeightCharges, valueType: ""));
    cityData!.extraCharges!.forEach((element) {
      extraChargeList.add(ExtraChargeRequestModel(key: element.title!.toLowerCase().replaceAll(' ', "_"), value: element.charges, valueType: element.chargesType));
    });
  }

  getCityDetailApiCall(int cityId) async {
    await getCityDetail(cityId).then((value) async {
      await setValue(CITY_DATA, value.data!.toJson());
      cityData = value.data!;
      setState(() {});
    }).catchError((error) {});
  }

  getParcelTypeListApiCall() async {
    appStore.setLoading(true);
    await getParcelTypeList().then((value) {
      appStore.setLoading(false);
      parcelTypeList.clear();
      parcelTypeList.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  getTotalAmount() {
    totalDistance = calculateDistance(pickLat.toDouble(), pickLong.toDouble(), deliverLat.toDouble(), deliverLong.toDouble());
    totalAmount = 0;
    weightCharge = 0;
    distanceCharge = 0;
    totalExtraCharge = 0;

    /// calculate weight Charge
    if (weightController.text.toDouble() > cityData!.minWeight!) {
      weightCharge = ((weightController.text.toDouble() - cityData!.minWeight!) * cityData!.perWeightCharges!).toStringAsFixed(2).toDouble();
    }

    /// calculate distance Charge
    if (totalDistance > cityData!.minDistance!) {
      distanceCharge = ((totalDistance - cityData!.minDistance!) * cityData!.perDistanceCharges!).toStringAsFixed(2).toDouble();
    }

    /// total amount
    totalAmount = cityData!.fixedCharges! + weightCharge + distanceCharge;

    /// calculate extra charges
    cityData!.extraCharges!.forEach((element) {
      totalExtraCharge += countExtraCharge(totalAmount: totalAmount, charges: element.charges!, chargesType: element.chargesType!);
    });

    /// All Charges
    totalAmount = (totalAmount + totalExtraCharge).toStringAsFixed(2).toDouble();
  }

  createOrderApiCall(String orderStatus) async {
    Map req = {
      "id": widget.orderData != null ? widget.orderData!.id : "",
      "client_id": getIntAsync(USER_ID).toString(),
      "date": DateTime.now().toString(),
      "country_id": getIntAsync(COUNTRY_ID).toString(),
      "city_id": getIntAsync(CITY_ID).toString(),
      "pickup_point": {
        "start_time": !isDeliverNow ? pickFromDateTime.toString() : DateTime.now().toString(),
        "end_time": !isDeliverNow ? pickToDateTime.toString() : null,
        "address": pickAddressCont.text,
        "latitude": pickLat,
        "longitude": pickLong,
        "description": pickDesCont.text,
        "contact_number": pickPhoneCont.text
      },
      "delivery_point": {
        "start_time": !isDeliverNow ? deliverFromDateTime.toString() : null,
        "end_time": !isDeliverNow ? deliverToDateTime.toString() : null,
        "address": deliverAddressCont.text,
        "latitude": deliverLat,
        "longitude": deliverLong,
        "description": deliverDesCont.text,
        "contact_number": deliverPhoneCont.text,
      },
      "extra_charges": extraChargeList,
      "parcel_type": parcelTypeCont.text,
      "total_weight": weightController.text.toInt(),
      "total_distance": totalDistance.toStringAsFixed(2).validate(),
      "payment_collect_from": paymentCollectFrom,
      "status": orderStatus,
      "payment_type": "",
      "payment_status": "",
      "fixed_charges": cityData!.fixedCharges.toString(),
      "parent_order_id": "",
      "total_amount": totalAmount,
      "weight_charge": weightCharge,
      "distance_charge": distanceCharge,
    };
    appStore.setLoading(true);
    await createOrder(req).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      finish(context);
      if (!isCashPayment) {
        PaymentScreen(orderId: value.orderId.validate(), totalAmount: totalAmount).launch(context);
      } else {
        DashboardScreen().launch(context, isNewTask: true);
      }
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget createOrderWidget1() {
    return Observer(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              scheduleOptionWidget(context, isDeliverNow, 'assets/icons/ic_clock.png', language.deliveryNow).onTap(() {
                isDeliverNow = true;
                setState(() {});
              }).expand(),
              16.width,
              scheduleOptionWidget(context, !isDeliverNow, 'assets/icons/ic_schedule.png', language.schedule).onTap(() {
                isDeliverNow = false;
                setState(() {});
              }).expand(),
            ],
          ),
          16.height,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(language.pickTime, style: boldTextStyle()),
              16.height,
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
                  borderRadius: BorderRadius.circular(defaultRadius),
                ),
                child: Column(
                  children: [
                    DateTimePicker(
                      controller: pickDateController,
                      type: DateTimePickerType.date,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2050),
                      onChanged: (value) {
                        pickDate = DateTime.parse(value);
                        deliverDate = null;
                        deliverDateController.clear();
                        setState(() {});
                      },
                      validator: (value) {
                        if (value!.isEmpty) return errorThisFieldRequired;
                        return null;
                      },
                      decoration: commonInputDecoration(suffixIcon: Icons.calendar_today, hintText: language.date),
                    ),
                    16.height,
                    Row(
                      children: [
                        DateTimePicker(
                          controller: pickFromTimeController,
                          type: DateTimePickerType.time,
                          onChanged: (value) {
                            pickFromTime = TimeOfDay.fromDateTime(DateFormat('hh:mm').parse(value));
                            setState(() {});
                          },
                          validator: (value) {
                            if (value.validate().isEmpty) return errorThisFieldRequired;
                            return null;
                          },
                          decoration: commonInputDecoration(suffixIcon: Icons.access_time, hintText: language.from),
                        ).expand(),
                        16.width,
                        DateTimePicker(
                          controller: pickToTimeController,
                          type: DateTimePickerType.time,
                          onChanged: (value) {
                            pickToTime = TimeOfDay.fromDateTime(DateFormat('hh:mm').parse(value));
                            setState(() {});
                          },
                          validator: (value) {
                            if (value.validate().isEmpty) return errorThisFieldRequired;
                            double fromTimeInHour = pickFromTime!.hour + pickFromTime!.minute / 60;
                            double toTimeInHour = pickToTime!.hour + pickToTime!.minute / 60;
                            double difference = toTimeInHour - fromTimeInHour;
                            if (difference <= 0) {
                              return language.endTimeValidationMsg;
                            }
                            return null;
                          },
                          decoration: commonInputDecoration(suffixIcon: Icons.access_time, hintText: language.to),
                        ).expand()
                      ],
                    ),
                  ],
                ),
              ),
              16.height,
              Text(language.deliverTime, style: boldTextStyle()),
              16.height,
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
                  borderRadius: BorderRadius.circular(defaultRadius),
                ),
                child: Column(
                  children: [
                    DateTimePicker(
                      controller: deliverDateController,
                      type: DateTimePickerType.date,
                      initialDate: pickDate ?? DateTime.now(),
                      firstDate: pickDate ?? DateTime.now(),
                      lastDate: DateTime(2050),
                      onChanged: (value) {
                        deliverDate = DateTime.parse(value);
                        setState(() {});
                      },
                      validator: (value) {
                        if (value!.isEmpty) return errorThisFieldRequired;
                        return null;
                      },
                      decoration: commonInputDecoration(suffixIcon: Icons.calendar_today, hintText: language.date),
                    ),
                    16.height,
                    Row(
                      children: [
                        DateTimePicker(
                          controller: deliverFromTimeController,
                          type: DateTimePickerType.time,
                          onChanged: (value) {
                            deliverFromTime = TimeOfDay.fromDateTime(DateFormat('hh:mm').parse(value));
                            setState(() {});
                          },
                          validator: (value) {
                            if (value.validate().isEmpty) return errorThisFieldRequired;
                            return null;
                          },
                          decoration: commonInputDecoration(suffixIcon: Icons.access_time, hintText: language.from),
                        ).expand(),
                        16.width,
                        DateTimePicker(
                          controller: deliverToTimeController,
                          type: DateTimePickerType.time,
                          onChanged: (value) {
                            deliverToTime = TimeOfDay.fromDateTime(DateFormat('hh:mm').parse(value));
                            setState(() {});
                          },
                          validator: (value) {
                            if (value!.isEmpty) return errorThisFieldRequired;
                            double fromTimeInHour = deliverFromTime!.hour + deliverFromTime!.minute / 60;
                            double toTimeInHour = deliverToTime!.hour + deliverToTime!.minute / 60;
                            double difference = toTimeInHour - fromTimeInHour;
                            if (difference < 0) {
                              return language.endTimeValidationMsg;
                            }
                            return null;
                          },
                          decoration: commonInputDecoration(suffixIcon: Icons.access_time, hintText: language.to),
                        ).expand()
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ).visible(!isDeliverNow),
          16.height,
          Text(language.weight, style: boldTextStyle()),
          8.height,
          Container(
            decoration: BoxDecoration(border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1), borderRadius: BorderRadius.circular(defaultRadius)),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(language.weight, style: primaryTextStyle()).paddingAll(12).expand(),
                  VerticalDivider(thickness: 1),
                  Icon(Icons.remove, color: appStore.isDarkMode ? Colors.white : Colors.grey).paddingAll(12).onTap(() {
                    if (weightController.text.toInt() > 1) {
                      weightController.text = (weightController.text.toInt() - 1).toString();
                    }
                  }),
                  VerticalDivider(thickness: 1),
                  Container(
                    width: 50,
                    child: AppTextField(
                      controller: weightController,
                      textAlign: TextAlign.center,
                      maxLength: 2,
                      textFieldType: TextFieldType.PHONE,
                      decoration: InputDecoration(
                        counterText: '',
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  VerticalDivider(thickness: 1),
                  Icon(Icons.add, color: appStore.isDarkMode ? Colors.white : Colors.grey).paddingAll(12).onTap(() {
                    weightController.text = (weightController.text.toInt() + 1).toString();
                  }),
                ],
              ),
            ),
          ),
          16.height,
          Text(language.parcelType, style: boldTextStyle()),
          8.height,
          AppTextField(
            controller: parcelTypeCont,
            textFieldType: TextFieldType.OTHER,
            decoration: commonInputDecoration(),
            validator: (value) {
              if (value!.isEmpty) return language.fieldRequiredMsg;
              return null;
            },
          ),
          16.height,
          (appStore.isLoading && parcelTypeList.isEmpty)
              ? loaderWidget()
              : Wrap(
                  spacing: 8,
                  runSpacing: 0,
                  children: parcelTypeList.map((item) {
                    return Chip(
                      backgroundColor: context.scaffoldBackgroundColor,
                      label: Text(item.label!),
                      elevation: 0,
                      labelStyle: primaryTextStyle(color: Colors.grey),
                      padding: EdgeInsets.zero,
                      labelPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        side: BorderSide(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
                      ),
                    ).onTap(() {
                      parcelTypeCont.text = item.label!;
                      setState(() {});
                    });
                  }).toList(),
                ),
        ],
      );
    });
  }

  Widget createOrderWidget2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.pickupInformation, style: boldTextStyle()),
        16.height,
        Text(language.pickupLocation, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: pickAddressCont,
          textInputAction: TextInputAction.next,
          readOnly: true,
          textFieldType: TextFieldType.MULTILINE,
          decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return language.fieldRequiredMsg;
            return null;
          },
          onTap: () async {
            List<dynamic> data = await SearchAddressWidget().launch(context);
            if (data.isNotEmpty) {
              pickAddressCont.text = data.first['address']!;
              pickLat = data.first['late'];
              pickLong = data.first['long'];
            }
          },
        ),
        16.height,
        Text(language.pickupContactNumber, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: pickPhoneCont,
          textFieldType: TextFieldType.PHONE,
          decoration: commonInputDecoration(suffixIcon: Icons.phone),
          validator: (value) {
            if (value!.trim().isEmpty) return language.fieldRequiredMsg;
            if (value.trim().length < 10 || value.trim().length > 14) return language.contactNumber;
            return null;
          },
        ),
        16.height,
        Text(language.pickupDescription, style: primaryTextStyle()),
        8.height,
        TextField(
          controller: pickDesCont,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.newline,
          maxLines: 3,
          minLines: 3,
        ),
      ],
    );
  }

  Widget createOrderWidget3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.deliveryInformation, style: boldTextStyle()),
        16.height,
        Text(language.deliveryLocation, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: deliverAddressCont,
          textInputAction: TextInputAction.next,
          readOnly: true,
          textFieldType: TextFieldType.MULTILINE,
          decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return language.fieldRequiredMsg;
            return null;
          },
          onTap: () async {
            List<dynamic> data = await SearchAddressWidget().launch(context);
            if (data.isNotEmpty) {
              deliverAddressCont.text = data.first['address']!;
              deliverLat = data.first['late'];
              deliverLong = data.first['long'];
            }
          },
        ),
        16.height,
        Text(language.deliveryContactNumber, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: deliverPhoneCont,
          textInputAction: TextInputAction.next,
          textFieldType: TextFieldType.PHONE,
          decoration: commonInputDecoration(suffixIcon: Icons.phone),
          validator: (value) {
            if (value!.trim().isEmpty) return language.fieldRequiredMsg;
            if (value.trim().length < 10 || value.trim().length > 14) return language.contactLength;
            return null;
          },
        ),
        16.height,
        Text(language.deliveryDescription, style: primaryTextStyle()),
        8.height,
        TextField(
          controller: deliverDesCont,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.newline,
          maxLines: 3,
          minLines: 3,
        ),
      ],
    );
  }

  Widget createOrderWidget4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.packageInformation, style: boldTextStyle()),
        8.height,
        Container(
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
            backgroundColor: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.parcelType, style: primaryTextStyle()),
                  16.width,
                  Text(parcelTypeCont.text, style: primaryTextStyle(), maxLines: 3, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis).expand(),
                ],
              ),
              8.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.weight, style: primaryTextStyle()),
                  16.width,
                  Text('${weightController.text} ${CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).weightType}', style: primaryTextStyle()),
                ],
              ),
            ],
          ),
        ),
        16.height,
        Text(language.pickupLocation, style: boldTextStyle()),
        8.height,
        Container(
          width: context.width(),
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
            backgroundColor: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pickAddressCont.text, style: primaryTextStyle()),
              8.height.visible(pickPhoneCont.text.isNotEmpty),
              Text(pickPhoneCont.text, style: secondaryTextStyle()).visible(pickPhoneCont.text.isNotEmpty),
            ],
          ),
        ),
        16.height,
        Text(language.deliveryLocation, style: boldTextStyle()),
        8.height,
        Container(
          width: context.width(),
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
            backgroundColor: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(deliverAddressCont.text, style: primaryTextStyle()),
              8.height.visible(deliverPhoneCont.text.isNotEmpty),
              Text(deliverPhoneCont.text, style: secondaryTextStyle()).visible(deliverPhoneCont.text.isNotEmpty),
            ],
          ),
        ),
        Divider(height: 30),
        OrderSummeryWidget(
            extraChargesList: extraChargeList,
            totalDistance: totalDistance,
            totalWeight: weightController.text.toDouble(),
            distanceCharge: distanceCharge,
            weightCharge: weightCharge,
            totalAmount: totalAmount),
        16.height,
        Text(language.payment, style: boldTextStyle()),
        16.height,
        Row(
          children: [
            scheduleOptionWidget(context, isCashPayment, 'assets/icons/ic_cash.png', language.cash).onTap(() {
              isCashPayment = true;
              setState(() {});
            }).expand(),
            16.width,
            scheduleOptionWidget(context, !isCashPayment, 'assets/icons/ic_credit_card.png', language.online).onTap(() {
              isCashPayment = false;
              setState(() {});
            }).expand(),
          ],
        ),
        16.height,
        Row(
          children: [
            Text(language.paymentCollectFrom, style: boldTextStyle()),
            16.width,
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: paymentCollectFrom,
              decoration: commonInputDecoration(),
              items: [
                DropdownMenuItem(value: PAYMENT_ON_PICKUP, child: Text(language.pickupLocation, style: primaryTextStyle(), maxLines: 1)),
                DropdownMenuItem(value: PAYMENT_ON_DELIVERY, child: Text(language.deliveryLocation, style: primaryTextStyle(), maxLines: 1)),
              ],
              onChanged: (value) {
                paymentCollectFrom = value!;
                setState(() {});
              },
            ).expand(),
          ],
        ).visible(isCashPayment),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedTabIndex == 0) {
          await showInDialog(
            context,
            contentPadding: EdgeInsets.all(16),
            builder: (p0) {
              return CreateOrderConfirmationDialog(
                onCancel: () {
                  finish(context);
                  finish(context);
                },
                onSuccess: () {
                  finish(context);
                  createOrderApiCall(ORDER_DRAFT);
                },
                message: language.saveDraftConfirmationMsg,
                primaryText: language.saveDraft,
              );
            },
          );
          return false;
        } else {
          selectedTabIndex--;
          setState(() {});
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(language.createOrder)),
        body: BodyCornerWidget(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(4, (index) {
                      return Container(
                        color: selectedTabIndex >= index ? colorPrimary : borderColor,
                        height: 5,
                        width: context.width() * 0.15,
                      );
                    }).toList(),
                  ),
                  30.height,
                  if (selectedTabIndex == 0) createOrderWidget1(),
                  if (selectedTabIndex == 1) createOrderWidget2(),
                  if (selectedTabIndex == 2) createOrderWidget3(),
                  if (selectedTabIndex == 3) createOrderWidget4(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(16),
          color: context.scaffoldBackgroundColor,
          child: Row(
            children: [
              if (selectedTabIndex != 0)
                outlineButton(language.previous, () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  selectedTabIndex--;
                  setState(() {});
                }).paddingRight(16).expand(),
              commonButton(selectedTabIndex != 3 ? language.next : language.createOrder, () async {
                FocusScope.of(context).requestFocus(new FocusNode());
                if (selectedTabIndex != 3) {
                  if (_formKey.currentState!.validate()) {
                    Duration difference = Duration();
                    Duration differenceCurrentTime = Duration();
                    if (!isDeliverNow) {
                      pickFromDateTime = pickDate!.add(Duration(hours: pickFromTime!.hour, minutes: pickFromTime!.minute));
                      pickToDateTime = pickDate!.add(Duration(hours: pickToTime!.hour, minutes: pickToTime!.minute));
                      deliverFromDateTime = deliverDate!.add(Duration(hours: deliverFromTime!.hour, minutes: deliverFromTime!.minute));
                      deliverToDateTime = deliverDate!.add(Duration(hours: deliverToTime!.hour, minutes: deliverToTime!.minute));
                      difference = pickFromDateTime!.difference(deliverFromDateTime!);
                      differenceCurrentTime = DateTime.now().difference(pickFromDateTime!);
                    }
                    if (differenceCurrentTime.inMinutes > 0) return toast(language.pickupCurrentValidationMsg);
                    if (difference.inMinutes > 0) return toast(language.pickupDeliverValidationMsg);
                    selectedTabIndex++;
                    if (selectedTabIndex == 3) {
                      getTotalAmount();
                    }
                    setState(() {});
                  }
                } else {
                  showConfirmDialog(
                    context,
                    language.createOrderConfirmationMsg,
                    positiveText: language.yes,
                    negativeText: language.no,
                    onAccept: () {
                      createOrderApiCall(ORDER_CREATE);
                    },
                  );
                }
              }).expand()
            ],
          ),
        ),
      ),
    );
  }
}
