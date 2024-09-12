import 'dart:async';
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mighty_delivery/extensions/colors.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/list_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/num_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main/models/CountryDetailModel.dart';

import '../../extensions/LiveStream.dart';
import '../../extensions/animatedList/animated_scroll_view.dart';
import '../../extensions/app_button.dart';
import '../../extensions/app_text_field.dart';
import '../../extensions/common.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../extensions/widgets.dart';
import '../../main.dart';
import '../../main/Chat/ChatScreen.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/components/OrderSummeryWidget.dart';
import '../../main/models/CountryListModel.dart';
import '../../main/models/ExtraChargeRequestModel.dart';
import '../../main/models/LoginResponse.dart';
import '../../main/models/OrderDetailModel.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/DataProviders.dart';
import '../../main/utils/Images.dart';
import '../../main/utils/Widgets.dart';
import '../../main/utils/dynamic_theme.dart';
import '../../user/components/CancelOrderDialog.dart';
import '../../user/screens/ReturnOrderScreen.dart';
import '../components/OrderCardComponent.dart';
import 'OrderHistoryScreen.dart';

class OrderDetailScreen extends StatefulWidget {
  static String tag = '/OrderDetailScreen';

  final int orderId;

  OrderDetailScreen({required this.orderId});

  @override
  OrderDetailScreenState createState() => OrderDetailScreenState();
}

class OrderDetailScreenState extends State<OrderDetailScreen> {
  UserData? userData;

  OrderData? orderData;
  OrderRating? rating;
  List<OrderHistory>? orderHistory;
  List<OrderItem>? orderItems;
  CourierCompanyDetail? courierDetails;
  Payment? payment;
  List<ExtraChargeRequestModel> list = [];
  double? totalDistance;
  String? distance, duration;
  num productAmount = 0;
  String? reason;
  String? otherReason;
  bool canCancel = false;
  List<String> reasonsList = getDeliveryBoyBeforePickupCancelReasonList();
  List<Map<String, String>> packagingSymbols = [];
  TextEditingController reasonController = TextEditingController();
  bool isOtherOptionSelected = false;
  int differenceInMinutes = 0;
  Duration remainingTime = Duration(); // Remaining time
  Timer? timer;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  Future<void> init() async {
    orderDetailApiCall();
  }

  orderDetailApiCall() async {
    appStore.setLoading(true);
    await getOrderDetails(widget.orderId).then((value) {
      orderData = value.data!;
      orderHistory = value.orderHistory!;
      if (value.courierCompanyDetail != null) {
        courierDetails = value.courierCompanyDetail!;
      }
      orderItems = value.orderItem.validate();
      if (orderItems.validate().isNotEmpty) {
        orderItems!.forEach((element) {
          productAmount += element.totalAmount.validate();
        });
      }
      payment = value.payment ?? Payment();

      rating = value.orderRating ?? null;
      if (orderData!.extraCharges.runtimeType == List<dynamic>) {
        (orderData!.extraCharges as List<dynamic>).forEach((element) {
          list.add(ExtraChargeRequestModel.fromJson(element));
        });
      }
      if (getStringAsync(USER_TYPE) == CLIENT) {
        userData = value.deliveryManDetail != null ? value.deliveryManDetail : UserData();
      } else {
        userData = value.clientDetail;
      }
      canUserCancelOrder();
      getDistanceApiCall();
      if (orderData!.status == ORDER_TRANSFER ||
          orderData!.status == ORDER_ASSIGNED ||
          orderData!.status == ORDER_ACCEPTED) {
        reasonsList = getDeliveryBoyBeforePickupCancelReasonList();
      } else if (orderData!.status == ORDER_PICKED_UP ||
          orderData!.status == ORDER_DEPARTED ||
          orderData!.status == ORDER_ARRIVED) {
        reasonsList = getDeliveryBoyAfterPickupCancelReasonList();
      }
      if (orderData!.packagingSymbols != null) {
        getPackagingSymbols().forEach((element1) {
          orderData!.packagingSymbols!.forEach((element2) {
            if (element1['key'] == element2.key) {
              packagingSymbols.add(element1);
            }
          });
        });
      }
    }).catchError((error) {
      toast(error.toString());
    }).whenComplete(() => appStore.setLoading(false));
  }

  cancelOrderByDeliveryManApiCall() async {
    appStore.setLoading(true);
    await updateOrder(
      orderId: widget.orderId,
      reason: reason == isOtherOptionSelected ? otherReason : reason,
      orderStatus: ORDER_CANCELLED,
    ).then((value) {
      appStore.setLoading(false);
      toast(language.orderCancelledSuccessfully);
      finish(context);
    }).catchError((error) {
      appStore.setLoading(false);

      log(error);
    });
  }

  canUserCancelOrder() {
    DateTime orderDate = DateTime.parse("${orderData!.date!}Z").toLocal();
    DateTime currentDate = DateTime.parse(DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())).toLocal();
    Duration difference = currentDate.difference(orderDate);
    int differenceInMinutes = currentDate.difference(orderDate).inMinutes;
    canCancel = differenceInMinutes < cancelOrderDuration;
    if (difference.inMinutes < 60 && difference.inMinutes > 0) {
      setState(() {
        remainingTime = Duration(hours: 1) - difference;
        startTimer();
      });
    } else {
      setState(() {
        remainingTime = Duration.zero;
      });
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        remainingTime = DateTime.parse("${orderData!.date!}Z")
            .toLocal()
            .add(Duration(hours: 1))
            .difference(DateTime.parse(DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())).toLocal());

        // Stop the timer if time is over
        if (remainingTime.isNegative || remainingTime.inSeconds <= 0) {
          remainingTime = Duration.zero;
          timer.cancel();
        }
      });
    });
  }

  String formatRemainingTime(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = seconds.toString().padLeft(2, '0');
    return '$formattedMinutes:$formattedSeconds';
  }

  getDistanceApiCall() async {
    String? originLat = orderData!.pickupPoint!.latitude.validate();
    String? originLong = orderData!.pickupPoint!.longitude.validate();
    String? destinationLat = orderData!.deliveryPoint!.latitude.validate();
    String? destinationLong = orderData!.deliveryPoint!.longitude.validate();
    String origins = "${originLat},${originLong}";
    String destinations = "${destinationLat},${destinationLong}";
    await getDistanceBetweenLatLng(origins, destinations).then((value) {
      duration = value.rows[0].elements[0].duration.text;
      double distanceInKms = value.rows[0].elements[0].distance.text.toString().split(' ')[0].toDouble();
      if (appStore.distanceUnit == DISTANCE_UNIT_MILE) {
        totalDistance = (MILES_PER_KM * distanceInKms);
        distance = totalDistance!.toStringAsFixed(2) + DISTANCE_UNIT_MILE;
      } else {
        totalDistance = distanceInKms;
        distance = totalDistance.toString() + DISTANCE_UNIT_KM;
      }
      setState(() {});
    });
  }

  createOrderApiCall() async {
    appStore.setLoading(true);
    Map req = {
      "client_id": orderData!.clientId!,
      "date": DateTime.now().toString(),
      "country_id": orderData!.countryId!,
      "city_id": orderData!.cityId!,
      "pickup_point": orderData!.deliveryPoint!,
      "delivery_point": orderData!.pickupPoint!,
      "extra_charges": orderData!.extraCharges!,
      "parcel_type": orderData!.parcelType!,
      "total_weight": orderData!.totalWeight!,
      "total_distance": orderData!.totalDistance!,
      "payment_collect_from": orderData!.paymentCollectFrom,
      "status": ORDER_CREATED,
      "payment_type": "",
      "payment_status": "",
      "fixed_charges": orderData!.fixedCharges!,
      "parent_order_id": orderData!.id!,
      "total_amount": orderData!.totalAmount ?? 0,
      "vehicle_id": orderData!.vehicleId.validate(),
      "reason": reason == isOtherOptionSelected ? otherReason : reason,
      if (orderItems.validate().isNotEmpty)
        "store_detail_id": orderItems!.first.productData!.first.storeDetailId.validate(),
      if (orderItems.validate().isNotEmpty) "order_item": orderItems,
      "order_id": orderData!.id,
      "cancelorderreturn": 1
    };

    await createOrder(req).then((value) async {
      print("------------------------${value}");
      appStore.setLoading(false);
      toast(value.message);
      finish(context);
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    afterBuildCreated(() {
      appStore.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: '${orderData != null ? orderStatus(orderData!.status.validate()) : ''}',
      body: Stack(
        children: [
          orderData != null
              ? Stack(
                  children: [
                    AnimatedScrollView(
                      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: boxDecorationWithRoundedCorners(
                                  borderRadius: BorderRadius.circular(defaultRadius),
                                  border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                                  backgroundColor: Colors.transparent),
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      orderData!.date != null
                                          ? Text(
                                                  '${DateFormat('dd MMM yyyy').format(DateTime.parse("${orderData!.date!}Z").toLocal())} ' +
                                                      ' ${language.at.toLowerCase()} ' +
                                                      ' ${DateFormat('hh:mm a').format(DateTime.parse("${orderData!.date!}Z").toLocal())}',
                                                  style: primaryTextStyle(size: 14))
                                              .expand()
                                          : SizedBox(),
                                    ],
                                  ),
                                  8.height,
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(orderData!.parcelType.validate(),
                                              style: boldTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          4.height,
                                          Row(
                                            children: [
                                              Text('# ${orderData!.id}', style: boldTextStyle(size: 14)).expand(),
                                              if (orderData!.status != ORDER_CANCELLED)
                                                Text(printAmount(orderData!.totalAmount ?? 0), style: boldTextStyle()),
                                            ],
                                          ),
                                          4.height,
                                          Text(
                                              '${appStore.orderTrackingIdPrefixId.toUpperCase()}${orderData!.orderTrackingId}',
                                              style: boldTextStyle(size: 12, color: ColorUtils.colorPrimary)),
                                          4.height,
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(language.distance,
                                                      style: secondaryTextStyle(size: 14),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1),
                                                  4.width,
                                                  Text(distance ?? "0",
                                                      style: boldTextStyle(),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(language.duration,
                                                      style: secondaryTextStyle(size: 14),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1),
                                                  4.width,
                                                  Text(duration ?? "0",
                                                      style: boldTextStyle(),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1),
                                                ],
                                              ),
                                            ],
                                          ).visible(orderData!.pickupPoint != null && orderData!.deliveryPoint != null),
                                        ],
                                      ).expand(),
                                    ],
                                  ),
                                  8.height,
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (orderData!.pickupDatetime != null)
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(language.picked, style: secondaryTextStyle(size: 12)),
                                                    4.height,
                                                    Text(
                                                        '${language.at} ${printDateWithoutAt("${orderData!.pickupDatetime!}Z")}',
                                                        style: secondaryTextStyle(size: 12)),
                                                  ],
                                                ),
                                              4.height,
                                              GestureDetector(
                                                onTap: () {
                                                  openMap(double.parse(orderData!.pickupPoint!.latitude.validate()),
                                                      double.parse(orderData!.pickupPoint!.longitude.validate()));
                                                },
                                                child: Row(
                                                  children: [
                                                    ImageIcon(AssetImage(ic_from),
                                                        size: 24, color: ColorUtils.colorPrimary),
                                                    12.width,
                                                    Text('${orderData!.pickupPoint!.address}',
                                                            style: secondaryTextStyle())
                                                        .expand(),
                                                  ],
                                                ),
                                              ),
                                              if (orderData!.pickupDatetime == null &&
                                                  orderData!.pickupPoint!.endTime != null &&
                                                  orderData!.pickupPoint!.startTime != null)
                                                Text('${language.note} ${language.courierWillPickupAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(orderData!.pickupPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.pickupPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.pickupPoint!.endTime!).toLocal())}',
                                                        style: secondaryTextStyle(size: 12, color: Colors.red))
                                                    .paddingOnly(top: 4),
                                            ],
                                          ).expand(),
                                          12.width,
                                          if (orderData!.pickupPoint!.contactNumber != null)
                                            Icon(Ionicons.ios_call_outline, size: 20, color: ColorUtils.colorPrimary)
                                                .onTap(() {
                                              commonLaunchUrl('tel:${orderData!.pickupPoint!.contactNumber}');
                                            }),
                                        ],
                                      ),
                                    ],
                                  ),
                                  16.height,
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  if (orderData!.deliveryDatetime != null)
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(language.delivered, style: secondaryTextStyle(size: 12)),
                                                        4.height,
                                                        Text(
                                                            '${language.at} ${printDateWithoutAt("${orderData!.deliveryDatetime!}Z")}',
                                                            style: secondaryTextStyle(size: 12)),
                                                      ],
                                                    ),
                                                  4.height,
                                                  InkWell(
                                                    onTap: () {
                                                      openMap(
                                                          double.parse(orderData!.deliveryPoint!.latitude.validate()),
                                                          double.parse(orderData!.deliveryPoint!.longitude.validate()));
                                                    },
                                                    child: Row(
                                                      children: [
                                                        ImageIcon(AssetImage(ic_to),
                                                            size: 24, color: ColorUtils.colorPrimary),
                                                        12.width,
                                                        Text('${orderData!.deliveryPoint!.address}',
                                                                style: secondaryTextStyle(), textAlign: TextAlign.start)
                                                            .expand(),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (orderData!.deliveryDatetime == null &&
                                                  orderData!.deliveryPoint!.endTime != null &&
                                                  orderData!.deliveryPoint!.startTime != null)
                                                Text('${language.note} ${language.courierWillDeliverAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(orderData!.deliveryPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPoint!.endTime!).toLocal())}',
                                                        style: secondaryTextStyle(color: Colors.red, size: 12))
                                                    .paddingOnly(top: 4)
                                            ],
                                          ).expand(),
                                          12.width,
                                          if (orderData!.deliveryPoint!.contactNumber != null)
                                            Icon(Ionicons.ios_call_outline, size: 20, color: ColorUtils.colorPrimary)
                                                .onTap(() {
                                              commonLaunchUrl('tel:${orderData!.deliveryPoint!.contactNumber}');
                                            }),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (orderData!.status != ORDER_CANCELLED ||
                                      (orderData!.status == ORDER_DEPARTED || orderData!.status == ORDER_ACCEPTED))
                                    16.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppButton(
                                        elevation: 0,
                                        height: 35,
                                        color: Colors.transparent,
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                        shapeBorder: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(defaultRadius),
                                          side: BorderSide(color: ColorUtils.colorPrimary),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(language.viewHistory,
                                                style: primaryTextStyle(color: ColorUtils.colorPrimary)),
                                            Icon(Icons.arrow_right, color: ColorUtils.colorPrimary),
                                          ],
                                        ),
                                        onTap: () {
                                          OrderHistoryScreen(orderHistory: orderHistory.validate()).launch(context);
                                        },
                                      ),
                                      if (orderData!.status == ORDER_DELIVERED && appStore.userType == CLIENT) ...[
                                        AppButton(
                                          elevation: 0,
                                          height: 35,
                                          color: Colors.transparent,
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                          shapeBorder: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(defaultRadius),
                                            side: BorderSide(color: ColorUtils.colorPrimary),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(language.invoice,
                                                  style: primaryTextStyle(color: ColorUtils.colorPrimary)),
                                              Icon(Icons.arrow_right, color: ColorUtils.colorPrimary),
                                            ],
                                          ),
                                          onTap: () {
                                            PDFViewer(
                                              invoice: "${orderData!.invoice.validate()}",
                                              filename: "${orderData!.id.validate()}",
                                            ).launch(context);
                                          },
                                        )
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            16.height,
                            Text(language.parcelDetails, style: boldTextStyle(size: 16)),
                            12.height,
                            Container(
                              decoration: boxDecorationWithRoundedCorners(
                                  borderRadius: BorderRadius.circular(defaultRadius),
                                  border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                                  backgroundColor: Colors.transparent),
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: boxDecorationWithRoundedCorners(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                                color: ColorUtils.borderColor, width: appStore.isDarkMode ? 0.2 : 1),
                                            backgroundColor: Colors.transparent),
                                        padding: EdgeInsets.all(8),
                                        child: Image.asset(parcelTypeIcon(orderData!.parcelType.validate()),
                                            height: 24, width: 24, color: Colors.grey),
                                      ),
                                      8.width,
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(orderData!.parcelType.validate(), style: boldTextStyle()),
                                          4.height,
                                          Text(
                                              '${orderData!.totalWeight} ${CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).weightType}',
                                              style: secondaryTextStyle()),
                                        ],
                                      ).expand(),
                                    ],
                                  ),
                                  8.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.numberOfParcels, style: secondaryTextStyle()),
                                      Text('${orderData!.totalParcel ?? 1}', style: boldTextStyle(size: 14)),
                                    ],
                                  ).visible(orderData!.totalParcel != null),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      8.height,
                                      Divider(
                                        height: 18,
                                        color: ColorUtils.dividerColor,
                                      ),
                                      Text(language.orderItems, style: boldTextStyle()),
                                      8.height,
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.zero,
                                        itemCount: orderItems.validate().length,
                                        itemBuilder: (context, index) {
                                          OrderItem item = orderItems.validate()[index];

                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      commonCachedNetworkImage(
                                                              item.productData.validate().first.productImage,
                                                              height: 70,
                                                              width: 70,
                                                              fit: BoxFit.cover)
                                                          .cornerRadiusWithClipRRect(16),
                                                      10.width,
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          2.height,
                                                          if (item.productData != null)
                                                            Text(item.productData!.first.title.validate(),
                                                                style: boldTextStyle(size: 14)),
                                                          8.height,
                                                          Row(
                                                            children: [
                                                              Text(printAmount(item.amount.validate()),
                                                                  style: boldTextStyle(
                                                                      size: 14, color: ColorUtils.colorPrimary)),
                                                              8.width,
                                                              Text('x ${item.quantity.validate()}'.toString(),
                                                                  style: secondaryTextStyle()),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ).expand(),
                                                  16.width,
                                                  Text(printAmount(item.totalAmount.validate()),
                                                      style: boldTextStyle(size: 14, color: ColorUtils.colorPrimary)),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return Divider();
                                        },
                                      ),
                                    ],
                                  ).visible(orderItems.validate().isNotEmpty),
                                  8.height,
                                ],
                              ),
                            ),
                            16.height,
                            Text(language.labels, style: boldTextStyle(size: 16)).visible(packagingSymbols.isNotEmpty),
                            12.height.visible(packagingSymbols.isNotEmpty),
                            Container(
                              width: context.width(),
                              decoration: boxDecorationWithRoundedCorners(
                                  borderRadius: BorderRadius.circular(defaultRadius),
                                  border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                                  backgroundColor: Colors.transparent),
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Wrap(
                                    spacing: 20,
                                    runSpacing: 10,
                                    children: packagingSymbols!.map((item) {
                                      return Container(
                                        width: 70,
                                        decoration: boxDecorationWithRoundedCorners(
                                            backgroundColor: Colors.transparent,
                                            border: Border.all(
                                              color: ColorUtils.colorPrimary.withOpacity(0.4),
                                            )),
                                        child: Stack(
                                          children: [
                                            Image.asset(
                                              item['image'].toString(),
                                              width: 24,
                                              height: 24,
                                              color: appStore.isDarkMode
                                                  ? Colors.white.withOpacity(0.7)
                                                  : ColorUtils.colorPrimary,
                                            ).center().paddingAll(10),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  )
                                ],
                              ),
                            ).visible(packagingSymbols.isNotEmpty),
                            16.height.visible(packagingSymbols.isNotEmpty),
                            Text(language.shippedVia, style: boldTextStyle(size: 16)).visible(courierDetails != null &&
                                (orderData!.status != ORDER_CREATED && orderData!.status != ORDER_DELIVERED)),
                            12.height.visible(courierDetails != null &&
                                orderData!.status != ORDER_CREATED &&
                                (orderData!.status != ORDER_DELIVERED)),
                            if (courierDetails != null &&
                                orderData!.status != ORDER_DELIVERED &&
                                orderData!.status != ORDER_CREATED)
                              Container(
                                decoration: boxDecorationWithRoundedCorners(
                                    borderRadius: BorderRadius.circular(defaultRadius),
                                    border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                                    backgroundColor: Colors.transparent),
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(ic_no_data,
                                                height: 30, width: 30, fit: BoxFit.cover, alignment: Alignment.center)
                                            .center(),
                                        8.width,
                                        Text(courierDetails!.name.toString(), style: boldTextStyle()).expand(),
                                        if (!courierDetails!.link.isEmptyOrNull)
                                          AppButton(
                                            elevation: 0,
                                            height: 20,
                                            color: Colors.transparent,
                                            padding: EdgeInsets.symmetric(vertical: 4),
                                            shapeBorder: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(defaultRadius),
                                              side: BorderSide(color: ColorUtils.colorPrimary),
                                            ),
                                            child: Text(language.track,
                                                style: primaryTextStyle(color: ColorUtils.colorPrimary)),
                                            onTap: () {
                                              commonLaunchUrl(courierDetails!.link.toString());
                                            },
                                          ),

                                        //  .visible(orderData!.status != ORDER_DELIVERED && orderData!.status != ORDER_CANCELLED && userData!.userType!=ADMIN && userData!.userType!=DEMO_ADMIN)
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            16.height.visible(courierDetails != null && orderData!.status != ORDER_DELIVERED),
                            Text(language.paymentDetails, style: boldTextStyle(size: 16)),
                            12.height,
                            Container(
                              decoration: boxDecorationWithRoundedCorners(
                                  borderRadius: BorderRadius.circular(defaultRadius),
                                  border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                                  backgroundColor: Colors.transparent),
                              padding: EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.paymentType, style: secondaryTextStyle()),
                                      Text('${paymentType(orderData!.paymentType.validate(value: PAYMENT_TYPE_CASH))}',
                                          style: boldTextStyle(size: 14)),
                                    ],
                                  ),
                                  8.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.paymentStatus, style: secondaryTextStyle()),
                                      Text(
                                          '${paymentStatus(orderData!.paymentStatus.validate(value: PAYMENT_PENDING))}',
                                          style: boldTextStyle(size: 14)),
                                    ],
                                  ),
                                  8.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.paymentCollectFrom, style: secondaryTextStyle()),
                                      Text('${paymentCollectForm(orderData!.paymentCollectFrom!)}',
                                          style: boldTextStyle(size: 14)),
                                    ],
                                  ).visible(
                                      orderData!.paymentType.validate(value: PAYMENT_TYPE_CASH) == PAYMENT_TYPE_CASH),
                                ],
                              ),
                            ),
                            8.height,
                            Text(language.info, style: boldTextStyle(size: 16)).visible(
                                !orderData!.pickupPoint!.description.isEmptyOrNull ||
                                    !orderData!.deliveryPoint!.description.isEmptyOrNull),
                            12.height,
                            Container(
                              decoration: boxDecorationWithRoundedCorners(
                                  borderRadius: BorderRadius.circular(defaultRadius),
                                  border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                                  backgroundColor: Colors.transparent),
                              padding: EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.pickupInformation, style: secondaryTextStyle()),
                                      Text(orderData!.pickupPoint!.description.toString(),
                                          style: boldTextStyle(size: 14)),
                                    ],
                                  ).visible(!orderData!.pickupPoint!.description.isEmptyOrNull),
                                  8.height.visible(!orderData!.pickupPoint!.description.isEmptyOrNull),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.deliveryInformation, style: secondaryTextStyle()),
                                      Text(orderData!.deliveryPoint!.description.toString(),
                                          style: boldTextStyle(size: 14)),
                                    ],
                                  ).visible(!orderData!.deliveryPoint!.description.isEmptyOrNull),
                                ],
                              ),
                            ),
                            if (orderData!.vehicleData != null) 16.height,
                            if (orderData!.vehicleData != null) Text(language.vehicle, style: boldTextStyle()),
                            if (orderData!.vehicleData != null) 12.height,
                            if (orderData!.vehicleData != null)
                              Container(
                                decoration: boxDecorationWithRoundedCorners(
                                    borderRadius: BorderRadius.circular(defaultRadius),
                                    border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                                    backgroundColor: Colors.transparent),
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (orderData!.vehicleImage != null)
                                      ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: commonCachedNetworkImage(orderData!.vehicleImage,
                                              fit: BoxFit.fill, height: 100, width: 150)),
                                    8.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(language.vehicleName, style: secondaryTextStyle()),
                                        Text('${orderData!.vehicleData!.title.validate()}', style: primaryTextStyle())
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            if (userData != null &&
                                (orderData!.status != ORDER_CREATED && orderData!.status != ORDER_DRAFT))
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  16.height,
                                  Text(
                                      '${getStringAsync(USER_TYPE) == CLIENT ? language.aboutDeliveryMan : language.aboutUser}',
                                      style: boldTextStyle(size: 16)),
                                  12.height,
                                  Container(
                                    decoration: boxDecorationWithRoundedCorners(
                                        borderRadius: BorderRadius.circular(defaultRadius),
                                        border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                                        backgroundColor: Colors.transparent),
                                    padding: EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Image.network(userData!.profileImage.validate(),
                                                    height: 60,
                                                    width: 60,
                                                    fit: BoxFit.cover,
                                                    alignment: Alignment.center)
                                                .cornerRadiusWithClipRRect(60)
                                                .visible(!userData!.profileImage.isEmptyOrNull),

                                            commonCachedNetworkImage(ic_profile,
                                                    height: 60,
                                                    width: 60,
                                                    fit: BoxFit.cover,
                                                    alignment: Alignment.center)
                                                .cornerRadiusWithClipRRect(60)
                                                .visible(userData!.profileImage.isEmptyOrNull),
                                            8.width,
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text('${userData!.name.validate()}', style: boldTextStyle()),
                                                        4.width,
                                                        if (getStringAsync(USER_TYPE) == CLIENT &&
                                                            !userData!.documentVerifiedAt.isEmptyOrNull)
                                                          Icon(Octicons.verified, color: Colors.green, size: 18),
                                                      ],
                                                    ),
                                                    // InkWell(
                                                    //         onTap: () {
                                                    //           ChatScreen(
                                                    //                   userData: userData,
                                                    //                   orderId: orderData!.id.toString().validate())
                                                    //               .launch(context);
                                                    //         },
                                                    //         child: Icon(Ionicons.md_chatbox_outline,
                                                    //             size: 22, color: colorPrimary))
                                                    //     .visible(orderData!.status != ORDER_DELIVERED &&
                                                    //         orderData!.status != ORDER_CANCELLED &&
                                                    //         userData!.userType.validate() != ADMIN),
                                                  ],
                                                ),
                                                4.height,
                                                userData!.contactNumber != null
                                                    ? Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text('${userData!.contactNumber}',
                                                                  style: secondaryTextStyle())
                                                              .paddingOnly(top: 4)
                                                              .onTap(() {
                                                            commonLaunchUrl('tel:${userData!.contactNumber}');
                                                          }),
                                                          InkWell(
                                                              onTap: () {
                                                                commonLaunchUrl('tel:${userData!.contactNumber}');
                                                                //   ChatScreen(userData: userData).launch(context);
                                                              },
                                                              child: Icon(Ionicons.call_outline,
                                                                  size: 22, color: ColorUtils.colorPrimary))
                                                        ],
                                                      )
                                                    : SizedBox()
                                              ],
                                            ).expand(),

                                            //  .visible(orderData!.status != ORDER_DELIVERED && orderData!.status != ORDER_CANCELLED && userData!.userType!=ADMIN && userData!.userType!=DEMO_ADMIN)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            if (orderData!.reason.validate().isNotEmpty && orderData!.status != ORDER_CANCELLED)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  24.height,
                                  Text(language.returnReason, style: boldTextStyle()),
                                  12.height,
                                  Container(
                                    width: context.width(),
                                    decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    padding: EdgeInsets.all(12),
                                    child: Text('${orderData!.reason.validate(value: "-")}',
                                        style: primaryTextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            if (orderData!.status == ORDER_CANCELLED)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  24.height,
                                  Text(language.cancelledReason, style: boldTextStyle()),
                                  12.height,
                                  Container(
                                    width: context.width(),
                                    decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    padding: EdgeInsets.all(12),
                                    child: Text('${orderData!.reason.validate(value: "-")}',
                                        style: primaryTextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            16.height,
                            (orderData!.extraCharges.runtimeType == List<dynamic>)
                                ? OrderSummeryWidget(
                                    productAmount: productAmount,
                                    vehiclePrice:
                                        orderData!.vehicleData != null ? orderData!.vehicleData!.price.validate() : 0,
                                    extraChargesList: list,
                                    totalDistance: orderData!.totalDistance != null ? orderData!.totalDistance : 0,
                                    totalWeight: orderData!.totalWeight.validate(),
                                    distanceCharge: orderData!.distanceCharge.validate(),
                                    weightCharge: orderData!.weightCharge.validate(),
                                    totalAmount: orderData!.totalAmount,
                                    payment: payment,
                                    status: orderData!.status,
                                    isDetail: true,
                                    isInsuranceChargeDisplay: orderData!.insuranceCharge != 0 ? true : false,
                                    insuranceCharge: orderData!.insuranceCharge)
                                : Container(
                                    width: context.width(),
                                    padding: EdgeInsets.all(16),
                                    decoration: boxDecorationWithRoundedCorners(
                                      borderRadius: BorderRadius.circular(defaultRadius),
                                      border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.2)),
                                      backgroundColor: Colors.transparent,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (orderItems.validate().isNotEmpty)
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(language.productAmount, style: primaryTextStyle()),
                                              16.width,
                                              Text('${printAmount(productAmount)}', style: primaryTextStyle()),
                                            ],
                                          ),
                                        if (orderData!.vehicleData != null)
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("${language.vehicle} ${language.price.toLowerCase()}",
                                                  style: primaryTextStyle()),
                                              16.width,
                                              Text('${printAmount(orderData!.vehicleData!.price)}',
                                                  style: primaryTextStyle()),
                                            ],
                                          ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(language.deliveryCharge, style: primaryTextStyle()),
                                            16.width,
                                            Text('${printAmount(orderData!.fixedCharges.validate())}',
                                                style: primaryTextStyle()),
                                          ],
                                        ),
                                        //todo add keys
                                        if (orderData!.insuranceCharge != 0)
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Insurance Charge", style: primaryTextStyle()),
                                              16.width,
                                              Text('${orderData!.insuranceCharge.validate()}',
                                                  style: primaryTextStyle()),
                                            ],
                                          ),
                                        if (orderData!.distanceCharge.validate() != 0)
                                          Column(
                                            children: [
                                              8.height,
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(language.distanceCharge, style: primaryTextStyle()),
                                                  16.width,
                                                  Text('${printAmount(orderData!.distanceCharge.validate())}',
                                                      style: primaryTextStyle()),
                                                ],
                                              )
                                            ],
                                          ),
                                        if (orderData!.weightCharge.validate() != 0)
                                          Column(
                                            children: [
                                              8.height,
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(language.weightCharge, style: primaryTextStyle()),
                                                  16.width,
                                                  Text('${printAmount(orderData!.weightCharge.validate())}',
                                                      style: primaryTextStyle()),
                                                ],
                                              ),
                                            ],
                                          ),
                                        /*Align(
                                          alignment: Alignment.bottomRight,
                                          child: Column(
                                            children: [
                                              8.height,
                                              Text(
                                                  '${printAmount(orderData!.fixedCharges.validate() + orderData!.distanceCharge.validate() + orderData!.weightCharge.validate())}',
                                                  style: primaryTextStyle()),
                                            ],
                                          ),
                                        ).visible((orderData!.distanceCharge.validate() != 0 ||
                                                orderData!.weightCharge.validate() != 0) &&
                                            orderData!.extraCharges.keys.length != 0),*/
                                        if (orderData!.extraCharges != null)
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              16.height,
                                              Text(language.extraCharges, style: boldTextStyle()),
                                              8.height,
                                              Column(
                                                  children:
                                                      List.generate(orderData!.extraCharges!.keys.length, (index) {
                                                return Padding(
                                                  padding: EdgeInsets.only(bottom: 8),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                          orderData!.extraCharges.keys
                                                              .elementAt(index)
                                                              .replaceAll("_", " "),
                                                          style: primaryTextStyle()),
                                                      16.width,
                                                      Text(
                                                          '${printAmount(orderData!.extraCharges.values.elementAt(index))}',
                                                          style: primaryTextStyle()),
                                                    ],
                                                  ),
                                                );
                                              }).toList()),
                                            ],
                                          ).visible(orderData!.extraCharges.keys.length != 0),
                                        16.height,
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(language.total, style: boldTextStyle(size: 20)),
                                            (orderData!.status == ORDER_CANCELLED &&
                                                    payment != null &&
                                                    payment!.deliveryManFee == 0)
                                                ? Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text('${printAmount(orderData!.totalAmount.validate())}',
                                                          style: secondaryTextStyle(
                                                              size: 16, decoration: TextDecoration.lineThrough)),
                                                      8.width,
                                                      Text('${printAmount(payment!.cancelCharges.validate())}',
                                                          style: boldTextStyle(size: 20)),
                                                    ],
                                                  )
                                                : Text('${printAmount(orderData!.totalAmount ?? 0)}',
                                                    style: boldTextStyle(size: 20)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                            16.height,
                            Text(language.reason, style: boldTextStyle(size: 16)).visible(
                                getStringAsync(USER_TYPE) == DELIVERY_MAN &&
                                    (orderData!.status == ORDER_ACCEPTED ||
                                        orderData!.status == ORDER_PICKED_UP ||
                                        orderData!.status == ORDER_ARRIVED ||
                                        orderData!.status == ORDER_DEPARTED)),
                            8.height,
                            DropdownButtonFormField<String>(
                              value: reason,
                              isExpanded: true,
                              isDense: true,
                              decoration: commonInputDecoration(),
                              items: reasonsList.map((e) {
                                return DropdownMenuItem(value: e, child: Text(e));
                              }).toList(),
                              onChanged: (String? val) {
                                int index = reasonsList.indexOf(val.toString());
                                isOtherOptionSelected = index == reasonsList.length - 1;
                                reason = val;
                                setState(() {});
                              },
                              validator: (value) {
                                if (value == null) return language.fieldRequiredMsg;
                                return null;
                              },
                            ).visible(getStringAsync(USER_TYPE) == DELIVERY_MAN &&
                                (orderData!.status == ORDER_ACCEPTED ||
                                    orderData!.status == ORDER_PICKED_UP ||
                                    orderData!.status == ORDER_ARRIVED ||
                                    orderData!.status == ORDER_DEPARTED)),
                            16.height,
                            // controller for reason if selected reason type is others
                            AppTextField(
                              textFieldType: TextFieldType.OTHER,
                              controller: reasonController,
                              decoration: commonInputDecoration(hintText: language.writeReasonHere),
                              maxLines: 3,
                              minLines: 3,
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  otherReason = reasonController.text.toString();
                                  print("--------------reason${otherReason}");
                                }
                              },
                              textInputAction: TextInputAction.done,
                            ).visible(reason.validate().trim() == language.other.trim()),
                            16.height,
                            if (orderData!.status == ORDER_CANCELLED && payment != null)
                              Container(
                                width: context.width(),
                                decoration: BoxDecoration(
                                    color: appStore.isDarkMode
                                        ? ColorUtils.scaffoldSecondaryDark
                                        : ColorUtils.colorPrimary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.all(12),
                                child: Text(
                                    '${language.note} ${payment!.deliveryManFee == 0 ? language.cancelBeforePickMsg : language.cancelAfterPickMsg}',
                                    style: secondaryTextStyle(color: Colors.red)),
                              ),
                            Container(
                              width: context.width() * 0.9,
                              child: Text(
                                formatRemainingTime(remainingTime),
                                style: boldTextStyle(color: Colors.red),
                                textAlign: TextAlign.right,
                              ).visible(getStringAsync(USER_TYPE) == CLIENT &&
                                  orderData!.status != ORDER_DELIVERED &&
                                  orderData!.status != ORDER_CANCELLED &&
                                  canCancel),
                            ),
                            8.height,
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Column(
                                children: [
                                  commonButton(language.cancelOrder, () {
                                    showInDialog(
                                      context,
                                      backgroundColor: ColorUtils.colorPrimaryLight,
                                      contentPadding: EdgeInsets.all(16),
                                      builder: (p0) {
                                        return CancelOrderDialog(
                                            orderId: orderData!.id.validate(),
                                            onUpdate: () {
                                              list.clear();
                                              orderDetailApiCall();
                                              LiveStream().emit('UpdateOrderData');
                                            });
                                      },
                                    );
                                  }, width: context.width()),
                                  8.height,
                                  Container(
                                    width: context.width(),
                                    decoration: BoxDecoration(
                                        color: appStore.isDarkMode
                                            ? scaffoldSecondaryDark
                                            : ColorUtils.colorPrimary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: EdgeInsets.all(12),
                                    child: Text(language.cancelNote, style: secondaryTextStyle()),
                                  ),
                                ],
                              ),
                            ).visible(getStringAsync(USER_TYPE) == CLIENT &&
                                orderData!.status != ORDER_DELIVERED &&
                                orderData!.status != ORDER_CANCELLED &&
                                canCancel),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: commonButton(language.returnOrder, () {
                                ReturnOrderScreen(
                                  orderData!,
                                  orderItems: orderItems,
                                ).launch(context);
                              }, width: context.width()),
                            ).visible(orderData!.status == ORDER_DELIVERED &&
                                !orderData!.returnOrderId! &&
                                orderData!.parentOrderId == null &&
                                getStringAsync(USER_TYPE) == CLIENT),
                          ],
                        ),
                      ],
                    ),
                    // return order option for delivery person
                    Positioned(
                      bottom: 10,
                      left: context.height() * 0.11,
                      right: context.height() * 0.11,
                      child: commonButton(language.cancelOrder, () {
                        if (!reason.isEmptyOrNull) {
                          cancelOrderByDeliveryManApiCall();
                        } else {
                          toast(language.pleaseSelectReason);
                        }
                      }, width: context.width()),
                    ).visible((orderData!.status == ORDER_TRANSFER || orderData!.status == ORDER_ACCEPTED) &&
                        getStringAsync(USER_TYPE) == DELIVERY_MAN),
                    // return & cancel order option for delivery person
                    Positioned(
                      bottom: 10,
                      left: context.height() * 0.11,
                      right: context.height() * 0.11,
                      //todo add keys
                      child: commonButton(language.cancelAndReturn, () {
                        if (!reason.isEmptyOrNull) {
                          createOrderApiCall();
                        } else {
                          //todo add keys
                          toast(language.pleaseSelectReason);
                        }

                        //      ReturnOrderScreen(orderData!, orderItems: orderItems, isCancelAndReturn: 1).launch(context);
                      }, width: context.width()),
                    ).visible((orderData!.status == ORDER_ARRIVED ||
                            orderData!.status == ORDER_DEPARTED ||
                            orderData!.status == ORDER_PICKED_UP) &&
                        getStringAsync(USER_TYPE) == DELIVERY_MAN),
                    // chat option
                    Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                            width: 60,
                            height: 60,
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: boxDecorationWithRoundedCorners(
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                                backgroundColor: ColorUtils.colorPrimary),
                            child: Stack(
                              children: [
                                if (userData != null && userData!.uid != null)
                                  Positioned(
                                    top: 8,
                                    right: 10,
                                    child: StreamBuilder<int>(
                                        stream: ordersMessageService.getUnReadCount(
                                            receiverId: userData!.uid!, orderId: orderData!.id.toString()),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData && snapshot.data != null && snapshot.data! > 0) {
                                            return Lottie.asset(ic_chat_unread_count,
                                                width: 18, height: 18, fit: BoxFit.cover);
                                          }
                                          return SizedBox();
                                        }),
                                  ).visible(orderData!.status != ORDER_DELIVERED &&
                                      orderData!.status != ORDER_CANCELLED &&
                                      userData!.userType.validate() != ADMIN),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  bottom: 0,
                                  left: 0,
                                  child: Icon(
                                    Icons.chat_bubble_outline,
                                    size: 25,
                                    color: white,
                                  ),
                                )
                              ],
                            )).onTap(() {
                          ChatScreen(userData: userData, orderId: orderData!.id.toString().validate()).launch(context);
                        })).visible(orderData!.status !=
                            ORDER_CREATED &&
                        orderData!.status != ORDER_DELIVERED &&
                        orderData!.status != ORDER_CANCELLED &&
                        userData!.userType.validate() != ADMIN),
                  ],
                )
              : SizedBox(),
          Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
