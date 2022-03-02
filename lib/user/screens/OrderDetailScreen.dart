import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeline_tile/timeline_tile.dart';

import 'TrackOrderScreen.dart';

class OrderDetailScreen extends StatefulWidget {
  static String tag = '/OrderDetailScreen';

  final OrderData orderData;

  OrderDetailScreen({required this.orderData});

  @override
  OrderDetailScreenState createState() => OrderDetailScreenState();
}

class OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('Order Details', color: colorPrimary, textColor: white, elevation: 0),
      body: BodyCornerWidget(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#${widget.orderData.id}', style: boldTextStyle()),
                  Text('${widget.orderData.status}', style: boldTextStyle(color: statusColor(widget.orderData.status ?? ""))),
                ],
              ),
              8.height,
              Text(DateFormat('dd MMM yyyy').format(DateTime.parse(widget.orderData.date!)), style: secondaryTextStyle()),
              16.height,
              Text('Payment Method', style: secondaryTextStyle(size: 16)),
              8.height,
              Text('Cash on Delivery', style: boldTextStyle()),
              Row(
                children: [
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
                            Text('Picked at 14 June 2020 at 3:45 AM', style: secondaryTextStyle(size: 16)),
                            8.height,
                            Text('${widget.orderData.pickupPoint!.address}', style: boldTextStyle()),
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
                            Text('Delivered at 14 June 2020 at 3:45 AM', style: secondaryTextStyle(size: 16)),
                            8.height,
                            Text('${widget.orderData.deliveryPoint!.address}', style: boldTextStyle()),
                          ],
                        ).paddingAll(16),
                      ),
                    ],
                  ).expand(),
                  Icon(
                    Icons.navigate_next,
                    color: Colors.grey,
                  ).onTap(() {
                    TrackOrderScreen().launch(context);
                    /*final List<TimelineModel> list = [
                      TimelineModel(
                          id: "1",
                          description: "World Best Website",
                          lineColor: Colors.yellow,
                          descriptionColor: Colors.green,
                          titleColor: Colors.green,
                          title: "Flutter"),
                      TimelineModel(
                          id: "2",
                          lineColor: Colors.red,
                          description: "Flutter Interview Question \nTop 10 display",
                          title: "Flutter Interview Question"),
                      TimelineModel(
                          id: "3",
                          description: "Every pattern avialble in \nwww.fluttertutorial.in",
                          lineColor: Colors.black,
                          title: "Flutter")
                    ];
                    TimelineComponent(timelineList: list).launch(context);*/
                  }),
                ],
              ),
              Divider(height: 30, thickness: 1),
              Text('Package details', style: boldTextStyle(size: 18)),
              16.height,
              Text('Parcel Type', style: secondaryTextStyle(size: 16)),
              8.height,
              Text('${widget.orderData.parcelType}', style: boldTextStyle()),
              16.height,
              Text('Total Weight', style: secondaryTextStyle(size: 16)),
              8.height,
              Text('${widget.orderData.totalWeight} Kg', style: boldTextStyle()),
              Divider(height: 30, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Charges', style: primaryTextStyle()),
                  Text('\$10.00', style: boldTextStyle()),
                ],
              ),
              16.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Express Delivery', style: primaryTextStyle()),
                  Text('\$3.00', style: boldTextStyle()),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: colorPrimary, borderRadius: BorderRadius.circular(defaultRadius)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: boldTextStyle(color: white)),
            Text('\$13.00', style: boldTextStyle(color: white)),
          ],
        ),
      ).paddingAll(16),
    );
  }
}
