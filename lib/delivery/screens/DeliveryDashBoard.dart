import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/delivery/fragment/DProfileFragment.dart';
import 'package:mighty_delivery/delivery/screens/CreateTabScreen.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/screens/NotificationScreen.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';

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
          automaticallyImplyLeading: false,
          actions: [
            Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional.center,
                  child: Icon(Icons.notifications),
                ),
                Observer(
                    builder: (context) {
                      return Positioned(
                        right: 2,
                        top: 8,
                        child: Container(
                          height: 20,
                          width: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: Text('${appStore.allUnreadCount < 99 ? appStore.allUnreadCount : '99+'}', style: primaryTextStyle(size: 8, color: Colors.white)),
                        ),
                      ).visible(appStore.allUnreadCount != 0);
                    }
                ),
              ],
            ).withWidth(40).onTap(() {
              NotificationScreen().launch(context);
            }),
            4.width,
            IconButton(
              onPressed: () {
                DProfileFragment().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
              },
              icon: Icon(Icons.settings),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            unselectedLabelColor: Colors.white70,
            indicatorColor: colorPrimary,
            labelColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.label,
            unselectedLabelStyle: secondaryTextStyle(),
            labelStyle: boldTextStyle(),
            tabs: statusList.map((e) {
              return Tab(text: orderStatus(e));
            }).toList(),
          ),
        ),
        body: BodyCornerWidget(
          child: TabBarView(
            children: statusList.map((e) {
              return CreateTabScreen(orderStatus: e);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
