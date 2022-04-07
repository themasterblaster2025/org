import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/user/screens/OrderTrackingScreen.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/user/screens/OrderDetailScreen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderFragment extends StatefulWidget {
  static String tag = '/OrderFragment';

  @override
  OrderFragmentState createState() => OrderFragmentState();
}

class OrderFragmentState extends State<OrderFragment> {
  List<OrderData> orderList = [];
  ScrollController scrollController = ScrollController();
  int page = 1;
  int totalPage = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !appStore.isLoading) {
        if (page < totalPage) {
          page++;
          init();
        }
      }
    });
    LiveStream().on('UpdateOrderData', (p0) {
      page = 1;
      getOrderListApiCall();
      setState(() {});
    });
  }

  Future<void> init() async {
    afterBuildCreated(() {
      getOrderListApiCall();
    });
  }

  getOrderListApiCall() async {
    appStore.setLoading(true);
    FilterAttributeModel filterData = FilterAttributeModel.fromJson(getJSONAsync(FILTER_DATA));
    await getOrderList(page: page, orderStatus: filterData.orderStatus, fromDate: filterData.fromDate, toDate: filterData.toDate).then((value) {
      appStore.setLoading(false);
      appStore.setAllUnreadCount(value.allUnreadCount.validate());
      totalPage = value.pagination!.totalPages.validate(value: 1);
      page = value.pagination!.currentPage.validate(value: 1);
      isLastPage = false;
      if (page == 1) {
        orderList.clear();
      }
      orderList.addAll(value.data!);
      setState(() {});
    }).catchError((e) {
      isLastPage = true;
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(Duration(milliseconds: 1500));
        page = 1;
        init();
      },
      child: Observer(builder: (context) {
        return Stack(
          children: [
            orderList.isNotEmpty
                ? ListView(
                    shrinkWrap: true,
                    controller: scrollController,
                    padding: EdgeInsets.all(16),
                    children: orderList.map((item) {
                      return item.status != ORDER_DRAFT
                          ? GestureDetector(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 16),
                                decoration: appStore.isDarkMode
                                    ? boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(defaultRadius), backgroundColor: context.cardColor)
                                    : boxDecorationRoundedWithShadow(defaultRadius.toInt()),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // TODO Localization
                                        Text('${language.order}# ${item.id}', style: secondaryTextStyle(size: 16)).expand(),
                                        Container(
                                          decoration: BoxDecoration(color: statusColor(item.status.validate()).withOpacity(0.15), borderRadius: BorderRadius.circular(defaultRadius)),
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: Text(item.status!.replaceAll("_", " ").capitalizeFirstLetter(), style: boldTextStyle(color: statusColor(item.status.validate()))),
                                        ),
                                      ],
                                    ),
                                    8.height,
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: boxDecorationWithRoundedCorners(
                                              borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1), backgroundColor: Colors.transparent),
                                          padding: EdgeInsets.all(8),
                                          child: Image.asset(parcelTypeIcon(item.parcelType.validate()), height: 24, width: 24, color: Colors.grey),
                                        ),
                                        8.width,
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.parcelType.validate(), style: boldTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            4.height,
                                            Row(
                                              children: [
                                                item.date != null ? Text(printDate(item.date!), style: secondaryTextStyle()).expand() : SizedBox(),
                                                Text('$currencySymbol ${item.totalAmount}', style: boldTextStyle()),
                                              ],
                                            ),
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
                                            if (item.pickupDatetime != null) Text('${language.pickedAt} ${printDate(item.pickupDatetime!)}', style: secondaryTextStyle()).paddingOnly(bottom: 8),
                                            Text('${item.pickupPoint!.address}', style: primaryTextStyle()),
                                            if (item.pickupPoint!.contactNumber != null)
                                              Row(
                                                children: [
                                                  Icon(Icons.call, color: Colors.green, size: 18).onTap(() {
                                                    launch('tel:${item.pickupPoint!.contactNumber}');
                                                  }),
                                                  8.width,
                                                  Text('${item.pickupPoint!.contactNumber}', style: primaryTextStyle()),
                                                ],
                                              ).paddingOnly(top: 8),
                                            if (item.pickupDatetime == null && item.pickupPoint!.endTime != null && item.pickupPoint!.startTime != null)
                                              Text('${language.note} ${language.courierWillPickupAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(item.pickupPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(item.pickupPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(item.pickupPoint!.endTime!).toLocal())}',
                                                      style: secondaryTextStyle())
                                                  .paddingOnly(top: 8),
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
                                            if (item.deliveryDatetime != null) Text('${language.deliveredAt} ${printDate(item.deliveryDatetime!)}', style: secondaryTextStyle()).paddingOnly(bottom: 8),
                                            Text('${item.deliveryPoint!.address}', style: primaryTextStyle()),
                                            if (item.deliveryPoint!.contactNumber != null)
                                              Row(
                                                children: [
                                                  Icon(Icons.call, color: Colors.green, size: 18).onTap(() {
                                                    launch('tel:${item.deliveryPoint!.contactNumber}');
                                                  }),
                                                  8.width,
                                                  Text('${item.deliveryPoint!.contactNumber ?? ""}', style: primaryTextStyle()),
                                                ],
                                              ).paddingOnly(top: 8),
                                            if (item.deliveryDatetime == null && item.deliveryPoint!.endTime != null && item.deliveryPoint!.startTime != null)
                                              Text('${language.note} ${language.courierWillDeliverAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(item.deliveryPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(item.deliveryPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(item.deliveryPoint!.endTime!).toLocal())}',
                                                      style: secondaryTextStyle())
                                                  .paddingOnly(top: 8),
                                          ],
                                        ).expand(),
                                      ],
                                    ),
                                    16.height,
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: AppButton(
                                        elevation: 0,
                                        width: 135,
                                        height: 35,
                                        color: Colors.transparent,
                                        padding: EdgeInsets.zero,
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
                                        onTap: () {
                                          OrderTrackingScreen(orderData: item).launch(context);
                                        },
                                      ).visible(item.status == ORDER_DEPARTED || item.status == ORDER_ARRIVED),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () {
                                OrderDetailScreen(orderId: item.id.validate()).launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                              },
                            )
                          : SizedBox();
                    }).toList(),
                  )
                : !appStore.isLoading
                    ? emptyWidget()
                    : SizedBox(),
            loaderWidget().center().visible(appStore.isLoading)
          ],
        );
      }),
    );
  }
}
