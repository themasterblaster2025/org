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
import 'package:mighty_delivery/main/utils/DataProviders.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:mighty_delivery/user/components/CreateOrderConfirmationDialog.dart';
import 'package:mighty_delivery/user/components/SearchAddressWidget.dart';
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
  int? selectedPaymentIndex;

  bool isDeliverNow = true;
  bool isCashPayment = true;
  bool isOnDelivery = false;

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
      selectedWeight = widget.orderData!.totalWeight!.toInt();
      parcelTypeCont.text = widget.orderData!.parcelType!;

      pickAddressCont.text = widget.orderData!.pickupPoint!.address!;
      pickLat = widget.orderData!.pickupPoint!.latitude!;
      pickLong = widget.orderData!.pickupPoint!.longitude!;
      pickPhoneCont.text = widget.orderData!.pickupPoint!.contactNumber!;
      pickDesCont.text = widget.orderData!.pickupPoint!.description!;

      deliverAddressCont.text = widget.orderData!.deliveryPoint!.address!;
      pickLat = widget.orderData!.deliveryPoint!.latitude!;
      pickLong = widget.orderData!.deliveryPoint!.longitude!;
      deliverPhoneCont.text = widget.orderData!.deliveryPoint!.contactNumber!;
      deliverDesCont.text = widget.orderData!.deliveryPoint!.description!;

      isOnDelivery = widget.orderData!.paymentCollectFrom! == PAYMENT_ON_DELIVERY;
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

    /// calculate extra charges
    cityData!.extraCharges!.forEach((element) {
      if (element.chargesType == CHARGE_TYPE_PERCENTAGE) {
        num charge = ((totalAmount * element.charges! * 0.01)).toStringAsFixed(2).toDouble();
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
    print('total:$totalAmount');
    print('extraChargesObject : $extraChargesObject');
  }

  createOrderApiCall(String orderStatus) async {
    finish(context);
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
      "payment_collect_from": isOnDelivery ? PAYMENT_ON_DELIVERY : PAYMENT_ON_CLIENT,
      "status": orderStatus,
      "payment_type": "",
      "payment_status": "",
      "fixed_charges": cityData!.fixedCharges.toString(),
      "parent_order_id": "",
      "total_amount": totalAmount,
    };
    appStore.setLoading(true);
    await createOrder(req).then((value) {
      appStore.setLoading(false);
      toast(value.message);
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
            scheduleOptionWidget(isDeliverNow, 'assets/icons/ic_clock.png', 'Deliver Now').onTap(() {
              isDeliverNow = true;
              setState(() {});
            }).expand(),
            16.width,
            scheduleOptionWidget(!isDeliverNow, 'assets/icons/ic_schedule.png', 'Schedule').onTap(() {
              isDeliverNow = false;
              setState(() {});
            }).expand(),
          ],
        ),
        16.height,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pick Time', style: primaryTextStyle()),
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
                      Text('From', style: primaryTextStyle()),
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
                      Text('To', style: primaryTextStyle()),
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
                          double fromTimeInHour = pickFromTime!.hour + pickFromTime!.minute/60;
                          double toTimeInHour = pickToTime!.hour + pickToTime!.minute/60;
                          double difference = toTimeInHour - fromTimeInHour;
                          print(difference);
                          if(difference<=0){
                            return 'EndTime must be after StartTime';
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
            Text('Deliver Time', style: primaryTextStyle()),
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
                      Text('From', style: primaryTextStyle()),
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
                      Text('To', style: primaryTextStyle()),
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
                          double fromTimeInHour = deliverFromTime!.hour + deliverFromTime!.minute/60;
                          double toTimeInHour = deliverToTime!.hour + deliverToTime!.minute/60;
                          double difference = toTimeInHour - fromTimeInHour;
                          if(difference<0){
                            return 'EndTime must be after StartTime';
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
        Text('Weight', style: boldTextStyle()),
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
              if (value == null) return errorThisFieldRequired;
              return null;
            },
          ),
        ),
        /*  Wrap(
          spacing: 16,
          runSpacing: 16,
          children: weightList.map((item) {
            int index = weightList.indexOf(item);
            return Chip(
              backgroundColor: selectedWeightIndex == index ? colorPrimary : Colors.white,
              label: Text(item),
              elevation: 0,
              labelStyle: primaryTextStyle(color: selectedWeightIndex == index ? white : Colors.grey),
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultRadius),
                side: BorderSide(color: selectedWeightIndex == index ? colorPrimary : borderColor),
              ),
            ).onTap(() {
              selectedWeightIndex = index;
              setState(() {});
            });
          }).toList(),
        ),*/
        16.height,
        Text('What you are Sending?', style: boldTextStyle()),
        8.height,
        AppTextField(
          controller: parcelTypeCont,
          textFieldType: TextFieldType.OTHER,
          decoration: commonInputDecoration(),
          validator: (value) {
            if (value!.isEmpty) return errorThisFieldRequired;
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
        Text('Pickup Information', style: boldTextStyle()),
        16.height,
        Text('Address', style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: pickAddressCont,
          textInputAction: TextInputAction.next,
          readOnly: true,
          textFieldType: TextFieldType.ADDRESS,
          decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return errorThisFieldRequired;
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
        16.height.visible(pickLat != null && pickLong != null),
        Column(
          children: [
            Row(
              children: [
                Text('latitude: ', style: primaryTextStyle()),
                Text(pickLat.toString(), style: primaryTextStyle(size: 14)),
              ],
            ).visible(pickLat != null && pickLong != null),
            4.height,
            Row(
              children: [
                Text('longitude: ', style: primaryTextStyle()),
                Text(pickLong.toString(), style: primaryTextStyle(size: 14)),
              ],
            ),
          ],
        ).visible(pickLat != null && pickLong != null),
        16.height,
        Text('Contact Number', style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: pickPhoneCont,
          textFieldType: TextFieldType.PHONE,
          decoration: commonInputDecoration(suffixIcon: Icons.phone),
        ),
        16.height,
        Text('Description', style: primaryTextStyle()),
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
        Text('Delivery Information', style: boldTextStyle()),
        16.height,
        Text('Address', style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: deliverAddressCont,
          textInputAction: TextInputAction.next,
          readOnly: true,
          textFieldType: TextFieldType.ADDRESS,
          decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return errorThisFieldRequired;
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
        16.height.visible(deliverLat != null && deliverLong != null),
        Column(
          children: [
            Row(
              children: [
                Text('latitude: ', style: primaryTextStyle()),
                Text(deliverLat.toString(), style: primaryTextStyle(size: 14)),
              ],
            ),
            4.height,
            Row(
              children: [
                Text('longitude: ', style: primaryTextStyle()),
                Text(deliverLong.toString(), style: primaryTextStyle(size: 14)),
              ],
            )
          ],
        ).visible(deliverLat != null && deliverLong != null),
        16.height,
        Text('Contact Number', style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: deliverPhoneCont,
          textFieldType: TextFieldType.PHONE,
          decoration: commonInputDecoration(suffixIcon: Icons.phone),
        ),
        16.height,
        Text('Description', style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: deliverDesCont,
          textFieldType: TextFieldType.OTHER,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          maxLines: 3,
          minLines: 3,
        ),
        16.height,
        CheckboxListTile(
          title: Text('Collect Cash on delivery'),
          controlAffinity: ListTileControlAffinity.leading,
          value: isOnDelivery,
          contentPadding: EdgeInsets.zero,
          onChanged: (value) {
            isOnDelivery = value!;
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget CreateOrderWidget4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Package Information', style: boldTextStyle()),
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
                  Text('Parcel Type', style: primaryTextStyle()),
                  16.width,
                  Text(parcelTypeCont.text, style: primaryTextStyle()),
                ],
              ),
              8.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weight', style: primaryTextStyle()),
                  16.width,
                  Text('${selectedWeight} ${CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).weight_type}', style: primaryTextStyle()),
                ],
              ),
            ],
          ),
        ),
        16.height,
        Text('PickUp', style: boldTextStyle()),
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
        Text('Delivery', style: boldTextStyle()),
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
            Text('Delivery Charge', style: primaryTextStyle()),
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
                Text('Distance Charge', style: primaryTextStyle()),
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
                Text('Weight Charge', style: primaryTextStyle()),
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
        ).visible(weightCharge != 0 || distanceCharge != 0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,
            Text('Extra Charges', style: boldTextStyle()),
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
            Text('Total', style: boldTextStyle()),
            16.width,
            Text('$currencySymbol $totalAmount', style: boldTextStyle(size: 20)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(height: 30),
            Text('Payment', style: boldTextStyle()),
            16.height,
            Row(
              children: [
                scheduleOptionWidget(isCashPayment, 'assets/icons/ic_cash.png', 'Cash').onTap(() {
                  isCashPayment = true;
                  setState(() {});
                }).expand(),
                16.width,
                scheduleOptionWidget(!isCashPayment, 'assets/icons/ic_credit_card.png', 'Card').onTap(() {
                  isCashPayment = false;
                  setState(() {});
                }).expand(),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                Text('Payment Methods', style: boldTextStyle()),
                16.height,
                ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: paymentGatewayList.length,
                  itemBuilder: (context, index) {
                    String mData = paymentGatewayList[index];
                    return GestureDetector(
                      child: Container(
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: boxDecorationWithRoundedCorners(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(mData, style: boldTextStyle()),
                            Icon(Icons.check_circle, color: colorPrimary).visible(index == selectedPaymentIndex),
                          ],
                        ),
                      ),
                      onTap: () {
                        selectedPaymentIndex = index;
                        setState(() {});
                      },
                    );
                  },
                ),
              ],
            ).visible(!isCashPayment),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedTabIndex == 0) {
          /*DateTime now = DateTime.now();
          if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
            currentBackPressTime = now;
            toast('Tap back again to leave Screen');
            return false;
          }
          return true;*/
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
                message: 'Are you sure you want to save as a draft?',
                primaryText: 'Save Draft',
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
        appBar: appBarWidget('Create Order', color: colorPrimary, textColor: white, elevation: 0),
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
        bottomNavigationBar: Row(
          children: [
            if (selectedTabIndex != 0)
              outlineButton('Previous', () {
                selectedTabIndex--;
                setState(() {});
              }).paddingRight(16).expand(),
            commonButton(selectedTabIndex != 3 ? 'Next' : 'Create Order', () async {
              if (selectedTabIndex != 3) {
                if (_formKey.currentState!.validate()) {
                  Duration difference = Duration();
                  if (!isDeliverNow) {
                    pickFromDateTime = pickDate!.add(Duration(hours: pickFromTime!.hour, minutes: pickFromTime!.minute));
                    pickToDateTime = pickDate!.add(Duration(hours: pickToTime!.hour, minutes: pickToTime!.minute));
                    deliverFromDateTime = deliverDate!.add(Duration(hours: deliverFromTime!.hour, minutes: deliverFromTime!.minute));
                    deliverToDateTime = deliverDate!.add(Duration(hours: deliverToTime!.hour, minutes: deliverToTime!.minute));
                    difference = pickFromDateTime!.difference(deliverFromDateTime!);
                  }
                  if (difference.inMinutes > 0) return toast('PickupTime must be before DeliverTime');
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
                      message: 'Are you sure you want to Create Order?',
                      primaryText: 'Create',
                    );
                  },
                );
              }
            }).expand()
          ],
        ).paddingAll(16),
      ),
    );
  }
}
