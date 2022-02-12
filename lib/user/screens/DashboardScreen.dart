import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/DataProviders.dart';
import 'package:mighty_delivery/user/components/LocationChangeDialog.dart';
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
              Text('Surat', style: primaryTextStyle(color: white)),
            ],
          ).onTap(() {
            showInDialog(
              context,
              contentPadding: EdgeInsets.all(16),
              builder: (context) {
                return LocationChangeDialog();
              },
            );
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
      /*  bottomNavigationBar:BubbleBottomBar(
        opacity: 0.2,
        currentIndex: currentIndex,
        onTap: (value) {
          currentIndex = value!;
          setState(() {});
        },
        borderRadius: BorderRadius.vertical(top: Radius.circular(defaultRadius)),
        elevation: 8,
        hasNotch: true,
        inkColor: Colors.black12,
        items: BottomNavBarItems.map((item) {
          return BubbleBottomBarItem(
            backgroundColor: colorPrimary,
            icon: Icon(item.icon, color: Colors.grey),
            activeIcon: Icon(item.icon, color: colorPrimary),
            title: Text(item.title!),
          );
        }).toList(),
      )*/
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
