import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/delivery/screens/DeliveryDetailScreen.dart';
import 'package:mighty_delivery/delivery/screens/ReceivedScreenOrderScreen.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
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

  bool mIsLastPage = false;
  List<OrderData> orderData = [];

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (!mIsLastPage) {
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

      mIsLastPage = value.data!.length != value.pagination!.per_page!;

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

                                  /// Send notification
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
                              Text('Picked at 4:45', style: secondaryTextStyle()),
                              4.height,
                              Text(data.pickupPoint!.address.validate(), style: primaryTextStyle()),
                              4.height,
                              Row(
                                children: [
                                  Icon(Icons.call, color: Colors.green, size: 18),
                                  8.width,
                                  Text(data.pickupPoint!.contactNumber.validate(), style: primaryTextStyle()),
                                ],
                              ),
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
                              Text('Delivered at 4:53', style: secondaryTextStyle()),
                              4.height,
                              Text(data.deliveryPoint!.address.validate(), style: primaryTextStyle()),
                              4.height,
                              Row(
                                children: [
                                  Icon(Icons.call, color: Colors.green, size: 18),
                                  8.width,
                                  Text(data.deliveryPoint!.contactNumber.validate(), style: primaryTextStyle()),
                                ],
                              ),
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
                            child: Image.network(parcelTypeIcon('document'), height: 24, width: 24, color: Colors.grey),
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
                    ],
                  ),
                ),
                onTap: () {
                  DeliveryDetailScreen().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                },
              );
            },
          ),
          if (orderData.isEmpty) appStore.isLoading ? SizedBox() : emptyWidget(),
          Loader().visible(appStore.isLoading)
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
      return 'Active';
    } else if (orderStatus == ORDER_ACTIVE) {
      return 'Pick Up';
    } else if (orderStatus == ORDER_ARRIVED) {
      return 'Pick Up';
    } else if (orderStatus == ORDER_PICKED_UP) {
      return 'Departed';
    } else if (orderStatus == ORDER_DEPARTED) {
      return 'Submit';
    }
    return '';
  }
}
