import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../main/models/NotificationModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../user/screens/OrderDetailScreen.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import '../utils/Widgets.dart';

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
    return Scaffold(
      appBar: commonAppBarWidget(language.notifications),
      body: Observer(builder: (context) {
        return Stack(
          children: [
            notificationData.isNotEmpty
                ? ListView.separated(
                    controller: scrollController,
                    padding: EdgeInsets.only(top: 8),
                    itemCount: notificationData.length,
                    itemBuilder: (_, index) {
                      NotificationData data = notificationData[index];
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                        color: data.readAt != null ? Colors.transparent : Colors.grey.withOpacity(0.2),
                        child: Row(
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorPrimary.withOpacity(0.15),
                              ),
                              child: commonCachedNetworkImage(statusTypeIcon(type: data.data!.type), fit: BoxFit.fill,color: colorPrimary,width: 22, height:  22),
                            ),
                            16.width,
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
                      return Divider(height: 0,);
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
