import 'dart:convert';
import 'dart:core';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/extensions/extension_util/bool_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/list_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/num_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../extensions/app_text_field.dart';
import '../../extensions/common.dart';
import '../../extensions/confirmation_dialog.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../extensions/widgets.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/components/OrderSummeryWidget.dart';
import '../../main/components/PickAddressBottomSheet.dart';
import '../../main/models/AddressListModel.dart';
import '../../main/models/AutoCompletePlacesListModel.dart';
import '../../main/models/CityListModel.dart';
import '../../main/models/CountryListModel.dart';
import '../../main/models/ExtraChargeRequestModel.dart';
import '../../main/models/OrderItemModel.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/models/ParcelTypeListModel.dart';
import '../../main/models/PaymentModel.dart';
import '../../main/models/PlaceIdDetailModel.dart';
import '../../main/models/ProductListModel.dart';
import '../../main/models/VehicleModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/screens/UserCitySelectScreen.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Images.dart';
import '../../main/utils/Widgets.dart';
import '../../user/components/CreateOrderConfirmationDialog.dart';
import '../../user/screens/DashboardScreen.dart';
import '../components/ProductItemComponent.dart';
import 'PaymentScreen.dart';
import 'WalletScreen.dart';

class CreateOrderScreen extends StatefulWidget {
  final OrderData? orderData;
  final List<ProductData>? orderItems;
  final int? storeId;

  CreateOrderScreen({this.orderData, this.orderItems, this.storeId});

  @override
  CreateOrderScreenState createState() => CreateOrderScreenState();
}

class CreateOrderScreenState extends State<CreateOrderScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CityModel? cityData;
  List<ParcelTypeData> parcelTypeList = [];

  TextEditingController parcelTypeCont = TextEditingController();
  TextEditingController weightController = TextEditingController(text: '1');
  TextEditingController totalParcelController = TextEditingController(text: '1');

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

  FocusNode pickPhoneFocus = FocusNode();
  FocusNode pickDesFocus = FocusNode();
  FocusNode deliverPhoneFocus = FocusNode();
  FocusNode deliverDesFocus = FocusNode();

  String deliverCountryCode = defaultPhoneCode;
  String pickupCountryCode = defaultPhoneCode;

  DateTime? pickFromDateTime, pickToDateTime, deliverFromDateTime, deliverToDateTime;
  DateTime? pickDate, deliverDate;
  TimeOfDay? pickFromTime, pickToTime, deliverFromTime, deliverToTime;

  String? pickLat, pickLong, deliverLat, deliverLong;

  int selectedTabIndex = 0;

  bool isDeliverNow = true;
  int isSelected = 1;

  bool? isCash = false;

  String paymentCollectFrom = PAYMENT_ON_PICKUP;

  DateTime? currentBackPressTime;
  bool isPickSavedAddress = false;
  bool isDeliverySavedAddress = false;
  num totalDistance = 0;
  num totalAmount = 0;
  List<AddressData> addressList = [];
  AddressData? pickAddressData;
  AddressData? deliveryAddressData;
  num weightCharge = 0;
  num distanceCharge = 0;
  num totalExtraCharge = 0;

  List<PaymentModel> mPaymentList = getPaymentItems();

  List<ExtraChargeRequestModel> extraChargeList = [];

  num productAmount = 0;
  List<OrderItemModel> orderItemsList = [];

  int? selectedVehicle;
  List<VehicleData> vehicleList = [];
  VehicleData? vehicleData;
  List<Marker> markers = [];
  GoogleMapController? googleMapController;
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints();
    afterBuildCreated(() {
      init();
    });
  }

  Future<void> init() async {
    pickupCountryCode = CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).code.isEmptyOrNull
        ? defaultPhoneCode
        : CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).code.validate();
    deliverCountryCode = CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).code.isEmptyOrNull
        ? defaultPhoneCode
        : CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).code.validate();
    await getCityDetailApiCall(getIntAsync(CITY_ID));
    getParcelTypeListApiCall();
    getAddressListApi();
    extraChargesList();
    getVehicleList(cityID: cityData!.id);
    if (widget.orderItems.validate().isNotEmpty) {
      getStoreDetail(widget.storeId.validate()).then((value) {
        pickAddressCont.text = value.address.validate();
        pickLat = value.latitude.validate();
        pickLong = value.longitude.validate();
        pickPhoneCont.text = value.contactNumber.validate();
        setState(() {});
      }).catchError((error) {
        print(error);
      });
      widget.orderItems.validate().forEach((element) {
        orderItemsList
            .add(OrderItemModel(orderId: "", productId: element.id, quantity: element.count, amount: element.price));
        productAmount = productAmount + ((element.count) * (element.price ?? 0));
        setState(() {});
      });
    }
    await getAppSetting().then((value) {
      appStore.setCurrencyCode(value.currencyCode ?? CURRENCY_CODE);
      appStore.setCurrencySymbol(value.currency ?? CURRENCY_SYMBOL);
      appStore.setCurrencyPosition(value.currencyPosition ?? CURRENCY_POSITION_LEFT);
      appStore.isVehicleOrder = value.isVehicleInOrder ?? 0;
      setState(() {});
    }).catchError((error) {
      log(error.toString());
    });

    if (widget.orderData != null) {
      if (widget.orderData!.totalWeight != 0) weightController.text = widget.orderData!.totalWeight!.toString();
      if (widget.orderData!.totalParcel != null) totalParcelController.text = widget.orderData!.totalParcel!.toString();
      parcelTypeCont.text = widget.orderData!.parcelType.validate();

      pickAddressCont.text = widget.orderData!.pickupPoint!.address.validate();
      pickLat = widget.orderData!.pickupPoint!.latitude.validate();
      pickLong = widget.orderData!.pickupPoint!.longitude.validate();
      if (widget.orderData!.pickupPoint!.contactNumber.validate().split(" ").length == 1) {
        pickPhoneCont.text = widget.orderData!.pickupPoint!.contactNumber.validate().split(" ").last;
      } else {
        pickupCountryCode = widget.orderData!.pickupPoint!.contactNumber.validate().split(" ").first;
        pickPhoneCont.text = widget.orderData!.pickupPoint!.contactNumber.validate().split(" ").last;
      }
      pickDesCont.text = widget.orderData!.pickupPoint!.description.validate();

      deliverAddressCont.text = widget.orderData!.deliveryPoint!.address.validate();
      deliverLat = widget.orderData!.deliveryPoint!.latitude.validate();
      deliverLong = widget.orderData!.deliveryPoint!.longitude.validate();
      if (widget.orderData!.deliveryPoint!.contactNumber.validate().split(" ").length == 1) {
        deliverPhoneCont.text = widget.orderData!.deliveryPoint!.contactNumber.validate().split(" ").last;
      } else {
        deliverCountryCode = widget.orderData!.deliveryPoint!.contactNumber.validate().split(" ").first;
        deliverPhoneCont.text = widget.orderData!.deliveryPoint!.contactNumber.validate().split(" ").last;
      }
      deliverDesCont.text = widget.orderData!.deliveryPoint!.description.validate();

      paymentCollectFrom = widget.orderData!.paymentCollectFrom.validate(value: PAYMENT_ON_PICKUP);
    }
  }

  extraChargesList() {
    extraChargeList.clear();
    extraChargeList.add(ExtraChargeRequestModel(key: FIXED_CHARGES, value: cityData!.fixedCharges, valueType: ""));
    extraChargeList.add(ExtraChargeRequestModel(key: MIN_DISTANCE, value: cityData!.minDistance, valueType: ""));
    extraChargeList.add(ExtraChargeRequestModel(key: MIN_WEIGHT, value: cityData!.minWeight, valueType: ""));
    extraChargeList
        .add(ExtraChargeRequestModel(key: PER_DISTANCE_CHARGE, value: cityData!.perDistanceCharges, valueType: ""));
    extraChargeList
        .add(ExtraChargeRequestModel(key: PER_WEIGHT_CHARGE, value: cityData!.perWeightCharges, valueType: ""));

    if (cityData!.extraCharges != null) {
      cityData!.extraCharges!.forEach((element) {
        extraChargeList.add(ExtraChargeRequestModel(
            key: element.title!.toLowerCase().replaceAll(' ', "_"),
            value: element.charges,
            valueType: element.chargesType));
      });
    }
  }

  getCityDetailApiCall(int cityId) async {
    await getCityDetail(cityId).then((value) async {
      await setValue(CITY_DATA, value.data!.toJson());
      cityData = value.data!;
      getVehicleApiCall();
      setState(() {});
    }).catchError((error) {
      if (error.toString() == CITY_NOT_FOUND_EXCEPTION) {
        UserCitySelectScreen().launch(getContext, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
      }
    });
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

  getVehicleApiCall({String? name}) async {
    appStore.setLoading(true);
    await getVehicleList(cityID: cityData!.id).then((value) {
      appStore.setLoading(false);
      vehicleList.clear();
      vehicleList = value.data!;
      if (value.data!.isNotEmpty) selectedVehicle = value.data![0].id;
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error);
    });
  }

  getTotalAmount() async {
    String? originLat = isPickSavedAddress ? pickAddressData!.latitude.validate() : pickLat;
    String? originLong = isPickSavedAddress ? pickAddressData!.longitude.validate() : pickLong;
    String? destinationLat = isDeliverySavedAddress ? deliveryAddressData!.latitude.validate() : deliverLat;
    String? destinationLong = isDeliverySavedAddress ? deliveryAddressData!.longitude.validate() : deliverLong;
    String origins = "${originLat},${originLong}";
    String destinations = "${destinationLat},${destinationLong}";
    await getDistanceBetweenLatLng(origins, destinations).then((value) {
      double distanceInKms = value.rows[0].elements[0].distance.text.toString().split(' ')[0].toDouble();
      if (appStore.distanceUnit == DISTANCE_UNIT_MILE) {
        totalDistance = (MILES_PER_KM * distanceInKms);
      } else {
        totalDistance = distanceInKms;
      }
      totalAmount = 0;
      weightCharge = 0;
      distanceCharge = 0;
      totalExtraCharge = 0;

      /// calculate weight Charge
      if (weightController.text.toDouble() > cityData!.minWeight!) {
        weightCharge = ((weightController.text.toDouble() - cityData!.minWeight!) * cityData!.perWeightCharges!)
            .toStringAsFixed(digitAfterDecimal)
            .toDouble();
      }

      /// calculate distance Charge
      if (totalDistance > cityData!.minDistance!) {
        distanceCharge = ((totalDistance - cityData!.minDistance!) * cityData!.perDistanceCharges!)
            .toStringAsFixed(digitAfterDecimal)
            .toDouble();
      }

      /// total amount
      totalAmount = cityData!.fixedCharges! + weightCharge + distanceCharge;

      /// calculate extra charges
      if (cityData!.extraCharges != null) {
        cityData!.extraCharges!.forEach((element) {
          totalExtraCharge +=
              countExtraCharge(totalAmount: totalAmount, charges: element.charges!, chargesType: element.chargesType!);
        });
      }

      /// vehicle charge
      if (selectedVehicle != null && appStore.isVehicleOrder != 0) {
        VehicleData vehicle = vehicleList.firstWhere((element) => element.id == selectedVehicle);
        totalAmount += vehicle.price.validate();
      }

      /// All Charges
      totalAmount = (totalAmount + totalExtraCharge + productAmount).toStringAsFixed(digitAfterDecimal).toDouble();
    });
  }

  createOrderApiCall(String orderStatus) async {
    appStore.setLoading(true);
    Map req = {
      "id": widget.orderData != null ? widget.orderData!.id : "",
      "client_id": getIntAsync(USER_ID).toString(),
      "date": DateTime.now().toString(),
      "country_id": getIntAsync(COUNTRY_ID).toString(),
      "city_id": getIntAsync(CITY_ID).toString(),
      //   if (appStore.isVehicleOrder != 0) "vehicle_id": selectedVehicle.toString(),
      if (!selectedVehicle.toString().isEmptyOrNull && selectedVehicle != 0 && appStore.isVehicleOrder != 0)
        "vehicle_id": selectedVehicle.toString(),
      "pickup_point": {
        "start_time":
            (!isDeliverNow && pickFromDateTime != null) ? pickFromDateTime.toString() : DateTime.now().toString(),
        "end_time": (!isDeliverNow && pickToDateTime != null) ? pickToDateTime!.toUtc().toString() : null,
        "address": isPickSavedAddress ? pickAddressData!.address.validate() : pickAddressCont.text,
        "latitude": isPickSavedAddress ? pickAddressData!.latitude.validate() : pickLat,
        "longitude": isPickSavedAddress ? pickAddressData!.longitude.validate() : pickLong,
        "description": pickDesCont.text,
        "contact_number": isPickSavedAddress
            ? pickAddressData!.contactNumber.validate()
            : '$pickupCountryCode${pickPhoneCont.text.trim()}',
      },
      "delivery_point": {
        "start_time": (!isDeliverNow && deliverFromDateTime != null) ? deliverFromDateTime.toString() : null,
        "end_time": (!isDeliverNow && deliverToDateTime != null) ? deliverToDateTime.toString() : null,
        "address": isDeliverySavedAddress ? deliveryAddressData!.address.validate() : deliverAddressCont.text,
        "latitude": isDeliverySavedAddress ? deliveryAddressData!.latitude.validate() : deliverLat,
        "longitude": isDeliverySavedAddress ? deliveryAddressData!.longitude.validate() : deliverLong,
        "description": deliverDesCont.text,
        "contact_number": isDeliverySavedAddress
            ? deliveryAddressData!.contactNumber.validate()
            : '$deliverCountryCode${deliverPhoneCont.text.trim()}',
      },
      "extra_charges": extraChargeList,
      "parcel_type": parcelTypeCont.text,
      "total_weight": weightController.text.toDouble(),
      "total_distance": totalDistance.toStringAsFixed(digitAfterDecimal).validate(),
      "payment_collect_from": widget.orderItems.validate().isEmpty ? paymentCollectFrom : PAYMENT_ON_DELIVERY,
      "status": orderStatus,
      "payment_type": "",
      "payment_status": "",
      "fixed_charges": cityData!.fixedCharges.toString(),
      "parent_order_id": "",
      "total_amount": totalAmount,
      "weight_charge": weightCharge,
      "distance_charge": distanceCharge,
      "total_parcel": totalParcelController.text.toInt(),
      "store_detail_id": widget.orderItems.validate().isEmpty ? null : widget.storeId,
      "order_item": widget.orderItems.validate().isEmpty ? null : orderItemsList,
    };

    log("req----" + req.toString());
    // log("req----" + jsonDecode(req.toString()));
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(req.toString()).forEach((match) => print(match.group(0)));
    orderItemsList.forEach((element) {
      print("==>${element.toJson().toString()}");
    });
    await createOrder(req).then((value) async {
      appStore.setLoading(false);
      toast(value.message);
      finish(context);
      if (isSelected == 2) {
        PaymentScreen(orderId: value.orderId.validate(), totalAmount: totalAmount).launch(context);
      } else if (isSelected == 3) {
        log("-----" + appStore.availableBal.toString());
        if (appStore.availableBal > totalAmount) {
          savePaymentApiCall(
              paymentType: PAYMENT_TYPE_WALLET,
              paymentStatus: PAYMENT_PAID,
              totalAmount: totalAmount.toString(),
              orderID: value.orderId.toString());
        } else {
          toast(language.balanceInsufficient);
          bool? res = await WalletScreen().launch(context);
          if (res == true) {
            if (appStore.availableBal > totalAmount) {
              savePaymentApiCall(
                  paymentType: PAYMENT_TYPE_WALLET,
                  paymentStatus: PAYMENT_PAID,
                  totalAmount: totalAmount.toString(),
                  orderID: value.orderId.toString());
            } else {
              cashConfirmDialog();
            }
          } else {
            cashConfirmDialog();
          }
        }
      } else {
        DashboardScreen().launch(
          context,
          isNewTask: true,
        );
      }
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  /// Save Payment
  Future<void> savePaymentApiCall(
      {String? paymentType,
      String? totalAmount,
      String? orderID,
      String? txnId,
      String? paymentStatus = PAYMENT_PENDING,
      Map? transactionDetail}) async {
    Map req = {
      "id": "",
      "order_id": orderID,
      "client_id": getIntAsync(USER_ID).toString(),
      "datetime": DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
      "total_amount": totalAmount,
      "payment_type": paymentType,
      "txn_id": txnId,
      "payment_status": paymentStatus,
      "transaction_detail": transactionDetail ?? {}
    };

    appStore.setLoading(true);

    savePayment(req).then((value) {
      appStore.setLoading(false);
      toast(value.message.toString());
      DashboardScreen().launch(context, isNewTask: true);
    }).catchError((error) {
      appStore.setLoading(false);
      print(error.toString());
    });
  }

  Future<List<Predictions>> getPlaceAutoCompleteApiCall(String text) async {
    List<Predictions> list = [];
    await placeAutoCompleteApi(
            searchText: text,
            language: appStore.selectedLanguage,
            countryCode: CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).code.validate(value: 'IN'))
        .then((value) {
      list = value.predictions ?? [];
    }).catchError((e) {
      throw e.toString();
    });
    return list;
  }

  Future<PlaceIdDetailModel?> getPlaceIdDetailApiCall({required String placeId}) async {
    PlaceIdDetailModel? detailModel;
    await getPlaceDetail(placeId: placeId).then((value) {
      detailModel = value;
    }).catchError((e) {
      throw e.toString();
    });
    return detailModel;
  }

  Future<void> getAddressListApi() async {
    /* addressList = (getStringListAsync(RECENT_ADDRESS_LIST) ?? [])
        .map((e) => AddressData.fromJson(jsonDecode(e)))
        .toList();
    if (addressList.isNotEmpty) {
      pickAddressData = addressList.first;
      deliveryAddressData = addressList.first;
    }
    setState(() {});*/
    appStore.setLoading(true);
    await getAddressList().then((value) {
      appStore.setLoading(false);
      addressList.addAll(value.data.validate());
      if (addressList.isNotEmpty) {
        pickAddressData = addressList.first;
        deliveryAddressData = addressList.first;
      }
      List<AddressData> list = [];
      addressList.forEach((e) {
        list.add(e);
      });
      setValue(RECENT_ADDRESS_LIST, list.map((element) => jsonEncode(element)).toList());
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void setMapFitToCenter(Set<Polyline> p) {
    double minLat = p.first.points.first.latitude;
    double minLong = p.first.points.first.longitude;
    double maxLat = p.first.points.first.latitude;
    double maxLong = p.first.points.first.longitude;

    p.forEach((poly) {
      poly.points.forEach((point) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLong) minLong = point.longitude;
        if (point.longitude > maxLong) maxLong = point.longitude;
      });
    });
    googleMapController?.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: LatLng(minLat, minLong), northeast: LatLng(maxLat, maxLong)), 20));
  }

  setPolylines() async {
    print("setPolyline");
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleMapAPIKey,
        request: PolylineRequest(
            origin: PointLatLng(isPickSavedAddress ? pickAddressData!.latitude.toDouble() : pickLat.toDouble(),
                isPickSavedAddress ? pickAddressData!.longitude.toDouble() : pickLong.toDouble()),
            destination: PointLatLng(
                isDeliverySavedAddress ? deliveryAddressData!.latitude.toDouble() : deliverLat.toDouble(),
                isDeliverySavedAddress ? deliveryAddressData!.longitude.toDouble() : deliverLong.toDouble()),
            mode: TravelMode.driving));
    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print("--address not found ---");
    }
    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId("poly"),
          color: Color.fromARGB(255, 40, 122, 198),
          width: 5,
          points: polylineCoordinates);
      _polylines.add(polyline);
    });
  }

  Widget createOrderWidget1() {
    return Observer(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              scheduleOptionWidget(context, isDeliverNow, ic_clock, language.deliveryNow).onTap(() {
                isDeliverNow = true;
                setState(() {});
              }).expand(),
              16.width,
              scheduleOptionWidget(context, !isDeliverNow, ic_schedule, language.schedule).onTap(() {
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
                    borderRadius: BorderRadius.circular(defaultRadius)),
                child: Column(
                  children: [
                    DateTimePicker(
                      controller: pickDateController,
                      type: DateTimePickerType.date,
                      initialDate: DateTime.now().add(Duration(days: 1)),
                      firstDate: DateTime.now().add(Duration(days: 1)),
                      lastDate: DateTime(2050),
                      onChanged: (value) {
                        pickDate = DateTime.parse(value);
                        deliverDate = null;
                        deliverDateController.clear();
                        setState(() {});
                      },
                      validator: (value) {
                        if (value!.isEmpty) return language.fieldRequiredMsg;
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
                            if (value.validate().isEmpty) return language.fieldRequiredMsg;
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
                            if (value.validate().isEmpty) return language.fieldRequiredMsg;
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
                        if (value!.isEmpty) return language.fieldRequiredMsg;
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
                            if (value.validate().isEmpty) return language.fieldRequiredMsg;
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
                            if (value!.isEmpty) return language.fieldRequiredMsg;
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
          // Text(language.weight, style: boldTextStyle()),
          // 8.height,

          Row(
            children: [
              Text(language.weight, style: primaryTextStyle()).expand(),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
                    borderRadius: BorderRadius.circular(defaultRadius)),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.remove, color: appStore.isDarkMode ? Colors.white : Colors.grey)
                          .paddingAll(12)
                          .onTap(() {
                        if (weightController.text.toDouble() > 1) {
                          weightController.text = (weightController.text.toDouble() - 1).toString();
                        }
                      }),
                      VerticalDivider(thickness: 1, color: context.dividerColor),
                      Container(
                        width: 50,
                        child: AppTextField(
                          controller: weightController,
                          textAlign: TextAlign.center,
                          maxLength: 5,
                          textFieldType: TextFieldType.PHONE,
                          decoration: InputDecoration(
                            counterText: '',
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      VerticalDivider(thickness: 1, color: context.dividerColor),
                      Icon(Icons.add, color: appStore.isDarkMode ? Colors.white : Colors.grey).paddingAll(12).onTap(() {
                        weightController.text = (weightController.text.toDouble() + 1).toString();
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
          16.height,
          // Text(language.numberOfParcels, style: boldTextStyle()),
          // 8.height,
          Row(
            children: [
              Text(language.numberOfParcels, style: primaryTextStyle()).expand(),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
                    borderRadius: BorderRadius.circular(defaultRadius)),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.remove, color: appStore.isDarkMode ? Colors.white : Colors.grey)
                          .paddingAll(12)
                          .onTap(() {
                        if (totalParcelController.text.toInt() > 1) {
                          totalParcelController.text = (totalParcelController.text.toInt() - 1).toString();
                        }
                      }),
                      VerticalDivider(thickness: 1, color: context.dividerColor),
                      Container(
                        width: 50,
                        child: AppTextField(
                          controller: totalParcelController,
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
                      VerticalDivider(thickness: 1, color: context.dividerColor),
                      Icon(Icons.add, color: appStore.isDarkMode ? Colors.white : Colors.grey).paddingAll(12).onTap(() {
                        totalParcelController.text = (totalParcelController.text.toInt() + 1).toString();
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Visibility(
            visible: appStore.isVehicleOrder != 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                Text(language.selectVehicle, style: primaryTextStyle()),
                8.height,
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: selectedVehicle,
                  decoration: commonInputDecoration(),
                  dropdownColor: Theme.of(context).cardColor,
                  style: primaryTextStyle(),
                  items: vehicleList.map<DropdownMenuItem<int>>((item) {
                    return DropdownMenuItem(
                      value: item.id,
                      child: Row(
                        children: [
                          commonCachedNetworkImage(item.vehicleImage.validate(), height: 40, width: 40),
                          SizedBox(width: 16),
                          Text("${item.title.validate()}  (${printAmount(item.price.validate())})",
                              style: primaryTextStyle()),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedVehicle = value;
                    setState(() {});
                  },
                  validator: (value) {
                    if (selectedVehicle == null) return language.fieldRequiredMsg;
                    return null;
                  },
                ),
              ],
            ),
          ),
          16.height,
          Text(language.parcelType, style: primaryTextStyle()),
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
          8.height,
          Wrap(
            spacing: 8,
            runSpacing: 0,
            children: parcelTypeList.map((item) {
              return Chip(
                backgroundColor: context.scaffoldBackgroundColor,
                label: Text(item.label!, style: secondaryTextStyle()),
                elevation: 0,
                labelStyle: primaryTextStyle(color: Colors.grey),
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
        if (widget.orderItems.validate().isEmpty && addressList.isNotEmpty)
          CheckboxListTile(
            contentPadding: EdgeInsets.only(bottom: 8),
            value: isPickSavedAddress,
            checkColor: Colors.white,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(language.selectAddressSave, style: primaryTextStyle()),
            dense: true,
            activeColor: colorPrimary,
            onChanged: (value) {
              isPickSavedAddress = value.validate();
              setState(() {});
            },
          ),
        isPickSavedAddress
            ? Container(
                decoration: boxDecorationWithRoundedCorners(
                    borderRadius: BorderRadius.circular(defaultRadius), backgroundColor: Colors.grey.withOpacity(0.15)),
                //   height: 90,
                padding: EdgeInsets.all(12),
                child: DropdownButton<AddressData>(
                  value: pickAddressData,
                  hint: Text(language.selectAddress, style: primaryTextStyle()),
                  dropdownColor: context.cardColor,
                  isExpanded: true,
                  itemHeight: 80,
                  underline: Container(color: Colors.red),
                  menuMaxHeight: context.height() * 0.6,
                  items: addressList.map((AddressData e) {
                    return DropdownMenuItem<AddressData>(
                      value: e,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.address.validate(), style: primaryTextStyle(), maxLines: 2),
                          8.height,
                          Text(e.contactNumber.validate(), style: secondaryTextStyle(), maxLines: 1),
                        ],
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (context) {
                    return addressList.map((e) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.address.validate(), style: primaryTextStyle(), maxLines: 2),
                          8.height,
                          Text(e.contactNumber.validate(), style: secondaryTextStyle(), maxLines: 1),
                        ],
                      );
                    }).toList();
                  },
                  onChanged: (AddressData? value) {
                    pickAddressData = value;
                    setState(() {});
                  },
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.location, style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: pickAddressCont,
                    readOnly: true,
                    enabled: widget.orderItems.validate().isEmpty,
                    textInputAction: TextInputAction.next,
                    nextFocus: pickPhoneFocus,
                    textFieldType: TextFieldType.MULTILINE,
                    decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
                    validator: (value) {
                      if (value!.isEmpty) return language.fieldRequiredMsg;
                      if (pickLat == null || pickLong == null) return language.pleaseSelectValidAddress;
                      return null;
                    },
                    onTap: () {
                      if (widget.orderItems.validate().isEmpty) {
                        showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(defaultRadius))),
                          context: context,
                          builder: (context) {
                            return PickAddressBottomSheet(
                              onPick: (address) {
                                pickAddressCont.text = address.address ?? "";
                                pickLat = address.latitude.toString();
                                pickLong = address.longitude.toString();
                                pickPhoneCont.text = address.contactNumber.validate().substring(4);
                                setState(() {});
                              },
                            );
                          },
                        ).then((value) {
                          addressList = (getStringListAsync(RECENT_ADDRESS_LIST) ?? [])
                              .map((e) => AddressData.fromJson(jsonDecode(e)))
                              .toList();
                          if (addressList.isNotEmpty) {
                            pickAddressData = addressList.first;
                            deliveryAddressData = addressList.first;
                          }
                          setState(() {});
                        });
                      }
                    },
                  ),
                  16.height,
                  Text(language.contactNumber, style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: pickPhoneCont,
                    focus: pickPhoneFocus,
                    nextFocus: pickDesFocus,
                    enabled: widget.orderItems.validate().isEmpty,
                    textFieldType: TextFieldType.PHONE,
                    decoration: commonInputDecoration(
                      suffixIcon: Icons.phone,
                      prefixIcon: widget.orderItems.validate().isEmpty
                          ? IntrinsicHeight(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CountryCodePicker(
                                    initialSelection: pickupCountryCode,
                                    showCountryOnly: false,
                                    dialogSize: Size(context.width() - 60, context.height() * 0.6),
                                    showFlag: true,
                                    showFlagDialog: true,
                                    showOnlyCountryWhenClosed: false,
                                    alignLeft: false,
                                    textStyle: primaryTextStyle(),
                                    dialogBackgroundColor: Theme.of(context).cardColor,
                                    barrierColor: Colors.black12,
                                    dialogTextStyle: primaryTextStyle(),
                                    searchDecoration: InputDecoration(
                                      iconColor: Theme.of(context).dividerColor,
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                                    ),
                                    searchStyle: primaryTextStyle(),
                                    onInit: (c) {
                                      pickupCountryCode = c!.dialCode!;
                                    },
                                    onChanged: (c) {
                                      pickupCountryCode = c.dialCode!;
                                    },
                                  ),
                                  VerticalDivider(color: Colors.grey.withOpacity(0.5)),
                                ],
                              ),
                            )
                          : null,
                    ),
                    textInputAction: TextInputAction.go,
                    validator: (value) {
                      if (value!.trim().isEmpty) return language.fieldRequiredMsg;
                      //  if (value.trim().length < minContactLength || value.trim().length > maxContactLength) return language.contactLength;
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ],
              ),
        16.height,
        Text(language.description, style: primaryTextStyle()),
        8.height,
        TextField(
          controller: pickDesCont,
          focusNode: pickDesFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
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
        if (addressList.isNotEmpty)
          CheckboxListTile(
            contentPadding: EdgeInsets.only(bottom: 8),
            value: isDeliverySavedAddress,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(language.selectAddressSave, style: primaryTextStyle()),
            dense: true,
            checkColor: Colors.white,
            activeColor: colorPrimary,
            onChanged: (value) {
              isDeliverySavedAddress = value.validate();
              setState(() {});
            },
          ),
        isDeliverySavedAddress
            ? Container(
                decoration: boxDecorationWithRoundedCorners(
                    borderRadius: BorderRadius.circular(defaultRadius), backgroundColor: Colors.grey.withOpacity(0.15)),
                // height: 90,
                padding: EdgeInsets.all(12),
                child: DropdownButton<AddressData>(
                  value: deliveryAddressData,
                  hint: Text(language.selectAddress, style: primaryTextStyle()),
                  dropdownColor: context.cardColor,
                  isExpanded: true,
                  itemHeight: 80,
                  underline: Container(color: Colors.red),
                  menuMaxHeight: context.height() * 0.6,
                  items: addressList.map((AddressData e) {
                    return DropdownMenuItem<AddressData>(
                      value: e,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.address.validate(), style: primaryTextStyle(), maxLines: 2),
                          8.height,
                          Text(e.contactNumber.validate(), style: secondaryTextStyle(), maxLines: 1),
                        ],
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (context) {
                    return addressList.map((e) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.address.validate(), style: primaryTextStyle(), maxLines: 2),
                          8.height,
                          Text(e.contactNumber.validate(), style: secondaryTextStyle(), maxLines: 1),
                        ],
                      );
                    }).toList();
                  },
                  onChanged: (AddressData? value) {
                    deliveryAddressData = value;
                    setState(() {});
                  },
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.deliveryLocation, style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: deliverAddressCont,
                    readOnly: true,
                    textInputAction: TextInputAction.next,
                    nextFocus: deliverPhoneFocus,
                    textFieldType: TextFieldType.MULTILINE,
                    decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
                    validator: (value) {
                      if (value!.isEmpty) return language.fieldRequiredMsg;
                      if (deliverLat == null || deliverLong == null) return language.pleaseSelectValidAddress;
                      return null;
                    },
                    onTap: () {
                      showModalBottomSheet(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(defaultRadius))),
                        context: context,
                        builder: (context) {
                          return PickAddressBottomSheet(
                            onPick: (address) {
                              deliverAddressCont.text = address.address ?? "";
                              deliverLat = address.latitude.toString();
                              deliverLong = address.longitude.toString();
                              deliverPhoneCont.text = address.contactNumber.validate().substring(4);
                              setState(() {});
                            },
                            isPickup: false,
                          );
                        },
                      ).then((value) {
                        addressList = (getStringListAsync(RECENT_ADDRESS_LIST) ?? [])
                            .map((e) => AddressData.fromJson(jsonDecode(e)))
                            .toList();
                        if (addressList.isNotEmpty) {
                          pickAddressData = addressList.first;
                          deliveryAddressData = addressList.first;
                        }
                        setState(() {});
                      });
                    },
                  ),
                  16.height,
                  Text(language.deliveryContactNumber, style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: deliverPhoneCont,
                    textInputAction: TextInputAction.go,
                    focus: deliverPhoneFocus,
                    nextFocus: deliverDesFocus,
                    textFieldType: TextFieldType.PHONE,
                    decoration: commonInputDecoration(
                      suffixIcon: Icons.phone,
                      prefixIcon: IntrinsicHeight(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CountryCodePicker(
                              initialSelection: deliverCountryCode,
                              showCountryOnly: false,
                              dialogSize: Size(context.width() - 60, context.height() * 0.6),
                              showFlag: true,
                              showFlagDialog: true,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                              textStyle: primaryTextStyle(),
                              dialogBackgroundColor: Theme.of(context).cardColor,
                              barrierColor: Colors.black12,
                              dialogTextStyle: primaryTextStyle(),
                              searchDecoration: InputDecoration(
                                iconColor: Theme.of(context).dividerColor,
                                enabledBorder:
                                    UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                              ),
                              searchStyle: primaryTextStyle(),
                              onInit: (c) {
                                deliverCountryCode = c!.dialCode!;
                              },
                              onChanged: (c) {
                                deliverCountryCode = c.dialCode!;
                              },
                            ),
                            VerticalDivider(color: Colors.grey.withOpacity(0.5)),
                          ],
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.trim().isEmpty) return language.fieldRequiredMsg;
                      // if (value.trim().length < minContactLength || value.trim().length > maxContactLength) return language.contactLength;
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ],
              ),
        16.height,
        Text(language.deliveryDescription, style: primaryTextStyle()),
        8.height,
        TextField(
          controller: deliverDesCont,
          focusNode: deliverDesFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
          maxLines: 3,
          minLines: 3,
        ),
      ],
    );
  }

  void onMapCreated(GoogleMapController controller) async {
    setState(() {
      googleMapController = controller;
      setPolylines().then((_) => setMapFitToCenter(_polylines));
    });
  }

  Widget createOrderWidget4() {
    return Column(
      children: [
        markers.isNotEmpty
            ? Container(
                width: context.width(),
                height: context.height() * 0.67,
                child: Stack(
                  children: [
                    GoogleMap(
                      markers: markers.map((e) => e).toSet(),
                      polylines: _polylines,
                      mapType: MapType.normal,
                      cameraTargetBounds: CameraTargetBounds.unbounded,
                      initialCameraPosition: CameraPosition(
                          // bearing: 192.8334901395799,
                          target: LatLng(isPickSavedAddress ? pickAddressData!.latitude.toDouble() : pickLat.toDouble(),
                              isPickSavedAddress ? pickAddressData!.longitude.toDouble() : pickLong.toDouble()),
                          zoom: 12),
                      onMapCreated: onMapCreated,
                      tiltGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      zoomGesturesEnabled: true,
                      // trafficEnabled: true,
                    )
                  ],
                ),
              )
            : loaderWidget(),
      ],
    );
  }

  Widget createOrderWidget5() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.packageInformation, style: boldTextStyle()),
          8.height,
          Container(
            padding: EdgeInsets.all(16),
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: BorderRadius.circular(defaultRadius),
              border: Border.all(color: colorPrimary.withOpacity(0.2)),
              backgroundColor: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                rowWidget(title: language.parcelType, value: parcelTypeCont.text),
                8.height,
                rowWidget(
                    title: language.weight,
                    value: '${weightController.text} ${CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).weightType}'),
                8.height,
                rowWidget(title: language.numberOfParcels, value: '${totalParcelController.text}'),
                Column(
                  children: [
                    16.height,
                    Text(language.orderItems, style: boldTextStyle()),
                    // Text(language.orderItems, style: boldTextStyle()),
                    8.height,
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: widget.orderItems.validate().length,
                      itemBuilder: (context, index) {
                        ProductData item = widget.orderItems.validate()[index];
                        return ProductItemComponent(product: item, isView: true);
                      },
                    ),
                  ],
                ).visible(widget.orderItems.validate().isNotEmpty),
              ],
            ),
          ),
          16.height,
          addressComponent(
              title: language.pickupLocation,
              address: isPickSavedAddress ? pickAddressData!.address.validate() : pickAddressCont.text,
              phoneNumber: isPickSavedAddress
                  ? pickAddressData!.contactNumber.validate()
                  : (widget.orderItems.validate().isNotEmpty
                      ? pickPhoneCont.text
                      : '$pickupCountryCode ${pickPhoneCont.text.trim()}')),
          16.height,
          addressComponent(
              title: language.deliveryLocation,
              address: isDeliverySavedAddress ? deliveryAddressData!.address.validate() : deliverAddressCont.text,
              phoneNumber: isDeliverySavedAddress
                  ? deliveryAddressData!.contactNumber.validate()
                  : '$deliverCountryCode ${deliverPhoneCont.text.trim()}'),
          16.height,
          OrderSummeryWidget(
              productAmount: productAmount,
              vehiclePrice: (selectedVehicle != null && appStore.isVehicleOrder != 0)
                  ? vehicleList.firstWhere((element) => element.id == selectedVehicle).price
                  : 0,
              extraChargesList: extraChargeList,
              totalDistance: totalDistance,
              totalWeight: weightController.text.toDouble(),
              distanceCharge: distanceCharge,
              weightCharge: weightCharge,
              totalAmount: totalAmount),
          16.height,
          Text(language.payment, style: boldTextStyle()),
          16.height,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mPaymentList.map((mData) {
              return Container(
                width: (context.width() - 48) / 3,
                padding: EdgeInsets.all(8),
                alignment: Alignment.center,
                decoration: boxDecorationWithRoundedCorners(
                    border: Border.all(color: isSelected == mData.index ? colorPrimary : borderColor),
                    backgroundColor: Colors.transparent),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ImageIcon(AssetImage(mData.image.validate()),
                        size: 20, color: isSelected == mData.index ? colorPrimary : dividerColor),
                    8.width,
                    Text(mData.title!,
                        style: primaryTextStyle(
                            color: isSelected == mData.index ? colorPrimary : textSecondaryColorGlobal)),
                  ],
                ),
              ).onTap(() {
                isSelected = mData.index!;
                setState(() {});
              });
            }).toList(),
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.paymentCollectFrom, style: boldTextStyle()),
              16.width,
              DropdownButtonFormField<String>(
                isExpanded: true,
                isDense: true,
                value: paymentCollectFrom,
                decoration: commonInputDecoration(),
                items: [
                  DropdownMenuItem(
                      value: PAYMENT_ON_PICKUP,
                      child: Text(language.pickupLocation, style: primaryTextStyle(), maxLines: 1)),
                  DropdownMenuItem(
                      value: PAYMENT_ON_DELIVERY,
                      child: Text(language.deliveryLocation, style: primaryTextStyle(), maxLines: 1)),
                ],
                onChanged: (value) {
                  paymentCollectFrom = value!;
                  setState(() {});
                },
              ).expand(),
            ],
          ).visible(isSelected == 1 && widget.orderItems.validate().isEmpty),
        ],
      ),
    );
  }

  Widget rowWidget({required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: secondaryTextStyle()),
        16.width,
        Text(value,
                style: boldTextStyle(size: 14), maxLines: 3, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis)
            .expand(),
      ],
    );
  }

  Widget addressComponent({required String title, required String address, required String phoneNumber}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: boldTextStyle()),
        8.height,
        Container(
          width: context.width(),
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: colorPrimary.withOpacity(0.2)),
            backgroundColor: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(address, style: primaryTextStyle()),
              8.height.visible(address.isNotEmpty),
              Row(
                children: [
                  Icon(Icons.call, size: 14),
                  8.width,
                  Text(phoneNumber, style: secondaryTextStyle()).visible(phoneNumber.isNotEmpty),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget progressIndicator() {
    return CircularPercentIndicator(
      radius: 20.0,
      lineWidth: 2.0,
      percent: ((selectedTabIndex + 1) / 5) > 1 ? 1 : (selectedTabIndex + 1) / 5,
      animation: true,
      center:
          Text((selectedTabIndex + 1).toInt().toString() + " /5", style: boldTextStyle(size: 11, color: Colors.white)),
      backgroundColor: Colors.white.withOpacity(0.25),
      progressColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedTabIndex == 0) {
          if ((widget.orderItems == null)) {
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
            return true;
          }
        } else {
          selectedTabIndex--;
          setState(() {});
          return false;
        }
      },
      child: CommonScaffoldComponent(
        // appBarTitle: language.createOrder,
        appBar: commonAppBarWidget(language.createOrder, actions: [
          Row(
            children: [
              progressIndicator(),
              10.width,
            ],
          )
        ]),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*   Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Container(
                          alignment: Alignment.center,
                          height: selectedTabIndex == index ? 35 : 25,
                          width: selectedTabIndex == index ? 35 : 25,
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                              color: selectedTabIndex >= index
                                  ? colorPrimary
                                  : (appStore.isDarkMode
                                      ? scaffoldSecondaryDark
                                      : borderColor),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: selectedTabIndex >= index
                                      ? colorPrimary
                                      : (appStore.isDarkMode
                                          ? colorPrimaryLight
                                          : colorPrimary))),
                          child: Text('${index + 1}',
                              style: primaryTextStyle(
                                  color: selectedTabIndex >= index ? Colors.white : null)),
                        );
                      }).toList(),
                    ),
                    30.height,*/
                    if (selectedTabIndex == 0) createOrderWidget1(),
                    if (selectedTabIndex == 1) createOrderWidget2(),
                    if (selectedTabIndex == 2) createOrderWidget3(),
                    if (selectedTabIndex == 3) createOrderWidget4(),
                    if (selectedTabIndex == 4) createOrderWidget5(),
                  ],
                ),
              ),
            ),
            Observer(
              builder: (context) => loaderWidget().visible(appStore.isLoading),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              if (selectedTabIndex != 0)
                outlineButton(language.previous, () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  selectedTabIndex--;
                  setState(() {});
                }, color: colorPrimary)
                    .paddingRight(isRTL ? 4 : 16)
                    .paddingLeft(isRTL ? 16 : 0)
                    .expand(),
              commonButton(selectedTabIndex != 4 ? language.next : language.createOrder, () async {
                FocusScope.of(context).requestFocus(new FocusNode());
                log('------selected tab index${selectedTabIndex}');
                if (selectedTabIndex == 2) {
                  markers.clear();
                  markers.add(
                    Marker(
                      markerId: MarkerId("1"),
                      position: isPickSavedAddress
                          ? LatLng(pickAddressData!.latitude.validate().toDouble(),
                              pickAddressData!.longitude.validate().toDouble())
                          : LatLng(pickLat.toDouble(), pickLong.toDouble()),
                      infoWindow: InfoWindow(title: language.sourceLocation),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    ),
                  );
                  markers.add(
                    Marker(
                      markerId: MarkerId("2"),
                      position: isDeliverySavedAddress
                          ? LatLng(deliveryAddressData!.latitude.validate().toDouble(),
                              deliveryAddressData!.longitude.validate().toDouble())
                          : LatLng(deliverLat.toDouble(), deliverLong.toDouble()),
                      infoWindow: InfoWindow(title: language.destinationLocation),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    ),
                  );
                  setState(() {});
                }
                if (selectedTabIndex != 4) {
                  if (_formKey.currentState!.validate()) {
                    Duration difference = Duration();
                    Duration differenceCurrentTime = Duration();
                    if (!isDeliverNow) {
                      pickFromDateTime =
                          pickDate!.add(Duration(hours: pickFromTime!.hour, minutes: pickFromTime!.minute));
                      pickToDateTime = pickDate!.add(Duration(hours: pickToTime!.hour, minutes: pickToTime!.minute));
                      deliverFromDateTime =
                          deliverDate!.add(Duration(hours: deliverFromTime!.hour, minutes: deliverFromTime!.minute));
                      deliverToDateTime =
                          deliverDate!.add(Duration(hours: deliverToTime!.hour, minutes: deliverToTime!.minute));
                      difference = pickFromDateTime!.difference(deliverFromDateTime!);
                      differenceCurrentTime = DateTime.now().difference(pickFromDateTime!);
                    }
                    if (differenceCurrentTime.inMinutes > 0) return toast(language.pickupCurrentValidationMsg);
                    if (difference.inMinutes > 0) return toast(language.pickupDeliverValidationMsg);
                    selectedTabIndex++;
                    if (selectedTabIndex == 4) {
                      await getTotalAmount();
                    }
                    setState(() {});
                  }
                } else {
                  showConfirmDialogCustom(
                    context,
                    title: language.createOrderConfirmationMsg,
                    note: language.pleaseAvoidSendingProhibitedItems,
                    positiveText: language.yes,
                    primaryColor: colorPrimary,
                    negativeText: language.no,
                    onAccept: (v) {
                      createOrderApiCall(ORDER_CREATED);
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
