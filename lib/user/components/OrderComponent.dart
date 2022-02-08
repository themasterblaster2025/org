import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';

class OrderComponent extends StatefulWidget {
  static String tag = '/OrderComponent';

  @override
  OrderComponentState createState() => OrderComponentState();
}

class OrderComponentState extends State<OrderComponent> {
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
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt()),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text('#643468383', style: secondaryTextStyle(size: 16)).expand(),
              Container(
                decoration: BoxDecoration(color: statusColor('completed'), borderRadius: BorderRadius.circular(defaultRadius)),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Completed', style: primaryTextStyle(color: white)),
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
                child:Image.network(parcelTypeIcon('documents'),height: 24,width: 24,color: Colors.grey),
              ),
              8.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Documents', style: boldTextStyle()),
                  4.height,
                  Row(
                    children: [
                      Text('14 June 2020 at 3:45 PM', style: secondaryTextStyle()).expand(),
                      Text('\$34.00', style: boldTextStyle()),
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
                  Text('Address , City, Gujarat.', style: primaryTextStyle(), maxLines: 1),
                ],
              ),
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
                  Text('Address', style: primaryTextStyle(), maxLines: 1),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
