import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/NotificationModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/user/screens/OrderDetailScreen.dart';
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
    print('call');
    getNotification(page: currentPage).then((value) {
      appStore.setLoading(false);
      appStore.setAllUnreadCount(value.all_unread_count.validate());
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
            child: ListView.separated(
              controller: scrollController,
              padding: EdgeInsets.zero,
              itemCount: notificationData.length,
              itemBuilder: (_, index) {
                NotificationData data = notificationData[index];
                return Container(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(decoration: BoxDecoration(shape: BoxShape.circle, color: data.read_at != null ? Colors.transparent : colorPrimary), width: 10, height: 10),
                      8.width,
                      Container(
                        height: 50,
                        width: 50,
                        alignment:Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorPrimary.withOpacity(0.15),
                        ),
                        child: ImageIcon(AssetImage(notificationTypeIcon(type: data.data!.type)),color: colorPrimary,size: 26),
                      ),
                      16.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${data.data!.subject}', style: boldTextStyle()).expand(),
                              8.width,
                              Text(data.created_at.validate(), style: secondaryTextStyle()),
                            ],
                          ),
                          8.height,
                          Text('${data.data!.message}', style: primaryTextStyle(size: 14)),
                        ],
                      ).expand(),
                    ],
                  ).onTap(() async {
                    bool? res = await OrderDetailScreen(orderId: data.data!.id.validate()).launch(context);
                    if (res!) {
                      currentPage = 1;
                      init();
                    }
                  }),
                );
              },
              separatorBuilder: (context, index) {
                return Divider();
              },
            ),
          ),
          Observer(builder: (_) => loaderWidget().visible(appStore.isLoading))
        ],
      ),
    );
  }
}
