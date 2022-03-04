import 'dart:core';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/CityListModel.dart';
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

  @override
  CreateOrderScreenState createState() => CreateOrderScreenState();
}

class CreateOrderScreenState extends State<CreateOrderScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<ParcelTypeData> parcelTypeList = [];
  CityModel? cityData;

  TextEditingController parcelTypeCont = TextEditingController();

  TextEditingController pickAddressCont = TextEditingController();
  TextEditingController pickPhoneCont = TextEditingController();
  TextEditingController pickDateCont = TextEditingController();
  TextEditingController pickFromTimeCont = TextEditingController();
  TextEditingController pickToTimeCont = TextEditingController();
  TextEditingController pickDesCont = TextEditingController();
  TextEditingController pickStartTimeController = TextEditingController();
  TextEditingController pickEndTimeController = TextEditingController();

  TextEditingController deliverAddressCont = TextEditingController();
  TextEditingController deliverPhoneCont = TextEditingController();
  TextEditingController deliverDateCont = TextEditingController();
  TextEditingController deliverFromTimeCont = TextEditingController();
  TextEditingController deliverToTimeCont = TextEditingController();
  TextEditingController deliverDesCont = TextEditingController();

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

  Map<String, num> allChargesObject = Map<String, num>();
  Map<String, num> extraChargesObject = Map<String, num>();

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  Future<void> init() async {
    getParcelTypeListApiCall();
    await getCityDetailApiCall();
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

  getCityDetailApiCall() async {
    await getCityDetail(getIntAsync(CITY_ID)).then((value) {
      cityData = value.data;
    }).catchError((error) {
      toast(error.toString());
    });
  }

  getTotalAmount() {
    if (cityData != null) {
      totalDistance = calculateDistance(pickLat.toDouble(), pickLong.toDouble(), deliverLat.toDouble(), deliverLong.toDouble());
      num weightCharge = 0;
      num distanceCharge = 0;
      num totalExtraCharge = 0;

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
      //  allChargesObject.addEntries({MapEntry("delivery_charge", cityData!.fixedCharges!)});
      if (weightCharge > 0) allChargesObject.addEntries({MapEntry("weight_charge", weightCharge)});
      if (distanceCharge > 0) allChargesObject.addEntries({MapEntry("distance_charge", distanceCharge)});
      allChargesObject.addAll(extraChargesObject);

      totalAmount = (totalAmount + totalExtraCharge).toStringAsFixed(2).toDouble();
      print('total:$totalAmount');
      print('extraChargesObject : $extraChargesObject');
      print('allChargesObject : $allChargesObject');
    }
  }

  createOrderApiCall(String status) async {
    finish(context);
    Map req = {
      "client_id": getIntAsync(USER_ID).toString(),
      "date": DateTime.now().toString(),
      "country_id": getIntAsync(COUNTRY_ID).toString(),
      "city_id": getIntAsync(CITY_ID).toString(),
      "pickup_point": {
        if (!isDeliverNow) "start_time": pickStartTimeController.text,
        if (!isDeliverNow) "end_time": pickEndTimeController.text,
        "address": pickAddressCont.text,
        "latitude": pickLat,
        "longitude": pickLong,
        "description": pickDesCont.text,
        "contact_number": pickPhoneCont.text
      },
      "delivery_point": {
        if (!isDeliverNow) "start_time": DateTime.now().toString(),
        if (!isDeliverNow) "end_time": DateTime.now().toString(),
        "address": deliverAddressCont.text,
        "latitude": deliverLat,
        "longitude": deliverLong,
        "description": deliverDesCont.text,
        "contact_number": deliverPhoneCont.text,
      },
      "extra_charges": allChargesObject,
      "parcel_type": parcelTypeCont.text,
      "total_weight": selectedWeight!.toString(),
      "total_distance": totalDistance.toString(),
      "payment_collect_from": isOnDelivery ? "on_delivery" : "on_client",
      "status": status,
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
                child: Text('${(index + 1).toString()} Kg'),
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
            ? Loader()
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,
            Text('Pickup Time', style: primaryTextStyle()),
            8.height,
            /* AppTextField(
              textFieldType: TextFieldType.OTHER,
              controller: pickDateCont,
              readOnly: true,
              decoration: commonInputDecoration(suffixIcon: Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
                if (picked != null)
                  setState(() {
                    pickDateCont.text = DateFormat('dd/MM/yyyy').format(picked);
                  });
              },
            ),
            16.height,
            Row(
              children: [
                Text('From', style: primaryTextStyle()),
                8.width,
                AppTextField(
                  textFieldType: TextFieldType.OTHER,
                  controller: pickFromTimeCont,
                  decoration: commonInputDecoration(suffixIcon: Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickFromTimeCont.text.isNotEmpty) pickFromTimeCont.text = '${picked!.hour}:${picked.minute}';
                  },
                ).expand(),
                16.width,
                Text('To', style: primaryTextStyle()),
                8.width,
                AppTextField(
                  textFieldType: TextFieldType.OTHER,
                  controller: pickToTimeCont,
                  decoration: commonInputDecoration(suffixIcon: Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickToTimeCont.text.isNotEmpty) pickToTimeCont.text = '${picked!.hour}:${picked.minute}';
                  },
                ).expand(),
              ],
            ),*/
            8.height,
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('From', style: primaryTextStyle()).expand(flex: 1),
                      8.width,
                      DateTimePicker(
                        controller: pickStartTimeController,
                        type: DateTimePickerType.dateTime,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        decoration: commonInputDecoration(suffixIcon: Icons.date_range),
                        dateLabelText: 'Date',
                        onChanged: (val) => print(val),
                        validator: (val) {
                          if (val!.isEmpty) return errorThisFieldRequired;
                          return null;
                        },
                        onSaved: (val) => print(val),
                      ).expand(flex: 3),
                    ],
                  ),
                  16.height,
                  Row(
                    children: [
                      Text('To', style: primaryTextStyle()).expand(flex: 1),
                      8.width,
                      DateTimePicker(
                        controller: pickEndTimeController,
                        type: DateTimePickerType.dateTime,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        decoration: commonInputDecoration(suffixIcon: Icons.date_range),
                        dateLabelText: 'Date',
                        onChanged: (val) => print(val),
                        validator: (val) {
                          if (val!.isEmpty) return errorThisFieldRequired;
                          return null;
                        },
                        onSaved: (val) => print(val),
                      ).expand(flex: 3),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ).visible(!isDeliverNow),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,
            Text('Deliver Time', style: primaryTextStyle()),
            8.height,
            AppTextField(
              textFieldType: TextFieldType.OTHER,
              controller: deliverDateCont,
              readOnly: true,
              decoration: commonInputDecoration(suffixIcon: Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
                if (picked != null)
                  setState(() {
                    deliverDateCont.text = DateFormat('dd/MM/yyyy').format(picked);
                  });
              },
            ),
            16.height,
            Row(
              children: [
                Text('From', style: primaryTextStyle()),
                8.width,
                AppTextField(
                  textFieldType: TextFieldType.OTHER,
                  controller: deliverFromTimeCont,
                  decoration: commonInputDecoration(suffixIcon: Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (deliverFromTimeCont.text.isNotEmpty) deliverFromTimeCont.text = '${picked!.hour}:${picked.minute}';
                  },
                ).expand(),
                16.width,
                Text('To', style: primaryTextStyle()),
                8.width,
                AppTextField(
                  textFieldType: TextFieldType.OTHER,
                  controller: deliverToTimeCont,
                  decoration: commonInputDecoration(suffixIcon: Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (deliverToTimeCont.text.isNotEmpty) deliverToTimeCont.text = '${picked!.hour}:${picked.minute}';
                  },
                ).expand(),
              ],
            ),
          ],
        ).visible(!isDeliverNow),
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
                  Text('${selectedWeight} Kg', style: primaryTextStyle()),
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
            Text(cityData!.fixedCharges.toString(), style: boldTextStyle()),
          ],
        ),
        8.height,
        Column(
            children: List.generate(allChargesObject.keys.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(allChargesObject.keys.elementAt(index).replaceAll("_", " ").capitalizeFirstLetter(), style: primaryTextStyle()),
                16.width,
                Text(allChargesObject.values.elementAt(index).toString(), style: boldTextStyle()),
              ],
            ),
          );
        }).toList()),
        16.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: boldTextStyle()),
            16.width,
            Text('$totalAmount', style: boldTextStyle(size: 20)),
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
                scheduleOptionWidget(!isCashPayment, 'assets/icons/ic_credit_card.png', 'Online').onTap(() {
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
          DateTime now = DateTime.now();
          if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
            currentBackPressTime = now;
            toast('Tap back again to leave Screen');
            return false;
          }
          return true;
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
                      onDraft: () {
                        finish(context);
                        createOrderApiCall(ORDER_DRAFT);
                      },
                      onCreate: () {
                        finish(context);
                        createOrderApiCall(ORDER_CREATED);
                      },
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
