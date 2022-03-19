import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/delivery/screens/ReceivedScreenOrderScreen.dart';
import 'package:mighty_delivery/delivery/screens/TrackingScreen.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/user/screens/OrderDetailScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';

class CreateTabScreen extends StatefulWidget {
  final String? orderStatus;

  CreateTabScreen({this.orderStatus});

  @override
  CreateTabScreenState createState() => CreateTabScreenState();
}

class CreateTabScreenState extends State<CreateTabScreen> {
  ScrollController scrollController = ScrollController();
  int currentPage = 1;
  int totalPage = 1;

  List<OrderData> orderData = [];

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          appStore.setLoading(true);

          currentPage++;
          setState(() {});

          init();
        }
      }
    });
    afterBuildCreated(() => appStore.setLoading(true));
  }

  void init() async {
    getDeliveryBoyList(page: currentPage, deliveryBoyID: getIntAsync(USER_ID), cityId: getIntAsync(CITY_ID), countryId: getIntAsync(COUNTRY_ID), orderStatus: widget.orderStatus!).then((value) {
      appStore.setLoading(false);
      appStore.setAllUnreadCount(value.allUnreadCount.validate());

      currentPage = value.pagination!.currentPage!;
      totalPage = value.pagination!.totalPages!;

      if (currentPage == 1) {
        orderData.clear();
      }
      orderData.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Stack(
        children: [
          ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.all(16),
            shrinkWrap: true,
            itemCount: orderData.length,
            itemBuilder: (_, index) {
              OrderData data = orderData[index];
              return GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt()),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('# ${data.id}', style: boldTextStyle(size: 16)).expand(),
                          4.height,
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await updateOrder(orderStatus: ORDER_ARRIVED, orderId: data.id);
                                  init();
                                },
                                icon: Icon(Icons.notifications_outlined),
                              ).visible(data.status == ORDER_ACTIVE),
                              widget.orderStatus != ORDER_CANCELLED
                                  ? AppButton(
                                      text: buttonText(widget.orderStatus!),
                                      padding: EdgeInsets.all(0),
                                      textStyle: boldTextStyle(color: Colors.white),
                                      color: colorPrimary,
                                      onTap: () {
                                        onTapData(orderData: data, orderStatus: widget.orderStatus!);
                                      },
                                    ).visible(widget.orderStatus != ORDER_COMPLETED)
                                  : SizedBox(),
                            ],
                          )
                        ],
                      ),
                      4.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            'https://www.diethelmtravel.com/wp-content/uploads/2016/04/bill-gates-wealthiest-person.jpg',
                            height: 30,
                            width: 30,
                            fit: BoxFit.cover,
                          ).cornerRadiusWithClipRRect(4),
                          8.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data.clientName ?? '', style: boldTextStyle()),
                              4.height,
                              data.date != null ? Text(printDate(data.date ?? ''), style: secondaryTextStyle()) : SizedBox(),
                            ],
                          ).expand(),
                        ],
                      ),
                      Divider(height: 30, thickness: 1),
                      Row(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(Icons.location_on, color: colorPrimary),
                              Text('...', style: boldTextStyle(size: 20, color: colorPrimary)),
                            ],
                          ),
                          8.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data.pickupDatetime != null) Text('${language.picked_at} ${printDate(data.pickupDatetime!)}', style: secondaryTextStyle()).paddingOnly(bottom: 8),
                              Text('${data.pickupPoint!.address}', style: primaryTextStyle()),
                              if (data.pickupPoint!.contactNumber != null)
                                Row(
                                  children: [
                                    Icon(Icons.call, color: Colors.green, size: 18),
                                    8.width,
                                    Text('${data.pickupPoint!.contactNumber}', style: primaryTextStyle()),
                                  ],
                                ).paddingOnly(top: 8),
                              if(data.pickupDatetime==null && data.pickupPoint!.endTime!=null && data.pickupPoint!.startTime!=null) Text('Note: Courier will pickup at ${DateFormat('dd MMM yyyy').format(DateTime.parse(data.pickupPoint!.startTime!).toLocal())} from ${DateFormat('hh:mm').format(DateTime.parse(data.pickupPoint!.startTime!).toLocal())} to ${DateFormat('hh:mm').format(DateTime.parse(data.pickupPoint!.endTime!).toLocal())}',style: secondaryTextStyle()).paddingOnly(top: 8),
                            ],
                          ).expand(),
                        ],
                      ),
                      16.height,
                      Row(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('...', style: boldTextStyle(size: 20, color: colorPrimary)),
                              Icon(Icons.location_on, color: colorPrimary),
                            ],
                          ),
                          8.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data.deliveryDatetime != null) Text('${language.delivered_at} ${printDate(data.deliveryDatetime!)}', style: secondaryTextStyle()).paddingOnly(bottom: 8),
                              Text('${data.deliveryPoint!.address}', style: primaryTextStyle()),
                              if (data.deliveryPoint!.contactNumber != null)
                                Row(
                                  children: [
                                    Icon(Icons.call, color: Colors.green, size: 18),
                                    8.width,
                                    Text('${data.deliveryPoint!.contactNumber ?? ""}', style: primaryTextStyle()),
                                  ],
                                ).paddingOnly(top: 8),
                              if(data.deliveryDatetime==null && data.deliveryPoint!.endTime!=null && data.deliveryPoint!.startTime!=null) Text('Note: Courier will Deliver at ${DateFormat('dd MMM yyyy').format(DateTime.parse(data.deliveryPoint!.startTime!).toLocal())} from ${DateFormat('hh:mm').format(DateTime.parse(data.deliveryPoint!.startTime!).toLocal())} to ${DateFormat('hh:mm').format(DateTime.parse(data.deliveryPoint!.endTime!).toLocal())}',style: secondaryTextStyle()).paddingOnly(top: 8),
                            ],
                          ).expand(),
                        ],
                      ),
                      Divider(height: 30, thickness: 1),
                      Row(
                        children: [
                          Container(
                            decoration: boxDecorationWithRoundedCorners(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: borderColor),
                            ),
                            padding: EdgeInsets.all(8),
                            child: Image.asset(parcelTypeIcon('document'), height: 24, width: 24, color: Colors.grey),
                          ),
                          8.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data.parcelType.validate(), style: boldTextStyle()),
                              4.height,
                              Row(
                                children: [
                                  data.date != null ? Text(printDate(data.date ?? ''), style: secondaryTextStyle()).expand() : SizedBox(),
                                  Text('$currencySymbol ${data.totalAmount.validate()}', style: boldTextStyle()),
                                ],
                              ),
                            ],
                          ).expand(),
                        ],
                      ),
                      if (data.status == COURIER_DEPARTED) 8.height,
                      if (data.status == COURIER_DEPARTED)
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: colorPrimary),
                            8.width,
                            Text(language.track_order_location, style: primaryTextStyle(color: colorPrimary)).expand(),
                            AppButton(
                              padding: EdgeInsets.all(0),
                              text: language.track,
                              color: colorPrimary,
                              textStyle: boldTextStyle(color: Colors.white),
                              onTap: () async {
                                if (await checkPermission()) {
                                  TrackingScreen(order: orderData, latLng: LatLng(data.pickupPoint!.latitude.toDouble(), data.pickupPoint!.longitude.toDouble()))
                                      .launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                                }
                              },
                            ),
                          ],
                        )
                    ],
                  ),
                ),
                onTap: () {
                  OrderDetailScreen(orderId: data.id!).launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                },
              );
            },
          ),
          if (orderData.isEmpty) appStore.isLoading ? SizedBox() : emptyWidget(),
          loaderWidget().visible(appStore.isLoading)
        ],
      ),
    );
  }

  Future<void> onTapData({required String orderStatus, required OrderData orderData}) async {
    if (orderStatus == ORDER_ASSIGNED) {
      await updateOrder(orderStatus: ORDER_ACTIVE, orderId: orderData.id);
      init();
    } else if (orderStatus == ORDER_ACTIVE) {
      await ReceivedScreenOrderScreen(orderData: orderData).launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
      init();
    } else if (orderStatus == ORDER_ARRIVED) {
      bool isCheck = await ReceivedScreenOrderScreen(orderData: orderData).launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
      if (isCheck) {
        init();
      }
    } else if (orderStatus == ORDER_PICKED_UP) {
      await updateOrder(orderStatus: ORDER_DEPARTED, orderId: orderData.id);
      init();
    } else if (orderStatus == ORDER_DEPARTED) {
      await ReceivedScreenOrderScreen(orderData: orderData).launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
      init();
    }
  }

  buttonText(String orderStatus) {
    if (orderStatus == ORDER_ASSIGNED) {
      return language.active;
    } else if (orderStatus == ORDER_ACTIVE) {
      return language.pick_up;
    } else if (orderStatus == ORDER_ARRIVED) {
      return language.pick_up;
    } else if (orderStatus == ORDER_PICKED_UP) {
      return language.departed;
    } else if (orderStatus == ORDER_DEPARTED) {
      return language.submit;
    }
    return '';
  }
}
