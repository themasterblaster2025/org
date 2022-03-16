import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/screens/NotificationScreen.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/CityListModel.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/DataProviders.dart';
import 'package:mighty_delivery/user/components/FilterOrderComponent.dart';
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
            UserCitySelectScreen(
                isBack: true,
                onUpdate: () {
                  setState(() {});
                }).launch(context);
          }).paddingOnly(right: 16),
          Stack(
            children: [
              Align(
                alignment: AlignmentDirectional.center,
                child: Icon(Icons.notifications),
              ),
              Positioned(
                right: 2,
                top: 8,
                child: Observer(builder: (context) {
                  return Container(
                    height: 20,
                    width: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text('${appStore.allUnreadCount < 99 ? appStore.allUnreadCount : '99+'}', style: primaryTextStyle(size: 8, color: Colors.white)),
                  );
                }),
              ).visible(appStore.allUnreadCount != 0),
            ],
          ).withWidth(40).onTap(() {
            NotificationScreen().launch(context);
          }).visible(currentIndex == 0),
          IconButton(
            icon: ImageIcon(AssetImage('assets/icons/ic_filter.png')),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(defaultRadius), topRight: Radius.circular(defaultRadius))),
                builder: (context) {
                  return FilterOrderComponent();
                },
              );
            },
            padding: EdgeInsets.zero,
          ).visible(currentIndex == 0),
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
