import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderBottomSheetWidget extends StatefulWidget {
  final OrderData? orderData;

  OrderBottomSheetWidget({this.orderData});

  @override
  OrderBottomSheetWidgetState createState() => OrderBottomSheetWidgetState();
}

class OrderBottomSheetWidgetState extends State<OrderBottomSheetWidget> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('-: PicUp Point :-', style: boldTextStyle(decoration: TextDecoration.underline, color: colorPrimary)).center(),
        16.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.schedule_outlined, color: colorPrimary, size: 20),
            Text('11/01/2022 07:38 PM', style: secondaryTextStyle(), textAlign: TextAlign.right),
          ],
        ),
        16.height,
        Row(
          children: [
            Icon(Icons.call_outlined, color: colorPrimary, size: 20).onTap(() {
              launch('tel://8320951437');
            }),
            16.width,
            Text('Contact number', style: primaryTextStyle()).expand(),
            Text('8320941437', style: secondaryTextStyle()),
          ],
        ),
        16.height,
        Row(
          children: [
            Icon(Icons.payment_outlined, color: colorPrimary, size: 20),
            16.width,
            Text('Payment type', style: primaryTextStyle()).expand(),
            Text('Cash On Delivery', style: secondaryTextStyle()),
          ],
        ),
        16.height,
        Row(
          children: [
            Icon(Icons.home_outlined, color: colorPrimary, size: 20),
            16.width,
            Text(widget.orderData!.pickupPoint!.address ?? '-', style: secondaryTextStyle()).expand(),
          ],
        ),
        16.height,
        Row(
          children: [
            Icon(Icons.description_outlined, color: colorPrimary, size: 20),
            16.width,
            Text(widget.orderData!.deliveryPoint!.address ?? '-', style: secondaryTextStyle()).expand(),
          ],
        ),
        16.height,
        Container(
          decoration: boxDecorationWithShadow(borderRadius: radius(), backgroundColor: colorPrimary),
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: boldTextStyle(color: white)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('140', style: secondaryTextStyle(color: white)),
                  4.height,
                  Text('All charge Include', style: secondaryTextStyle(size: 10, color: white)),
                ],
              ),
            ],
          ),
        )
      ],
    ).paddingAll(16);
  }
}
