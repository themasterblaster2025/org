import 'package:flutter/material.dart';
import 'package:mighty_delivery/delivery/fragment/DProfileFragment.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:mighty_delivery/delivery/screens/ActiveTabScreen.dart';
import 'package:mighty_delivery/delivery/screens/ArrivedTabScreen.dart';
import 'package:mighty_delivery/delivery/screens/CancelledTabScreen.dart';
import 'package:mighty_delivery/delivery/screens/CompletedTabScreen.dart';
import 'package:mighty_delivery/delivery/screens/CreateTabScreen.dart';
import 'package:mighty_delivery/delivery/screens/DepartedTabScreen.dart';
import 'package:mighty_delivery/delivery/screens/PickedUpTabScreen.dart';
import 'package:mighty_delivery/main/screens/EditProfileScreen.dart';

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

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                EditProfileScreen().launch(context,pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
              },
              icon: Icon(Icons.person_outlined),
            ),
            IconButton(
              onPressed: () {
                DProfileFragment().launch(context,pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
              },
              icon: Icon(Icons.settings),
            )
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Create'),
              Tab(text: 'Active'),
              Tab(text: 'Picked up'),
              Tab(text: 'Arrived'),
              Tab(text: 'Departed'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CreateTabScreen(),
            ActiveTabScreen(),
            PickedUpTabScreen(),
            ArrivedTabScreen(),
            DepartedTabScreen(),
            CompletedTabScreen(),
            CancelledTabScreen(),
          ],
        ),
      ),
    );
  }
}
