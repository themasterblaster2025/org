import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/user/screens/OrderDetailScreen.dart';
import 'package:nb_utils/nb_utils.dart';

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
  }

  Future<void> init() async {
    getOrderListApiCall();
  }

  getOrderListApiCall() async {
    appStore.setLoading(true);
    await getOrderList(page:page).then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages.validate(value: 1);
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
    return Stack(
      children: [
        ListView(
          shrinkWrap: true,
          controller: scrollController,
          padding: EdgeInsets.all(16),
          children: orderList.map((item) {
            return GestureDetector(
              child: Container(
                margin: EdgeInsets.only(bottom: 16),
                decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt()),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('#${item.id}', style: secondaryTextStyle(size: 16)).expand(),
                        Container(
                          decoration: BoxDecoration(color: statusColor(item.status.validate()), borderRadius: BorderRadius.circular(defaultRadius)),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(item.status.validate(value: "draft"), style: primaryTextStyle(color: white)),
                        ),
                      ],
                    ),
                    8.height,
                    Row(
                      children: [
                          Container(
                          decoration: boxDecorationWithRoundedCorners(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Image.network(parcelTypeIcon(item.parcelType.validate()), height: 24, width: 24, color: Colors.grey),
                        ),
                        8.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.parcelType.validate(), style: boldTextStyle()),
                            4.height,
                            Row(
                              children: [
                                item.date != null ? Text(printDate(item.date!), style: secondaryTextStyle()).expand() : SizedBox(),
                                Text('\u{20B9}${item.totalAmount}', style: boldTextStyle()),
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
                            Text('Picked at 4:45', style: secondaryTextStyle()),
                            4.height,
                            Text('${item.pickupPoint!.address}', style: primaryTextStyle()),
                            4.height.visible(item.pickupPoint!.contactNumber!=null),
                            Row(
                              children: [
                                Icon(Icons.call,color: Colors.green,size: 18),
                                8.width,
                                Text('${item.pickupPoint!.contactNumber ?? ""}', style: primaryTextStyle()),
                              ],
                            ).visible(item.pickupPoint!.contactNumber!=null),
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
                            Text('${item.deliveryPoint!.address}', style: primaryTextStyle()),
                            4.height.visible(item.deliveryPoint!.contactNumber!=null),
                            Row(
                              children: [
                                Icon(Icons.call,color: Colors.green,size: 18),
                                8.width,
                                Text('${item.deliveryPoint!.contactNumber ?? ""}', style: primaryTextStyle()),
                              ],
                            ).visible(item.deliveryPoint!.contactNumber!=null),
                          ],
                        ).expand(),
                      ],
                    ),
                  ],
                ),
              ),
              onTap: () {
                OrderDetailScreen(orderData: item).launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
              },
            );
            /*return Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt()),
              padding: EdgeInsets.all(16),
              child: OpenContainer<bool>(openElevation: 0,
                openColor: Colors.transparent,
                closedElevation: 0,
                transitionType: ContainerTransitionType.fadeThrough,
                transitionDuration :  Duration(milliseconds: 800),
                openBuilder: (BuildContext context, VoidCallback _) {
                  return OrderDetailScreen();
                },
                onClosed: (data) {},
                closedBuilder: (context, action) {
                  return OrderComponent();
                },
              ),
            );*/
          }).toList(),
        ),
        Observer(builder: (context) {
          return Loader().center().visible(appStore.isLoading);
        }),
      ],
    );
  }
}
