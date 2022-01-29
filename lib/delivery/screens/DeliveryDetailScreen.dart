import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class DeliveryDetailScreen extends StatefulWidget {
  @override
  DeliveryDetailScreenState createState() => DeliveryDetailScreenState();
}

class DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
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
    return Scaffold(
      body: Stack(
        children: [
          customAppBarWidget(context, 'Delivery Detail', isShowBack: true),
          containerWidget(
            context,
            SingleChildScrollView(
              padding: EdgeInsets.only(left: 16, top: 30, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('#561465465578', style: boldTextStyle()),
                      Text('Delivered', style: boldTextStyle(color: colorPrimary)),
                    ],
                  ),
                  4.height,
                  Text('27 May, 2020', style: primaryTextStyle()),
                  16.height,
                  Text('Delivered to', style: primaryTextStyle()),
                  8.height,
                  Text('1633 Hamptom Meadows, Lexington', style: boldTextStyle()),
                  16.height,
                  Text('Payment Method', style: primaryTextStyle()),
                  8.height,
                  Text('Apple pay', style: boldTextStyle()),
                  16.height,
                  Divider(color: Colors.grey),
                  16.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Item Total', style: primaryTextStyle()),
                      Text('\$ 23.08', style: boldTextStyle()),
                    ],
                  ),
                  16.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Delivery Items', style: primaryTextStyle()),
                      Text('\$ 2.00', style: boldTextStyle()),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
