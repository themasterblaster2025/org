import 'package:flutter/material.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/CityListModel.dart';
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
import 'package:timeline_tile/timeline_tile.dart';

class OrderDetailScreen extends StatefulWidget {
  static String tag = '/OrderDetailScreen';

  final int orderId;

  OrderDetailScreen({required this.orderId});

  @override
  OrderDetailScreenState createState() => OrderDetailScreenState();
}

class OrderDetailScreenState extends State<OrderDetailScreen> {
  CityModel? cityData;
  UserData? userData;

  OrderData? orderData;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  Future<void> init() async {
    cityData = CityModel.fromJson(getJSONAsync(CITY_DATA));
    orderDetailApiCall();
  }

  orderDetailApiCall() async {
    appStore.setLoading(true);
    await getOrderDetails(widget.orderId).then((value) {
      appStore.setLoading(false);
      orderData = value;

      if(getStringAsync(USER_TYPE) == CLIENT){
        if (orderData!.deliveryManId != null) userDetailApiCall(orderData!.deliveryManId!);
      }else{
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
      onWillPop: () async{
        finish(context,true);
        return false;
      },
      child: Scaffold(
        appBar: appBarWidget(language.order_details, color: colorPrimary, textColor: white, elevation: 0),
        body: !appStore.isLoading && orderData != null
            ? BodyCornerWidget(
                child: Stack(
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
                          Text(language.payment_method, style: secondaryTextStyle(size: 16)),
                          8.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${orderData!.paymentType.validate(value: PAYMENT_TYPE_CASH)}', style: boldTextStyle()),
                              Text('${orderData!.paymentStatus.validate(value: PAYMENT_PENDING)}', style: boldTextStyle(color: paymentStatusColor(orderData!.paymentStatus.validate(value: PAYMENT_PENDING)))),
                            ],
                          ),
                          16.height,
                          Column(
                            children: [
                              TimelineTile(
                                alignment: TimelineAlign.start,
                                isFirst: true,
                                indicatorStyle: IndicatorStyle(width: 15, color: colorPrimary),
                                afterLineStyle: LineStyle(color: colorPrimary, thickness: 3),
                                endChild: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (orderData!.pickupDatetime != null) Text('${language.picked_at} ${printDate(orderData!.pickupDatetime!)}', style: secondaryTextStyle()).paddingOnly(bottom: 8),
                                    Text('${orderData!.pickupPoint!.address}', style: primaryTextStyle()),
                                    if (orderData!.pickupPoint!.contactNumber != null)
                                      Row(
                                        children: [
                                          Icon(Icons.call, color: Colors.green, size: 18),
                                          8.width,
                                          Text('${orderData!.pickupPoint!.contactNumber}', style: secondaryTextStyle()),
                                        ],
                                      ).paddingOnly(top: 8),
                                  ],
                                ).paddingAll(16),
                              ),
                              TimelineTile(
                                alignment: TimelineAlign.start,
                                isLast: true,
                                indicatorStyle: IndicatorStyle(width: 15, color: colorPrimary),
                                beforeLineStyle: LineStyle(color: colorPrimary, thickness: 3),
                                endChild: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (orderData!.deliveryDatetime != null) Text('${language.delivered_at} ${printDate(orderData!.deliveryDatetime!)}', style: secondaryTextStyle()).paddingOnly(bottom: 8),
                                    Text('${orderData!.deliveryPoint!.address}', style: primaryTextStyle()),
                                    if (orderData!.deliveryPoint!.contactNumber != null)
                                      Row(
                                        children: [
                                          Icon(Icons.call, color: Colors.green, size: 18),
                                          8.width,
                                          Text('${orderData!.deliveryPoint!.contactNumber}', style: secondaryTextStyle()),
                                        ],
                                      ).paddingOnly(top: 8),
                                  ],
                                ).paddingAll(16),
                              ),
                            ],
                          ),
                          16.height,
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
                            decoration: BoxDecoration(color: colorPrimary.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  decoration: boxDecorationWithRoundedCorners(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: borderColor),
                                  ),
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
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('${getStringAsync(USER_TYPE) == CLIENT ? language.about_delivery_man : language.about_user}', style: boldTextStyle(size: 16)),
                              16.height,
                              Container(
                                decoration: BoxDecoration(color: colorPrimary.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(backgroundImage: NetworkImage(userData!.profile_image.validate()), radius: 30),
                                        16.width,
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('${userData!.name.validate()}', style: boldTextStyle()),
                                            8.height,
                                            Text('${userData!.email.validate()}', style: primaryTextStyle()),
                                          ],
                                        ).expand(),
                                      ],
                                    ),
                                    if (userData!.address != null)
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, color: colorPrimary, size: 22),
                                          16.width,
                                          Text('${userData!.address}', style: primaryTextStyle()).expand(),
                                        ],
                                      ).paddingOnly(top: 16),
                                    if (userData!.contact_number != null)
                                      Row(
                                        children: [
                                          Icon(Icons.phone, color: Colors.green, size: 22),
                                          16.width,
                                          Text('${userData!.contact_number}', style: primaryTextStyle()).expand(),
                                        ],
                                      ).paddingOnly(top: 8),
                                  ],
                                ),
                              ),
                              Divider(height: 30, thickness: 1),
                            ]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(language.delivery_charge, style: primaryTextStyle()),
                              16.width,
                              Text('$currencySymbol ${orderData!.fixedCharges}', style: boldTextStyle()),
                            ],
                          ),
                          if(orderData!.distanceCharge.validate() !=0) Column(
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
                          if(orderData!.weightCharge.validate() != 0) Column(
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
                                Text('$currencySymbol ${cityData!.fixedCharges.validate() + orderData!.distanceCharge.validate() + orderData!.weightCharge.validate()}', style: boldTextStyle()),
                              ],
                            ),
                          ).visible((orderData!.distanceCharge.validate() !=0  || orderData!.weightCharge.validate()!=0) && orderData!.extraCharges.keys.length != 0),
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
                    ).visible(orderData!.status == ORDER_COMPLETED && !orderData!.returnOrderId!),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: commonButton(language.cancel_order, () {
                        showInDialog(
                          context,
                          contentPadding: EdgeInsets.all(16),
                          builder: (p0) {
                            return CancelOrderDialog(orderId: orderData!.id.validate(),onUpdate: (){
                              orderDetailApiCall();
                              LiveStream().emit('UpdateOrderData');
                            });
                          },
                        );
                      }, width: context.width())
                          .paddingAll(16),
                    ).visible(orderData!.status == ORDER_CREATE)
                  ],
                ),
              )
            : loaderWidget(),
      ),
    );
  }
}
