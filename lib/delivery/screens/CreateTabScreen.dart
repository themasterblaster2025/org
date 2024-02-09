import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../delivery/screens/ReceivedScreenOrderScreen.dart';
import '../../delivery/screens/TrackingScreen.dart';
import '../../main.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Images.dart';
import '../../user/screens/OrderDetailScreen.dart';

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
    await getOrderListApiCall();
  }

  getOrderListApiCall() async {
    appStore.setLoading(true);
    await getDeliveryBoyOrderList(page: currentPage, deliveryBoyID: getIntAsync(USER_ID), cityId: getIntAsync(CITY_ID), countryId: getIntAsync(COUNTRY_ID), orderStatus: widget.orderStatus!)
        .then((value) {
      appStore.setAllUnreadCount(value.allUnreadCount.validate());

      currentPage = value.pagination!.currentPage!;
      totalPage = value.pagination!.totalPages!;

      if (currentPage == 1) {
        orderData.clear();
      }
      orderData.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      log(error);
    }).whenComplete(() {
      appStore.setLoading(false);
    });
  }

  Future<void> cancelOrder(OrderData order) async {
    appStore.setLoading(true);
    List<dynamic> cancelledDeliverManIds = order.cancelledDeliverManIds ?? [];
    cancelledDeliverManIds.add(getIntAsync(USER_ID));
    Map req = {
      "id": order.id,
      "cancelled_delivery_man_ids": cancelledDeliverManIds,
    };
    await cancelAutoAssignOrder(req).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      init();
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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedListView(
          itemCount: orderData.length,
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          listAnimationType: ListAnimationType.Slide,
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 60),
          flipConfiguration: FlipConfiguration(duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn),
          fadeInConfiguration: FadeInConfiguration(duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn),
          onNextPage: () {
            if (currentPage < totalPage) {
              currentPage++;
              setState(() {});
              init();
            }
          },
          emptyWidget: Stack(
            children: [
              loaderWidget().visible(appStore.isLoading),
              emptyWidget().visible(!appStore.isLoading),
            ],
          ),
          onPageScrollChange: () {
            appStore.setLoading(true);
          },
          onSwipeRefresh: () async {
            currentPage = 1;
            await getAppSetting().then((value) {
              appStore.setOtpVerifyOnPickupDelivery(value.otpVerifyOnPickupDelivery == 1);
              appStore.setCurrencyCode(value.currencyCode ?? currencyCode);
              appStore.setCurrencySymbol(value.currency ?? currencySymbol);
              appStore.setCurrencyPosition(value.currencyPosition ?? CURRENCY_POSITION_LEFT);
              appStore.isVehicleOrder = value.isVehicleInOrder ?? 0;
            }).catchError((error) {
              log(error.toString());
            });
            init();
            return Future.value(true);
          },
          itemBuilder: (context, i) {
            OrderData item = orderData[i];
            return item.status != ORDER_DRAFT ? orderCard(item) : SizedBox();
          },
        ),
        Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
      ],
    );
  }

  Widget orderCard(OrderData data) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(defaultRadius), border: Border.all(color: colorPrimary.withOpacity(0.3)), backgroundColor: Colors.transparent),
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${language.order}# ${data.id}', style: boldTextStyle(size: 16)).expand(),
                AppButton(
                  margin: EdgeInsets.only(right: 10),
                  elevation: 0,
                  text: language.cancel,
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  textStyle: boldTextStyle(color: Colors.red),
                  color: Colors.red.withOpacity(0.2),
                  onTap: () {
                    showConfirmDialogCustom(
                      context,
                      primaryColor: Colors.red,
                      dialogType: DialogType.CONFIRMATION,
                      title: language.orderCancelConfirmation,
                      positiveText: language.yes,
                      negativeText: language.no,
                      onAccept: (c) async {
                        await cancelOrder(data);
                      },
                    );
                  },
                ).visible(data.autoAssign == 1 && data.status == ORDER_ASSIGNED),
                widget.orderStatus != ORDER_CANCELLED
                    ? AppButton(
                        elevation: 0,
                        text: buttonText(widget.orderStatus!),
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        textStyle: boldTextStyle(color: Colors.white),
                        color: colorPrimary,
                        onTap: () {
                          if (widget.orderStatus == ORDER_ACCEPTED) {
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
                      ).visible(widget.orderStatus != ORDER_DELIVERED)
                    : SizedBox()
              ],
            ),
            8.height,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.pickupDatetime != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(language.picked, style: secondaryTextStyle(size: 12)),
                      4.height,
                      Text('${language.at} ${printDate(data.pickupDatetime!)}', style: secondaryTextStyle(size: 12)),
                    ],
                  ),
                4.height,
                Row(
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            openMap(double.parse(data.pickupPoint!.longitude.validate()), double.parse(data.pickupPoint!.longitude.validate()));
                          },
                          child: Row(
                            children: [
                              ImageIcon(AssetImage(ic_from), size: 24, color: colorPrimary),
                              12.width,
                              Text('${data.pickupPoint!.address}', style: primaryTextStyle()).expand(),
                            ],
                          ),
                        ),
                      ],
                    ).expand(),
                    12.width,
                    if (data.pickupPoint!.contactNumber != null)
                      Icon(Ionicons.ios_call_outline, size: 20, color: colorPrimary).onTap(() {
                        commonLaunchUrl('tel:${data.pickupPoint!.contactNumber}');
                      }),
                  ],
                ),
                if (data.pickupDatetime == null && data.pickupPoint!.endTime != null && data.pickupPoint!.startTime != null)
                  Text('${language.note} ${language.courierWillPickupAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(data.pickupPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(data.pickupPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(data.pickupPoint!.endTime!).toLocal())}',
                          style: secondaryTextStyle(size: 12, color: Colors.red))
                      .paddingOnly(top: 4)
                      .expand(),
              ],
            ),
            16.height,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.deliveryDatetime != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(language.delivered, style: secondaryTextStyle(size: 12)),
                      4.height,
                      Text('${language.at} ${printDate(data.deliveryDatetime!)}', style: secondaryTextStyle(size: 12)),
                    ],
                  ),
                4.height,
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        openMap(double.parse(data.deliveryPoint!.longitude.validate()), double.parse(data.deliveryPoint!.longitude.validate()));
                      },
                      child: Row(
                        children: [
                          ImageIcon(AssetImage(ic_to), size: 24, color: colorPrimary),
                          12.width,
                          Text('${data.deliveryPoint!.address}', style: primaryTextStyle(), textAlign: TextAlign.start).expand(),
                        ],
                      ),
                    ).expand(),
                    12.width,
                    if (data.deliveryPoint!.contactNumber != null)
                      Icon(Ionicons.ios_call_outline, size: 20, color: colorPrimary).onTap(() {
                        commonLaunchUrl('tel:${data.deliveryPoint!.contactNumber}');
                      }),
                  ],
                ),
                if (data.deliveryDatetime == null && data.deliveryPoint!.endTime != null && data.deliveryPoint!.startTime != null)
                  Text('${language.note} ${language.courierWillDeliverAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(data.deliveryPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(data.deliveryPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(data.deliveryPoint!.endTime!).toLocal())}',
                          style: secondaryTextStyle(color: Colors.red, size: 12))
                      .paddingOnly(top: 4)
                      .expand()
              ],
            ),
            Divider(height: 30, thickness: 1, color: context.dividerColor),
            Row(
              children: [
                Container(
                  decoration: boxDecorationWithRoundedCorners(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
                    backgroundColor: context.cardColor,
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
                        Text('${printAmount(data.totalAmount)}', style: boldTextStyle()),
                      ],
                    ),
                  ],
                ).expand(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: AppButton(
                    elevation: 0,
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultRadius),
                      side: BorderSide(color: colorPrimary),
                    ),
                    child: Text(language.notifyUser, style: primaryTextStyle(color: colorPrimary)),
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
                          await updateOrder(orderStatus: ORDER_ARRIVED, orderId: data.id).then((value) {
                            toast(language.orderArrived);
                          });
                          appStore.setLoading(false);
                          finish(context);
                          init();
                        },
                      );
                    },
                  ),
                ).paddingOnly(top: 12, right: 16).visible(data.status == ORDER_ACCEPTED),
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
                          TrackingScreen(
                                  orderId: data.id,
                                  order: orderData,
                                  latLng: data.status == ORDER_ACCEPTED
                                      ? LatLng(data.pickupPoint!.latitude.toDouble(), data.pickupPoint!.longitude.toDouble())
                                      : LatLng(data.deliveryPoint!.latitude.toDouble(), data.deliveryPoint!.longitude.toDouble()))
                              .launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                        }
                      },
                    )).paddingOnly(top: 12).visible(data.status == ORDER_DEPARTED || data.status == ORDER_ACCEPTED),
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        OrderDetailScreen(orderId: data.id!).launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop, duration: 400.milliseconds);
      },
    );
  }

  Future<void> onTapData({required String orderStatus, required OrderData orderData}) async {
    if (orderStatus == ORDER_ASSIGNED) {
      await updateOrder(orderStatus: ORDER_ACCEPTED, orderId: orderData.id).then((value) {
        toast(language.orderActiveSuccessfully);
      });
      init();
    } else if (orderStatus == ORDER_ACCEPTED) {
      await ReceivedScreenOrderScreen(orderData: orderData, isShowPayment: orderData.paymentId == null && orderData.paymentCollectFrom == PAYMENT_ON_PICKUP)
          .launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
      init();
    } else if (orderStatus == ORDER_ARRIVED) {
      bool isCheck = await ReceivedScreenOrderScreen(orderData: orderData, isShowPayment: orderData.paymentId == null && orderData.paymentCollectFrom == PAYMENT_ON_PICKUP)
          .launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
      if (isCheck) {
        init();
      }
    } else if (orderStatus == ORDER_PICKED_UP) {
      await updateOrder(orderStatus: ORDER_DEPARTED, orderId: orderData.id).then((value) {
        toast(language.orderDepartedSuccessfully);
      });
      init();
    } else if (orderStatus == ORDER_DEPARTED) {
      await ReceivedScreenOrderScreen(orderData: orderData, isShowPayment: orderData.paymentId == null && orderData.paymentCollectFrom == PAYMENT_ON_DELIVERY)
          .launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
      init();
    }
  }

  buttonText(String orderStatus) {
    if (orderStatus == ORDER_ASSIGNED) {
      return language.active;
    } else if (orderStatus == ORDER_ACCEPTED) {
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
