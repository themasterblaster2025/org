import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/CityListModel.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/DataProviders.dart';
import 'package:mighty_delivery/user/components/UserCitySelectScreen.dart';
import 'package:mighty_delivery/user/screens/CreateOrderScreen.dart';
import 'package:nb_utils/nb_utils.dart';

class DashboardScreen extends StatefulWidget {
  static String tag = '/DashboardScreen';

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  List<BottomNavigationBarItemModel> BottomNavBarItems = getNavBarItems();
  int currentIndex = 0;

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
      appBar: appBarWidget(
        '${BottomNavBarItems[currentIndex].title}',
        color: colorPrimary,
        textColor: white,
        elevation: 0,
        showBack: false,
        actions: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white),
              8.width,
              Text(CityModel.fromJson(getJSONAsync(CITY_DATA)).name.validate(), style: primaryTextStyle(color: white)),
            ],
          ).onTap(() {
            UserCitySelectScreen(isBack: true,onUpdate:(){setState(() { });}).launch(context);
          }).paddingOnly(right: 16),
        ],
      ),
      body: BodyCornerWidget(child: BottomNavBarItems[currentIndex].widget!),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorPrimary,
        child: Icon(Icons.add),
        onPressed: () {
          CreateOrderScreen().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        color: Colors.white,
        child: AnimatedBottomNavigationBar(
          icons: [Icons.reorder, Icons.person],
          activeIndex: currentIndex,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.defaultEdge,
          activeColor: colorPrimary,
          inactiveColor: Colors.grey,
          leftCornerRadius: 32,
          rightCornerRadius: 32,
          onTap: (index) => setState(() => currentIndex = index),
          //other params
        ),
      ),
    );
  }
}
