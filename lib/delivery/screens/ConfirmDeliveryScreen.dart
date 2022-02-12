import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:mighty_delivery/delivery/components/NewOrderWidget.dart';
import 'package:mighty_delivery/delivery/screens/ReceivedScreenOrderScreen.dart';

class ConfirmDeliveryScreen extends StatefulWidget {
  @override
  ConfirmDeliveryScreenState createState() => ConfirmDeliveryScreenState();
}

class ConfirmDeliveryScreenState extends State<ConfirmDeliveryScreen> {
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
      appBar: appBarWidget('Confirm Delivery', color: colorPrimary, textColor: white, elevation: 0),
      body: BodyCornerWidget(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: ListView.builder(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            itemCount: 10,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (_, index) {
              return NewOrderWidget(
                name: 'Take Parcel',
                onTap: () {
                  ReceivedScreenOrderScreen().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
