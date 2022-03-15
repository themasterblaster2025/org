import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/NotificationModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';

class NotificationScreen extends StatefulWidget {
  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  ScrollController scrollController = ScrollController();
  int currentPage = 1;

  bool mIsLastPage = false;
  List<NotificationData> notificationData = [];

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (!mIsLastPage) {
          appStore.setLoading(true);

          currentPage++;
          setState(() {});

          init();
        }
      }
    });
    afterBuildCreated(() => appStore.setLoading(true));
  }

  void init() async {
    getNotification(page: currentPage).then((value) {
      appStore.setLoading(false);

      mIsLastPage = value.notification_data!.length < currentPage;
      if (currentPage == 1) {
        notificationData.clear();
      }
      notificationData.addAll(value.notification_data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('Notification', color: colorPrimary, textColor: white, elevation: 0),
      body: Stack(
        children: [
          BodyCornerWidget(
            child: ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: notificationData.length,
              itemBuilder: (_, index) {
                NotificationData data = notificationData[index];
                return Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.only(top: 8, bottom: 8),
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(defaultRadius)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        'https://w7.pngwing.com/pngs/884/454/png-transparent-car-truck-delivery-transport-logistics-delivery-truck.png',
                        fit: BoxFit.cover,
                        height: 50,
                        width: 50,
                      ).cornerRadiusWithClipRRect(25),
                      16.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('# ${data.data!.id.validate()}', style: secondaryTextStyle()),
                          2.height,
                          Text('Courier arrived', style: boldTextStyle()),
                          4.height,
                          Text('New order has been created.', style: secondaryTextStyle()),
                        ],
                      ).expand(),
                      Text(data.created_at.validate(), style: secondaryTextStyle()),
                    ],
                  ),
                );
              },
            ),
          ),
          Observer(builder: (_) => Loader().visible(appStore.isLoading))
        ],
      ),
    );
  }
}
