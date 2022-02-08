import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class OrderDetailScreen extends StatefulWidget {
  static String tag = '/OrderDetailScreen';

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
      appBar: appBarWidget('Order Details',color: colorPrimary,textColor: white,elevation: 0),
      body:  BodyCornerWidget(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#8756346576',style: boldTextStyle()),
                  Text('Completed',style: boldTextStyle(color: statusColor('completed'))),
                ],
              ),
              8.height,
              Text('27 June 2022',style: secondaryTextStyle()),
              16.height,
              Text('Payment Method',style: secondaryTextStyle(size: 16)),
              8.height,
              Text('Cash on Delivery',style: boldTextStyle()),
              16.height,
              Text('Picked at 14 June 2020 at 3:45 AM',style: secondaryTextStyle(size: 16)),
              8.height,
              Text('467, Shubham Park, Navsari.',style: boldTextStyle()),
              16.height,
              Text('Delivered at 14 June 2020 at 3:45 AM',style: secondaryTextStyle(size: 16)),
              8.height,
              Text('467, Char rasta, Navsari.',style: boldTextStyle()),
              Divider(height: 30,thickness: 1),
              Text('Package details',style: boldTextStyle(size: 18)),
              16.height,
              Text('Parcel Type',style: secondaryTextStyle(size: 16)),
              8.height,
              Text('Documents',style: boldTextStyle()),
              16.height,
              Text('Total Weight',style: secondaryTextStyle(size: 16)),
              8.height,
              Text('5 Kg',style: boldTextStyle()),
              Divider(height: 30,thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Charges',style: primaryTextStyle()),
                  Text('\$10.00',style: boldTextStyle()),
                ],
              ),
              16.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Express Delivery',style: primaryTextStyle()),
                  Text('\$3.00',style: boldTextStyle()),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorPrimary,
          borderRadius: BorderRadius.circular(defaultRadius)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total',style: boldTextStyle(color: white)),
            Text('\$13.00',style: boldTextStyle(color: white)),
          ],
        ),
      ),
    );
  }
}
