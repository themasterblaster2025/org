import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/CountryListModel.dart';
import 'package:mighty_delivery/main/models/LoginResponse.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:mighty_delivery/user/components/CancelOrderDialog.dart';
import 'package:mighty_delivery/user/screens/ReturnOrderScreen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main/models/OrderDetailModel.dart';
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
  List<OrderHistory>? orderHistory;

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
      appStore.setLoading(false);
      orderData = value.data!;
      orderHistory = value.orderHistory!;
      if (getStringAsync(USER_TYPE) == CLIENT) {
        if (orderData!.deliveryManId != null) userDetailApiCall(orderData!.deliveryManId!);
      } else {
        if (orderData!.clientId != null) userDetailApiCall(orderData!.clientId!);
      }
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  userDetailApiCall(int id) async {
    appStore.setLoading(true);
    await getUserDetail(id).then((value) {
      appStore.setLoading(false);
      userData = value;
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        finish(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(language.order_details)),
        body: BodyCornerWidget(
          child: !appStore.isLoading && orderData != null
              ? Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('#${orderData!.id}', style: boldTextStyle()),
                              Text('${orderStatus(orderData!.status.validate(value: ORDER_CREATE))}', style: boldTextStyle(color: statusColor(orderData!.status ?? ""))),
                            ],
                          ),
                          8.height,
                          Text(printDate(orderData!.date!), style: secondaryTextStyle()),
                          16.height,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.reason, style: secondaryTextStyle(size: 16)),
                              8.height,
                              Text('${orderData!.reason}', style: boldTextStyle()),
                              16.height,
                            ],
                          ).visible(orderData!.status == ORDER_CANCELLED),
                          Text(language.payment_method, style: secondaryTextStyle(size: 16)),
                          8.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${orderData!.paymentType.validate(value: PAYMENT_TYPE_CASH)}', style: boldTextStyle()),
                              Text('${orderData!.paymentStatus.validate(value: PAYMENT_PENDING)}',
                                  style: boldTextStyle(color: paymentStatusColor(orderData!.paymentStatus.validate(value: PAYMENT_PENDING)))),
                            ],
                          ),
                          24.height,
                          Row(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, color: colorPrimary),
                                      Text('...', style: boldTextStyle(size: 20, color: colorPrimary)),
                                      16.width,
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (orderData!.pickupDatetime != null)
                                            Text('${language.picked_at} ${printDate(orderData!.pickupDatetime!)}', style: secondaryTextStyle()).paddingOnly(bottom: 8),
                                          Text('${orderData!.pickupPoint!.address}', style: primaryTextStyle()),
                                          if (orderData!.pickupPoint!.contactNumber != null)
                                            Row(
                                              children: [
                                                Icon(Icons.call, color: Colors.green, size: 18).onTap(() {
                                                  launch('tel:${orderData!.pickupPoint!.contactNumber}');
                                                }),
                                                8.width,
                                                Text('${orderData!.pickupPoint!.contactNumber}', style: secondaryTextStyle()),
                                              ],
                                            ).paddingOnly(top: 8),
                                          if (orderData!.pickupDatetime == null && orderData!.pickupPoint!.endTime != null && orderData!.pickupPoint!.startTime != null)
                                            Text('${language.note} ${language.courier_will_pickup_at} ${DateFormat('dd MMM yyyy').format(DateTime.parse(orderData!.pickupPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.pickupPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.pickupPoint!.endTime!).toLocal())}',
                                                    style: secondaryTextStyle())
                                                .paddingOnly(top: 8),
                                        ],
                                      ).expand(),
                                    ],
                                  ),
                                  16.height,
                                  Row(
                                    children: [
                                      Text('...', style: boldTextStyle(size: 20, color: colorPrimary)),
                                      Icon(Icons.location_on, color: colorPrimary),
                                      16.width,
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (orderData!.deliveryDatetime != null)
                                            Text('${language.delivered_at} ${printDate(orderData!.deliveryDatetime!)}', style: secondaryTextStyle()).paddingOnly(bottom: 8),
                                          Text('${orderData!.deliveryPoint!.address}', style: primaryTextStyle()),
                                          if (orderData!.deliveryPoint!.contactNumber != null)
                                            Row(
                                              children: [
                                                Icon(Icons.call, color: Colors.green, size: 18).onTap(() {
                                                  launch('tel:${orderData!.deliveryPoint!.contactNumber}');
                                                }),
                                                8.width,
                                                Text('${orderData!.deliveryPoint!.contactNumber}', style: secondaryTextStyle()),
                                              ],
                                            ).paddingOnly(top: 8),
                                          if (orderData!.deliveryDatetime == null && orderData!.deliveryPoint!.endTime != null && orderData!.deliveryPoint!.startTime != null)
                                            Text('${language.note} ${language.courier_will_deliver_at}${DateFormat('dd MMM yyyy').format(DateTime.parse(orderData!.deliveryPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPoint!.endTime!).toLocal())}',
                                                    style: secondaryTextStyle())
                                                .paddingOnly(top: 8),
                                        ],
                                      ).expand(),
                                    ],
                                  ),
                                ],
                              ).expand(),
                              16.width,
                              Icon(Icons.navigate_next, color: Colors.grey).onTap(() {
                                print(orderHistory!.length.toString());
                                OrderHistoryScreen(orderHistory: orderHistory.validate()).launch(context);
                              }),
                            ],
                          ),
                          24.height,
                          Text(language.distance, style: secondaryTextStyle(size: 16)),
                          8.height,
                          Text('${orderData!.totalDistance} ${CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).distance_type}', style: boldTextStyle()),
                          16.height,
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(language.country, style: secondaryTextStyle(size: 16)),
                                  8.height,
                                  Text('${orderData!.countryName}', style: boldTextStyle()),
                                ],
                              ).expand(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(language.city, style: secondaryTextStyle(size: 16)),
                                  8.height,
                                  Text('${orderData!.cityName}', style: boldTextStyle()),
                                ],
                              ).expand()
                            ],
                          ),
                          Divider(height: 30, thickness: 1),
                          Text(language.parcel_details, style: boldTextStyle(size: 16)),
                          16.height,
                          Container(
                            decoration: BoxDecoration(color: appStore.isDarkMode ? scaffoldSecondaryDark : colorPrimary.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  decoration: boxDecorationWithRoundedCorners(
                                      borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1), backgroundColor: Colors.transparent),
                                  padding: EdgeInsets.all(8),
                                  child: Image.asset(parcelTypeIcon(orderData!.parcelType.validate()), height: 24, width: 24, color: Colors.grey),
                                ),
                                8.width,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(orderData!.parcelType.validate(), style: boldTextStyle()),
                                    4.height,
                                    Text('${orderData!.totalWeight} ${CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).weight_type}', style: secondaryTextStyle()),
                                  ],
                                ).expand(),
                              ],
                            ),
                          ),
                          Divider(height: 30, thickness: 1),
                          if (userData != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${getStringAsync(USER_TYPE) == CLIENT ? language.about_delivery_man : language.about_user}', style: boldTextStyle(size: 16)),
                                16.height,
                                Container(
                                  decoration: BoxDecoration(color: appStore.isDarkMode ? scaffoldSecondaryDark : colorPrimary.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(backgroundImage: NetworkImage(userData!.profile_image.validate()), radius: 30),
                                          16.width,
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text('${userData!.name.validate()}', style: boldTextStyle()),
                                              4.height,
                                              Text('${userData!.email.validate()}', style: secondaryTextStyle()),
                                            ],
                                          ),
                                        ],
                                      ),
                                      8.height,
                                      if (userData!.contact_number != null)
                                      Row(
                                        children: [
                                          Icon(Icons.call, color: Colors.green, size: 18).onTap(() {
                                            launch('tel:${userData!.contact_number}');
                                          }),
                                          16.width,
                                          Text('${userData!.contact_number}', style: primaryTextStyle())
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 30, thickness: 1),
                              ],
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(language.delivery_charge, style: primaryTextStyle()),
                              16.width,
                              Text('$currencySymbol ${orderData!.fixedCharges}', style: boldTextStyle()),
                            ],
                          ),
                          //if (orderData!.distanceCharge.validate() != 0)
                            Column(
                              children: [
                                8.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(language.distance_charge, style: primaryTextStyle()),
                                    16.width,
                                    Text('$currencySymbol ${orderData!.distanceCharge}', style: boldTextStyle()),
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
                                    Text(language.weight_charge, style: primaryTextStyle()),
                                    16.width,
                                    Text('$currencySymbol ${orderData!.weightCharge}', style: boldTextStyle()),
                                  ],
                                ),
                              ],
                            ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Column(
                              children: [
                                8.height,
                                Text('$currencySymbol ${orderData!.fixedCharges.validate() + orderData!.distanceCharge.validate() + orderData!.weightCharge.validate()}', style: boldTextStyle()),
                              ],
                            ),
                          ).visible((orderData!.distanceCharge.validate() != 0 || orderData!.weightCharge.validate() != 0) && orderData!.extraCharges.keys.length != 0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              16.height,
                              Text(language.extra_charges, style: boldTextStyle()),
                              8.height,
                              Column(
                                  children: List.generate(orderData!.extraCharges.keys.length, (index) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(orderData!.extraCharges.keys.elementAt(index).replaceAll("_", " "), style: primaryTextStyle()),
                                      16.width,
                                      Text('$currencySymbol ${orderData!.extraCharges.values.elementAt(index)}', style: boldTextStyle()),
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
                              Text(language.total, style: boldTextStyle(size: 18)),
                              Text('$currencySymbol ${orderData!.totalAmount}', style: boldTextStyle(size: 18, color: colorPrimary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: commonButton(language.return_order, () {
                        ReturnOrderScreen(orderData!).launch(context);
                      }, width: context.width())
                          .paddingAll(16),
                    ).visible(orderData!.status == ORDER_COMPLETED && !orderData!.returnOrderId! && getStringAsync(USER_TYPE) == CLIENT),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: commonButton(language.cancel_order, () {
                        showInDialog(
                          context,
                          contentPadding: EdgeInsets.all(16),
                          builder: (p0) {
                            return CancelOrderDialog(
                                orderId: orderData!.id.validate(),
                                onUpdate: () {
                                  orderDetailApiCall();
                                  LiveStream().emit('UpdateOrderData');
                                });
                          },
                        );
                      }, width: context.width())
                          .paddingAll(16),
                    ).visible(orderData!.status == ORDER_CREATE && getStringAsync(USER_TYPE) == CLIENT)
                  ],
                )
              : loaderWidget(),
        ),
      ),
    );
  }
}
