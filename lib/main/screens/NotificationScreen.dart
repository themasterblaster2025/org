import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../main/models/NotificationModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../user/screens/OrderDetailScreen.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import '../components/CommonScaffoldComponent.dart';

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
    appStore.setLoading(true);
  }

  void init({Map? request}) async {
    getNotification(page: currentPage,request: request).then((value) {
      appStore.setLoading(false);
      appStore.setAllUnreadCount(value.allUnreadCount.validate());
      mIsLastPage = value.notificationData!.length < currentPage;
      if (currentPage == 1) {
        notificationData.clear();
      }
      notificationData.addAll(value.notificationData!);
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
    return CommonScaffoldComponent(
      appBarTitle: language.notifications,
      action: [
        TextButton(
            onPressed: () {
              Map req = {
                "type": "markas_read",
              };
              appStore.setLoading(true);

              init(request: req);
            },
            child: Text(language.markAllRead, style: secondaryTextStyle(color: Colors.white))).paddingRight(8)
      ],
      body: Observer(builder: (context) {
        return Stack(
          children: [
            notificationData.isNotEmpty
                ? ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: notificationData.length,
                    itemBuilder: (_, index) {
                      NotificationData data = notificationData[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(defaultRadius), backgroundColor: colorPrimary.withOpacity(0.08)),
                        padding: EdgeInsets.all(12),
                        // color: data.readAt != null ? Colors.transparent : Colors.grey.withOpacity(0.2),
                        child: Row(
                          children: [
                            Container(
                              height: 32,
                              width: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorPrimary.withOpacity(0.15),
                              ),
                              child: commonCachedNetworkImage(statusTypeIcon(type: data.data!.type), fit: BoxFit.fill, color: colorPrimary, width: 18, height: 18),
                            ),
                            8.width,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${data.data!.subject}', style: secondaryTextStyle()).expand(),
                                    8.width,
                                    Text(timeAgo(data.createdAt.validate()), style: secondaryTextStyle()),
                                  ],
                                ),
                                6.height,
                                Row(
                                  children: [
                                    Text('${data.data!.message}', style: primaryTextStyle(size: 14)).expand(),
                                    if (data.readAt.isEmptyOrNull) Icon(Entypo.dot_single, color: colorPrimary),
                                  ],
                                ),
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
                  )
                : !appStore.isLoading
                    ? emptyWidget()
                    : SizedBox(),
            loaderWidget().center().visible(appStore.isLoading)
          ],
        );
      }),
    );
  }
}
