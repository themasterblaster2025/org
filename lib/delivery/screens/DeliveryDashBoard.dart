import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import '../../delivery/fragment/DProfileFragment.dart';
import '../../delivery/screens/CreateTabScreen.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/screens/NotificationScreen.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import '../../main/network/RestApis.dart';

class DeliveryDashBoard extends StatefulWidget {
  @override
  DeliveryDashBoardState createState() => DeliveryDashBoardState();
}

class DeliveryDashBoardState extends State<DeliveryDashBoard> {
  List<String> statusList = [ORDER_ASSIGNED, ORDER_ACCEPTED, ORDER_ARRIVED, ORDER_PICKED_UP, ORDER_DEPARTED, ORDER_DELIVERED, ORDER_CANCELLED];
  int currentIndex = 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    LiveStream().on('UpdateLanguage', (p0) {
      setState(() {});
    });
    LiveStream().on('UpdateTheme', (p0) {
      setState(() {});
    });
    if (await checkPermission()) {
      positionStream = Geolocator.getPositionStream().listen((event) async {});
    }
    await getAppSetting().then((value) {
      appStore.setOtpVerifyOnPickupDelivery(value.otpVerifyOnPickupDelivery == 1);
      appStore.setCurrencyCode(value.currencyCode ?? currencyCode);
      appStore.setCurrencySymbol(value.currency ?? currencySymbol);
      appStore.setCurrencyPosition(value.currencyPosition ?? CURRENCY_POSITION_LEFT);
      appStore.isVehicleOrder = value.isVehicleInOrder ?? 0;
    }).catchError((error) {
      log(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: statusList.length,
      child: CommonScaffoldComponent(
        appBar: PreferredSize(
          preferredSize: Size(context.width(),90),
          child: commonAppBarWidget('${language.hey} ${getStringAsync(NAME)} 👋',showBack: false,
            actions: [
              Stack(clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: Icon(Ionicons.md_notifications_outline,color: Colors.white),
                  ),
                  Observer(builder: (context) {
                    return Positioned(
                      right: 0,
                      top: 2,
                      child: Container(
                        height: 20,
                        width: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                        child: Text('${appStore.allUnreadCount < 99 ? appStore.allUnreadCount : '99+'}', style: primaryTextStyle(size: appStore.allUnreadCount < 99 ? 12 : 8, color: Colors.white)),
                      ),
                    ).visible(appStore.allUnreadCount != 0);
                  }),
                ],
              ).withWidth(40).onTap(() {
                NotificationScreen().launch(context);
              }),
              IconButton(
                padding: EdgeInsets.only(right: 8),
                onPressed: () async {
                  DProfileFragment().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                },
                icon: Icon(Ionicons.settings_outline,color: Colors.white),
              ),
            ],
            bottom: TabBar(
              isScrollable: true,tabAlignment: TabAlignment.start,
              unselectedLabelColor: Colors.white70,
              indicator: BoxDecoration(color: Colors.transparent),
              labelColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.label,
              unselectedLabelStyle: secondaryTextStyle(),
              labelStyle: boldTextStyle(),
              tabs: statusList.map((e) {
                return Tab(text: orderStatus(e));
              }).toList(),
            ),
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
