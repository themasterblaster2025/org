import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/DataProviders.dart';
import 'package:nb_utils/nb_utils.dart';

class DDashboardScreen extends StatefulWidget {
  @override
  DDashboardScreenState createState() => DDashboardScreenState();
}

class DDashboardScreenState extends State<DDashboardScreen> {
  List<BottomNavigationBarItemModel> BottomNavBarItems = getDeliveryNavBarItems();
  int currentIndex = 0;

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
      appBar: appBarWidget(
        '${BottomNavBarItems[currentIndex].title}',
        color: colorPrimary,
        textColor: white,
        elevation: 0,
        showBack: false,
      ),
      body: BodyCornerWidget(
        child: Container(child: BottomNavBarItems[currentIndex].widget),
      ),
      /*Stack(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              appBarWidget(
                '${BottomNavBarItems[currentIndex].title}',
                color: colorPrimary,
                textColor: white,
                elevation: 0,
                showBack: false,
              ),
              */ /*Positioned(
                top: 32,
                right: 15,
                child: IconButton(
                  onPressed: () {
                    ShortingListScreen().launch(context,pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                  },
                  icon: Icon(Icons.search, color: white),
                ),
              )*/ /*
            ],
          ),
          containerWidget(context, BottomNavBarItems[currentIndex].widget),
        ],
      )*/
      bottomNavigationBar: BubbleBottomBar(
        opacity: 0.2,
        currentIndex: currentIndex,
        onTap: (value) {
          currentIndex = value!;
          setState(() {});
        },
        borderRadius: BorderRadius.vertical(top: Radius.circular(defaultRadius)),
        elevation: 8,
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
