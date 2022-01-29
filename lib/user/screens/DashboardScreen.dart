import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/DataProviders.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
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
      body: Stack(
        children: [
          customAppBarWidget(context, '${BottomNavBarItems[currentIndex].title}'),
          containerWidget(context,BottomNavBarItems[currentIndex].widget),
        ],
      ),
      bottomNavigationBar: BubbleBottomBar(
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
      ),
    );
  }
}
