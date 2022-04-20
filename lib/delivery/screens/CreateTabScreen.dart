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
import 'package:url_launcher/url_launcher.dart';

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
                  decoration: boxDecorationRoundedWithShadow(
                    defaultRadius.toInt(),
                    backgroundColor: context.cardColor,
                    shadowColor: appStore.isDarkMode ? Colors.transparent : null,
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('${language.order}# ${data.id}', style: boldTextStyle(size: 16)).expand(),
                          widget.orderStatus != ORDER_CANCELLED
                              ? AppButton(
                                  text: buttonText(widget.orderStatus!),
                                  padding: EdgeInsets.symmetric(vertical: 4,horizontal: 8),
                                  textStyle: boldTextStyle(color: Colors.white),
                                  color: colorPrimary,
                                  onTap: () {
                                    if (widget.orderStatus == ORDER_ACTIVE) {
                                      onTapData(orderData: data, orderStatus: widget.orderStatus!);
                                    } else if (widget.orderStatus == ORDER_ARRIVED) {
                                      onTapData(orderData: data, orderStatus: widget.orderStatus!);
                                    } else if (widget.orderStatus == ORDER_DEPARTED) {
                                      onTapData(orderData: data, orderStatus: widget.orderStatus!);
                                    } else {
                                      showConfirmDialogCustom(
                                        context,
                                        primaryColor: colorPrimary,
                                        dialogType: DialogType.CONFIRMATION,
                                        title: orderTitle(widget.orderStatus!),
                                        positiveText: language.yes,
                                        negativeText: language.no,
                                        onAccept: (c) async {
                                          appStore.setLoading(true);
                                          await onTapData(orderData: data, orderStatus: widget.orderStatus!);
                                          appStore.setLoading(false);
                                          finish(context);
                                        },
                                      );
                                    }
                                  },
                                ).visible(widget.orderStatus != ORDER_COMPLETED)
                              : SizedBox()
                        ],
                      ),
                      Divider(height: 30, thickness: 1),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (data.pickupDatetime != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(language.picked, style: boldTextStyle(size: 18)),
                                4.height,
                                Text('${language.at} ${printDate(data.pickupDatetime!)}', style: secondaryTextStyle()),
                                16.height,
                              ],
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(Icons.location_on, color: colorPrimary),
                                  Text('...', style: boldTextStyle(size: 20, color: colorPrimary)),
                                ],
                              ),
                              12.width,
                              Text('${data.pickupPoint!.address}', style: primaryTextStyle()).expand(),
                              12.width,
                              if (data.pickupPoint!.contactNumber != null)
                                Image.asset('assets/icons/ic_call.png', width: 24, height: 24).onTap(() {
                                  launch('tel:${data.pickupPoint!.contactNumber}');
                                }),
                            ],
                          ),
                          if (data.pickupDatetime == null && data.pickupPoint!.endTime != null && data.pickupPoint!.startTime != null)
                            Text('${language.note} ${language.courierWillPickupAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(data.pickupPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(data.pickupPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(data.pickupPoint!.endTime!).toLocal())}',
                                style: secondaryTextStyle())
                                .paddingOnly(top: 8),
                        ],
                      ),
                      Divider(height: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (data.deliveryDatetime != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(language.delivered, style: boldTextStyle(size: 18)),
                                4.height,
                                Text('${language.at} ${printDate(data.deliveryDatetime!)}', style: secondaryTextStyle()),
                                16.height,
                              ],
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('...', style: boldTextStyle(size: 20, color: colorPrimary)),
                                  Icon(Icons.location_on, color: colorPrimary),
                                ],
                              ),
                              12.width,
                              Text('${data.deliveryPoint!.address}', style: primaryTextStyle()).expand(),
                              12.width,
                              if (data.deliveryPoint!.contactNumber != null)
                                Image.asset('assets/icons/ic_call.png', width: 24, height: 24).onTap(() {
                                  launch('tel:${data.deliveryPoint!.contactNumber}');
                                }),
                            ],
                          ),
                          if (data.deliveryDatetime == null && data.deliveryPoint!.endTime != null && data.deliveryPoint!.startTime != null)
                            Text('${language.note} ${language.courierWillDeliverAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(data.deliveryPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(data.deliveryPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(data.deliveryPoint!.endTime!).toLocal())}',
                                style: secondaryTextStyle())
                                .paddingOnly(top: 8),
                        ],
                      ),
                      Divider(height: 30, thickness: 1),
                      Row(
                        children: [
                          Container(
                            decoration: boxDecorationWithRoundedCorners(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
                              backgroundColor: Colors.transparent,
                            ),
                            padding: EdgeInsets.all(8),
                            child: Image.asset(parcelTypeIcon(data.parcelType.validate()), height: 24, width: 24, color: Colors.grey),
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
                      if (data.status == COURIER_DEPARTED)
                        Align(
                            alignment: Alignment.topRight,
                            child: AppButton(
                              elevation: 0,
                              color: Colors.transparent,
                              padding: EdgeInsets.all(6),
                              shapeBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(defaultRadius),
                                side: BorderSide(color: colorPrimary),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(language.trackOrder, style: primaryTextStyle(color: colorPrimary)),
                                  Icon(Icons.arrow_right, color: colorPrimary),
                                ],
                              ),
                              onTap: () async {
                                if (await checkPermission()) {
                                  TrackingScreen(order: orderData, latLng: LatLng(data.pickupPoint!.latitude.toDouble(), data.pickupPoint!.longitude.toDouble()))
                                      .launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                                }
                              },
                            )).paddingOnly(top: 12),
                      Align(
                        alignment: Alignment.topRight,
                        child: AppButton(
                          elevation: 0,
                          color: Colors.transparent,
                          padding: EdgeInsets.all(6),
                          shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(defaultRadius),
                            side: BorderSide(color: colorPrimary),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(language.notifyUser, style: primaryTextStyle(color: colorPrimary)),
                              Icon(Icons.arrow_right, color: colorPrimary),
                            ],
                          ),
                          onTap: () {
                            showConfirmDialogCustom(
                              context,
                              primaryColor: colorPrimary,
                              dialogType: DialogType.CONFIRMATION,
                              title: language.areYouSureWantToArrive,
                              positiveText: language.yes,
                              negativeText: language.cancel,
                              onAccept: (c) async {
                                appStore.setLoading(true);
                                await updateOrder(orderStatus: ORDER_ARRIVED, orderId: data.id);
                                appStore.setLoading(false);
                                finish(context);

                                init();
                              },
                            );
                          },
                        ),
                      ).paddingOnly(top: 12).visible(data.status == ORDER_ACTIVE),
                    ],
                  ),
                ),
                onTap: () {
                  OrderDetailScreen(orderId: data.id!).launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop, duration: 400.milliseconds);
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
      await ReceivedScreenOrderScreen(orderData: orderData, isShowPayment: orderData.paymentId == null && orderData.paymentCollectFrom == PAYMENT_ON_PICKUP).launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
      init();
    } else if (orderStatus == ORDER_ARRIVED) {
      bool isCheck = await ReceivedScreenOrderScreen(orderData: orderData, isShowPayment: orderData.paymentId == null && orderData.paymentCollectFrom == PAYMENT_ON_PICKUP)
          .launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
      if (isCheck) {
        init();
      }
    } else if (orderStatus == ORDER_PICKED_UP) {
      await updateOrder(orderStatus: ORDER_DEPARTED, orderId: orderData.id);
      init();
    } else if (orderStatus == ORDER_DEPARTED) {
      await ReceivedScreenOrderScreen(orderData: orderData, isShowPayment: orderData.paymentId == null && orderData.paymentCollectFrom == PAYMENT_ON_DELIVERY).launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
      init();
    }
  }

  buttonText(String orderStatus) {
    if (orderStatus == ORDER_ASSIGNED) {
      return language.active;
    } else if (orderStatus == ORDER_ACTIVE) {
      return language.pickUp;
    } else if (orderStatus == ORDER_ARRIVED) {
      return language.pickUp;
    } else if (orderStatus == ORDER_PICKED_UP) {
      return language.departed;
    } else if (orderStatus == ORDER_DEPARTED) {
      return language.confirmDelivery;
    }
    return '';
  }
}
