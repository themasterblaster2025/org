import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/user/screens/CreateOrderScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';

class DraftOrderListScreen extends StatefulWidget {
  static String tag = '/DraftOrderListScreen';

  @override
  DraftOrderListScreenState createState() => DraftOrderListScreenState();
}

class DraftOrderListScreenState extends State<DraftOrderListScreen> {
  List<OrderData> orderList = [];
  ScrollController scrollController = ScrollController();
  int page = 1;
  int totalPage = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    getOrderListApiCall();
  }

  getOrderListApiCall() async {
    appStore.setLoading(true);
    await getOrderList(page: page, orderStatus: ORDER_DRAFT).then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages!;
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

  deleteOrderApiCall(int id) async {
    appStore.setLoading(true);
    await deleteOrder(id).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      getOrderListApiCall();
      setState(() {});
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
    return Scaffold(
      appBar: appBarWidget(language.draft_order, color: colorPrimary, textColor: white, elevation: 0),
      body: BodyCornerWidget(
        child: Observer(builder: (context) {
          return Stack(
            children: [
              orderList.isNotEmpty
                  ? ListView(
                      shrinkWrap: true,
                      controller: scrollController,
                      padding: EdgeInsets.all(16),
                      children: orderList.map((item) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt()),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('#${item.id}', style: secondaryTextStyle(size: 16)).paddingOnly(left: 16),
                                  Container(
                                    child: Icon(Icons.delete_outline, color: Colors.red),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.4),
                                      borderRadius: BorderRadius.only(topRight: Radius.circular(defaultRadius), bottomLeft: Radius.circular(defaultRadius)),
                                    ),
                                  ).onTap(() {
                                    showConfirmDialogCustom(
                                      context,
                                      dialogType: DialogType.DELETE,
                                      onAccept: (p0) {
                                        deleteOrderApiCall(item.id!.toInt());
                                      },
                                    );
                                  }),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    item.paymentType != null
                                        ? Row(
                                            children: [
                                              Container(
                                                decoration: boxDecorationWithRoundedCorners(
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: borderColor),
                                                ),
                                                padding: EdgeInsets.all(8),
                                                child: Image.asset(parcelTypeIcon(item.parcelType.validate()), height: 24, width: 24, color: Colors.grey),
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
                                                      Text('$currencySymbol ${item.totalAmount}', style: boldTextStyle()),
                                                    ],
                                                  ),
                                                ],
                                              ).expand(),
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              item.date != null ? Text(printDate(item.date!), style: secondaryTextStyle()).expand() : SizedBox(),
                                              Text('$currencySymbol ${item.totalAmount}', style: boldTextStyle()),
                                            ],
                                          ),
                                    if (item.pickupPoint!.address != null || item.deliveryPoint!.address != null)
                                      Column(
                                        children: [
                                          Divider(height: 30, thickness: 1),
                                          if(item.pickupPoint!.address != null) Row(
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
                                                  Text('${item.pickupPoint!.address}', style: primaryTextStyle()),
                                                  4.height.visible(item.pickupPoint!.contactNumber != null),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.call, color: Colors.green, size: 18),
                                                      8.width,
                                                      Text('${item.pickupPoint!.contactNumber ?? ""}', style: primaryTextStyle()),
                                                    ],
                                                  ).visible(item.pickupPoint!.contactNumber != null),
                                                ],
                                              ).expand(),
                                            ],
                                          ),
                                          16.height,
                                          if(item.deliveryPoint!.address != null) Row(
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
                                                  Text('${item.deliveryPoint!.address}', style: primaryTextStyle()),
                                                  4.height.visible(item.deliveryPoint!.contactNumber != null),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.call, color: Colors.green, size: 18),
                                                      8.width,
                                                      Text('${item.deliveryPoint!.contactNumber ?? ""}', style: primaryTextStyle()),
                                                    ],
                                                  ).visible(item.deliveryPoint!.contactNumber != null),
                                                ],
                                              ).expand(),
                                            ],
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).onTap(() {
                          CreateOrderScreen(orderData: item).launch(context);
                        });
                      }).toList(),
                    )
                  : !appStore.isLoading
                      ? emptyWidget()
                      : SizedBox(),
              loaderWidget().center().visible(appStore.isLoading),
            ],
          );
        }),
      ),
    );
  }
}
