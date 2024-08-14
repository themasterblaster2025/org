import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/extensions/colors.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/list_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main/Chat/ChatWithAdminScreen.dart';
import 'package:mighty_delivery/main/components/CommonScaffoldComponent.dart';
import 'package:mighty_delivery/main/models/CustomerSupportModel.dart';
import 'package:mighty_delivery/main/screens/AddSupportTicketScreen.dart';

import '../../extensions/decorations.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import 'customer_support_detials_screen.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  List<CustomerSupport> supportList = [];
  ScrollController scrollController = ScrollController();
  int page = 1;
  int totalPage = 1;

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !appStore.isLoading) {
        if (page < totalPage) {
          page++;
          appStore.setLoading(true);
          init();
        }
      }
    });
  }

  void init() {
    getCustomerSupportListApi();
  }

  Future<void> getCustomerSupportListApi() async {
    appStore.setLoading(true);
    await getCustomerSupportList(page: page).then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages.validate(value: 1);
      page = value.pagination!.currentPage.validate(value: 1);
      if (page == 1) {
        supportList.clear();
      }
      supportList.addAll(value.customerSupport!);
      appStore.setLoading(false);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
    });
  }

  getStatus(String status) {
    if (status == "pending") {
      return Text(status, style: boldTextStyle(color: pendingColor));
    } else if (status == "inreview") {
      return Text(status, style: boldTextStyle(color: in_progressColor));
    } else {
      return Text(status, style: boldTextStyle(color: completedColor));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: "Customer support", // todo
      body: Observer(builder: (context) {
        return Stack(
          children: [
            supportList.isNotEmpty
                ? ListView.builder(
                    itemCount: supportList.length,
                    shrinkWrap: true,
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    itemBuilder: (context, index) {
                      CustomerSupport item = supportList[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(8),
                        decoration: boxDecorationWithRoundedCorners(
                            borderRadius: BorderRadius.circular(defaultRadius),
                            border: Border.all(
                                color:
                                    appStore.isDarkMode ? Colors.grey.withOpacity(0.3) : colorPrimary.withOpacity(0.4)),
                            backgroundColor: Colors.transparent),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text("Support id : ", style: boldTextStyle()), // todo
                                        Text(item.supportId.validate().toString(), style: boldTextStyle()),
                                      ],
                                    ),
                                    getStatus(item.status.validate())
                                    //    Text(item.status.validate(), style: boldTextStyle()),
                                  ],
                                ),
                                8.height,
                                Row(
                                  children: [
                                    Text("Support type : ", style: primaryTextStyle()), // todo
                                    Text(item.supportType.validate(), style: primaryTextStyle()),
                                  ],
                                ),
                                8.height,
                                Row(
                                  children: [
                                    Text("Message : ", style: primaryTextStyle()), // todo
                                    Text(item.message.validate(), style: primaryTextStyle()),
                                  ],
                                ),
                                8.height,
                                Row(
                                  children: [
                                    Text("Attachment : ", style: primaryTextStyle()),
                                    10.width, // todo
                                    Text((item.video.isEmptyOrNull) ? "view photo" : "view video").onTap(() {
                                      CustomerSupportDetailsScreen(item.video.toString(), item.image.toString())
                                          .launch(context);
                                    }),
                                  ],
                                ),
                                if (item.resolutionDetail != null) 8.height,
                                if (item.resolutionDetail != null)
                                  Row(
                                    children: [
                                      Text("Resolution detail : ", style: primaryTextStyle()),
                                      10.width, // todo
                                      Text(item.resolutionDetail.validate(), style: primaryTextStyle()),
                                    ],
                                  ),
                              ],
                            ).expand(),
                          ],
                        ),
                      ).onTap(() {
                        ChatWithAdminScreen(item.supportChatHistory, item.supportId).launch(context);
                      });
                    },
                  )
                : !appStore.isLoading
                    ? emptyWidget()
                    : SizedBox(),
            loaderWidget().center().visible(appStore.isLoading),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorPrimary,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          AddSupportTicketScreen().launch(context).then((value) {
            init();
          });
        },
      ),
    );
  }
}
