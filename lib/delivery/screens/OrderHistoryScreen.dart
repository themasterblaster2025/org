import 'package:flutter/material.dart';
import 'package:mighty_delivery/delivery/components/NewOrderWidget.dart';
import 'package:mighty_delivery/delivery/screens/DeliveryDetailScreen.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/utils/DataProviders.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  OrderHistoryScreenState createState() => OrderHistoryScreenState();
}

class OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<AppModel> list = getSearchList();

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
          customAppBarWidget(context, 'Order History', isShowBack: true),
          containerWidget(
            context,
            SingleChildScrollView(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: ListView.builder(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                itemCount: 10,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  return NewOrderWidget(
                    name: 'Order Detail',
                    onTap: () {
                      DeliveryDetailScreen().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
