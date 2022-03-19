import 'dart:core';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
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

  int? selectedWeight;
  String? pickLat, pickLong, deliverLat, deliverLong;

  int selectedTabIndex = 0;
  int selectedWeightIndex = 0;

  bool isCashPayment = true;
  bool isDeliverNow = true;

  String paymentCollectFrom = PAYMENT_ON_PICKUP;

  DateTime? currentBackPressTime;

  num totalDistance = 0;
  num totalAmount = 0;

  num weightCharge = 0;
  num distanceCharge = 0;
  num totalExtraCharge = 0;

  Map<String, num> extraChargesObject = Map<String, num>();

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  Future<void> init() async {
    cityData = CityModel.fromJson(getJSONAsync(CITY_DATA));
    if (widget.orderData != null) {
      if(widget.orderData!.totalWeight!=0) selectedWeight = widget.orderData!.totalWeight!.toInt();
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
    getParcelTypeListApiCall();
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

    /// calculate weight Charge
    if (selectedWeight! > cityData!.minWeight!) {
      weightCharge = ((selectedWeight!.toDouble() - cityData!.minWeight!) * cityData!.perWeightCharges!).toStringAsFixed(2).toDouble();
    }

    /// calculate distance Charge
    if (totalDistance > cityData!.minDistance!) {
      distanceCharge = ((totalDistance - cityData!.minDistance!) * cityData!.perDistanceCharges!).toStringAsFixed(2).toDouble();
    }

    /// total amount
    totalAmount = cityData!.fixedCharges! + weightCharge + distanceCharge;
    print('totalAmount:$totalAmount');

    /// calculate extra charges
    cityData!.extraCharges!.forEach((element) {
      if (element.chargesType == CHARGE_TYPE_PERCENTAGE) {
        num charge = (totalAmount * element.charges! * 0.01).toStringAsFixed(2).toDouble();
        totalExtraCharge += charge;
        if (charge > 0) extraChargesObject.addEntries({MapEntry("${element.title!.toLowerCase().replaceAll(' ', "_")}", charge)});
      } else {
        num charge = element.charges!.toStringAsFixed(2).toDouble();
        totalExtraCharge += charge;
        if (charge > 0) extraChargesObject.addEntries({MapEntry("${element.title!.toLowerCase().replaceAll(' ', "_")}", charge)});
      }
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
      "extra_charges": extraChargesObject,
      "parcel_type": parcelTypeCont.text,
      "total_weight": selectedWeight.validate(),
      "total_distance": totalDistance.validate(),
      "payment_collect_from": paymentCollectFrom,
      "status": orderStatus,
      "payment_type": "",
      "payment_status": "",
      "fixed_charges": cityData!.fixedCharges.toString(),
      "parent_order_id": "",
      "total_amount": totalAmount,
      "weight_charge" : weightCharge,
      "distance_charge" : distanceCharge,
    };
    appStore.setLoading(true);
    await createOrder(req).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      finish(context);
      if(!isCashPayment){
        PaymentScreen(orderId: value.orderId.validate(), totalAmount: totalAmount).launch(context);
      }else{
        DashboardScreen().launch(context,isNewTask: true);
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

  Widget CreateOrderWidget1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            scheduleOptionWidget(isDeliverNow, 'assets/icons/ic_clock.png', language.delivery_now).onTap(() {
              isDeliverNow = true;
              setState(() {});
            }).expand(),
            16.width,
            scheduleOptionWidget(!isDeliverNow, 'assets/icons/ic_schedule.png', language.schedule).onTap(() {
              isDeliverNow = false;
              setState(() {});
            }).expand(),
          ],
        ),
        16.height,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language.pick_time, style: primaryTextStyle()),
            16.height,
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
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
                      setState(() {});
                    },
                    validator: (value) {
                      if (value!.isEmpty) return errorThisFieldRequired;
                    },
                    decoration: commonInputDecoration(suffixIcon: Icons.calendar_today),
                  ),
                  16.height,
                  Row(
                    children: [
                      Text(language.from, style: primaryTextStyle()),
                      8.width,
                      DateTimePicker(
                        controller: pickFromTimeController,
                        type: DateTimePickerType.time,
                        onChanged: (value) {
                          pickFromTime = TimeOfDay.fromDateTime(DateFormat('hh:mm').parse(value));
                          setState(() {});
                        },
                        validator: (value) {
                          if (value.validate().isEmpty) return errorThisFieldRequired;
                        },
                        decoration: commonInputDecoration(suffixIcon: Icons.access_time),
                      ).expand(),
                      16.width,
                      Text(language.to, style: primaryTextStyle()),
                      8.width,
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
                          print(difference);
                          if (difference <= 0) {
                            return language.end_time_validation_msg;
                          }
                        },
                        decoration: commonInputDecoration(suffixIcon: Icons.access_time),
                      ).expand(),
                    ],
                  ),
                ],
              ),
            ),
            16.height,
            Text(language.deliver_time, style: primaryTextStyle()),
            16.height,
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
              child: Column(
                children: [
                  DateTimePicker(
                    controller: deliverDateController,
                    type: DateTimePickerType.date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2050),
                    onChanged: (value) {
                      deliverDate = DateTime.parse(value);
                      setState(() {});
                    },
                    validator: (value) {
                      if (value!.isEmpty) return errorThisFieldRequired;
                    },
                    decoration: commonInputDecoration(suffixIcon: Icons.calendar_today),
                  ),
                  16.height,
                  Row(
                    children: [
                      Text(language.from, style: primaryTextStyle()),
                      8.width,
                      DateTimePicker(
                        controller: deliverFromTimeController,
                        type: DateTimePickerType.time,
                        onChanged: (value) {
                          deliverFromTime = TimeOfDay.fromDateTime(DateFormat('hh:mm').parse(value));
                          setState(() {});
                        },
                        validator: (value) {
                          if (value.validate().isEmpty) return errorThisFieldRequired;
                        },
                        decoration: commonInputDecoration(suffixIcon: Icons.access_time),
                      ).expand(),
                      16.width,
                      Text(language.to, style: primaryTextStyle()),
                      8.width,
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
                            return language.end_time_validation_msg;
                          }
                        },
                        decoration: commonInputDecoration(suffixIcon: Icons.access_time),
                      ).expand(),
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
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<int>(
            value: selectedWeight,
            decoration: commonInputDecoration(),
            items: List.generate(20, (index) {
              return DropdownMenuItem(
                value: index + 1,
                child: Text('${(index + 1).toString()} ${CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).weight_type}'),
              );
            }).toList(),
            onChanged: (value) {
              selectedWeight = value!;
              setState(() {});
            },
            validator: (value) {
              if (value == null) return language.field_required_msg;
              return null;
            },
          ),
        ),
        16.height,
        Text(language.parcel_type, style: boldTextStyle()),
        8.height,
        AppTextField(
          controller: parcelTypeCont,
          textFieldType: TextFieldType.OTHER,
          decoration: commonInputDecoration(),
          validator: (value) {
            if (value!.isEmpty) return language.field_required_msg;
            return null;
          },
        ),
        16.height,
        (appStore.isLoading && parcelTypeList.isEmpty)
            ? loaderWidget()
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: parcelTypeList.map((item) {
                  return Chip(
                    backgroundColor: Colors.white,
                    label: Text(item.label!),
                    elevation: 0,
                    labelStyle: primaryTextStyle(color: Colors.grey),
                    padding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultRadius),
                      side: BorderSide(color: borderColor),
                    ),
                  ).onTap(() {
                    parcelTypeCont.text = item.value!;
                    setState(() {});
                  });
                }).toList(),
              ),
      ],
    );
  }

  Widget CreateOrderWidget2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.pick_up_information, style: boldTextStyle()),
        16.height,
        Text(language.address, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: pickAddressCont,
          textInputAction: TextInputAction.next,
          readOnly: true,
          textFieldType: TextFieldType.ADDRESS,
          decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
           validator: (value) {
            if (value!.isEmpty) return language.field_required_msg;
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
        Text(language.contact_number, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: pickPhoneCont,
          textFieldType: TextFieldType.PHONE,
          decoration: commonInputDecoration(suffixIcon: Icons.phone),
          errorThisFieldRequired: language.field_required_msg,
        ),
        16.height,
        Text(language.description, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: pickDesCont,
          textFieldType: TextFieldType.OTHER,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          maxLines: 3,
          minLines: 3,
        ),
      ],
    );
  }

  Widget CreateOrderWidget3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.delivery_information, style: boldTextStyle()),
        16.height,
        Text(language.address, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: deliverAddressCont,
          textInputAction: TextInputAction.next,
          readOnly: true,
          textFieldType: TextFieldType.ADDRESS,
          decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return language.field_required_msg;
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
        Text(language.contact_number, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: deliverPhoneCont,
          textInputAction: TextInputAction.next,
          textFieldType: TextFieldType.PHONE,
          decoration: commonInputDecoration(suffixIcon: Icons.phone),
          errorThisFieldRequired: language.field_required_msg,
        ),
        16.height,
        Text(language.description, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: deliverDesCont,
          textFieldType: TextFieldType.OTHER,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          maxLines: 3,
          minLines: 3,
        ),
      ],
    );
  }

  Widget CreateOrderWidget4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.package_information, style: boldTextStyle()),
        8.height,
        Container(
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: borderColor),
            backgroundColor: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.parcel_type, style: primaryTextStyle()),
                  16.width,
                  Text(parcelTypeCont.text, style: primaryTextStyle()),
                ],
              ),
              8.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.weight, style: primaryTextStyle()),
                  16.width,
                  Text('${selectedWeight} ${CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).weight_type}', style: primaryTextStyle()),
                ],
              ),
            ],
          ),
        ),
        16.height,
        Text(language.pickup, style: boldTextStyle()),
        8.height,
        Container(
          width: context.width(),
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: borderColor),
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
        Text(language.delivery, style: boldTextStyle()),
        8.height,
        Container(
          width: context.width(),
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: borderColor),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(language.delivery_charge, style: primaryTextStyle()),
            16.width,
            Text('$currencySymbol ${cityData!.fixedCharges}', style: boldTextStyle()),
          ],
        ),
        Column(
          children: [
            8.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(language.distance_charge, style: primaryTextStyle()),
                16.width,
                Text('$currencySymbol $distanceCharge', style: boldTextStyle()),
              ],
            )
          ],
        ).visible(distanceCharge != 0),
        Column(
          children: [
            8.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(language.weight_charge, style: primaryTextStyle()),
                16.width,
                Text('$currencySymbol $weightCharge', style: boldTextStyle()),
              ],
            ),
          ],
        ).visible(weightCharge != 0),
        Align(
          alignment: Alignment.bottomRight,
          child: Column(
            children: [
              8.height,
              Text('$currencySymbol ${(cityData!.fixedCharges! + distanceCharge + weightCharge).toStringAsFixed(2)}', style: boldTextStyle()),
            ],
          ),
        ).visible((weightCharge != 0 || distanceCharge != 0) && extraChargesObject.keys.length != 0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,
            Text(language.extra_charges, style: boldTextStyle()),
            8.height,
            Column(
                children: List.generate(extraChargesObject.keys.length, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(extraChargesObject.keys.elementAt(index).replaceAll("_", " ").capitalizeFirstLetter(), style: primaryTextStyle()),
                    16.width,
                    Text('$currencySymbol ${extraChargesObject.values.elementAt(index)}', style: boldTextStyle()),
                  ],
                ),
              );
            }).toList()),
          ],
        ).visible(extraChargesObject.keys.length != 0),
        16.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(language.total, style: boldTextStyle()),
            16.width,
            Text('$currencySymbol $totalAmount', style: boldTextStyle(size: 20)),
          ],
        ),
        16.height,
        Text(language.payment, style: boldTextStyle()),
        16.height,
        Row(
          children: [
            scheduleOptionWidget(isCashPayment, 'assets/icons/ic_cash.png', language.cash_payment).onTap(() {
              isCashPayment = true;
              setState(() {});
            }).expand(),
            16.width,
            scheduleOptionWidget(!isCashPayment, 'assets/icons/ic_credit_card.png', language.online_payment).onTap(() {
              isCashPayment = false;
              setState(() {});
            }).expand(),
          ],
        ),
        16.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(language.payment_collect_from, style: boldTextStyle()),
            SizedBox(
              width: 150,
              child: DropdownButtonFormField<String>(
                value: paymentCollectFrom,
                decoration: commonInputDecoration(),
                items: [
                  DropdownMenuItem(value:PAYMENT_ON_PICKUP,child: Text(language.pickup, style: primaryTextStyle())),
                  DropdownMenuItem(value:PAYMENT_ON_DELIVERY,child: Text(language.delivery, style: primaryTextStyle())),
                ],
                onChanged: (value) {
                  paymentCollectFrom = value!;
                  setState(() { });
                },
              ),
            ),
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
                message: language.save_draft_confirmation_msg,
                primaryText: language.save_draft,
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
        appBar: appBarWidget(language.create_order, color: colorPrimary, textColor: white, elevation: 0),
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
                  if (selectedTabIndex == 0) CreateOrderWidget1(),
                  if (selectedTabIndex == 1) CreateOrderWidget2(),
                  if (selectedTabIndex == 2) CreateOrderWidget3(),
                  if (selectedTabIndex == 3) CreateOrderWidget4(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(16),
          color: context.cardColor,
          child: Row(
            children: [
              if (selectedTabIndex != 0)
                outlineButton(language.previous, () {
                  selectedTabIndex--;
                  setState(() {});
                }).paddingRight(16).expand(),
              commonButton(selectedTabIndex != 3 ? language.next : language.create_order, () async {
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
                    if(differenceCurrentTime.inMinutes > 0) return toast(language.pickup_current_validation_msg);
                    if (difference.inMinutes > 0) return toast(language.pickup_deliver_validation_msg);
                    selectedTabIndex++;
                    if (selectedTabIndex == 3) {
                      getTotalAmount();
                    }
                    setState(() {});
                  }
                } else {
                  await showInDialog(
                    context,
                    contentPadding: EdgeInsets.all(16),
                    builder: (p0) {
                      return CreateOrderConfirmationDialog(
                        onSuccess: () {
                          finish(context);
                          createOrderApiCall(ORDER_CREATE);
                        },
                        message: language.create_order_confirmation_msg,
                        primaryText: language.create,
                      );
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
