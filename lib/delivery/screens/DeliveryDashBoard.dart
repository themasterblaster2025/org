import 'package:flutter/material.dart';
import 'package:mighty_delivery/delivery/fragment/DProfileFragment.dart';
import 'package:mighty_delivery/delivery/screens/CreateTabScreen.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

class DeliveryDashBoard extends StatefulWidget {
  @override
  DeliveryDashBoardState createState() => DeliveryDashBoardState();
}

class DeliveryDashBoardState extends State<DeliveryDashBoard> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  List<String> statusList = [ORDER_ASSIGNED, ORDER_ACTIVE, ORDER_ARRIVED, ORDER_PICKED_UP, ORDER_DEPARTED, ORDER_COMPLETED, ORDER_CANCELLED];
  int currentIndex = 1;

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: statusList.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorPrimary,
          actions: [
            IconButton(
              onPressed: () {
                DProfileFragment().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
              },
              icon: Icon(Icons.settings),
            )
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: statusList.map((e) {
              return Tab(text: orderStatus(e));
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: statusList.map((e) {
            return CreateTabScreen(orderStatus: e);
          }).toList(),
        ),
      ),
    );
  }
}
