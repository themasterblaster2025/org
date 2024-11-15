import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main/models/CouponListResponseModel.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/Chat/ChatWithAdminScreen.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/CustomerSupportModel.dart';
import '../../main/screens/AddSupportTicketScreen.dart';

import '../../extensions/decorations.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/dynamic_theme.dart';
import 'customer_support_detials_screen.dart';

class CouponListScreen extends StatefulWidget {
  const CouponListScreen({super.key});

  @override
  State<CouponListScreen> createState() => _CouponListScreenState();
}

class _CouponListScreenState extends State<CouponListScreen> {
  List<CouponModel> couponList = [];
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
    await getCouponListApi(page).then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages.validate(value: 1);
      page = value.pagination!.currentPage.validate(value: 1);
      if (page == 1) {
        couponList.clear();
      }
      couponList.addAll(value.data!);
      appStore.setLoading(false);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      //todo add keys
      appBarTitle: language.customerSupport,
      body: Observer(builder: (context) {
        return Stack(
          children: [
            couponList.isNotEmpty
                ? ListView.builder(
                    itemCount: couponList.length,
                    shrinkWrap: true,
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    itemBuilder: (context, index) {
                      CouponModel item = couponList[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(8),
                        decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(defaultRadius), border: Border.all(color: appStore.isDarkMode ? Colors.grey.withOpacity(0.3) : ColorUtils.colorPrimary.withOpacity(0.4)), backgroundColor: Colors.transparent),
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
                                        Text("${language.id} :", style: boldTextStyle()),
                                        Text(item.id.validate().toString(), style: boldTextStyle()),
                                      ],
                                    ),
                                    Text(item.status.toString(), style: boldTextStyle()),
                                  ],
                                ),
                                8.height,
                                Row(
                                  children: [
                                    //todo add key
                                    Text('Coupon code : ', style: primaryTextStyle()),
                                    Text(item.couponCode.validate(), style: primaryTextStyle()),
                                  ],
                                ),
                                8.height,
                                Row(
                                  children: [
                                    Text('${language.startDate} : ', style: primaryTextStyle()),
                                    Text(item.startDate.validate(), style: primaryTextStyle()),
                                  ],
                                ),
                                8.height,
                                Row(
                                  children: [
                                    Text('${language.endDate} : ', style: primaryTextStyle()),
                                    10.width,
                                    Text(item.endDate.validate(), style: primaryTextStyle()),
                                  ],
                                ),
                                Row(
                                  children: [
                                    //todo add keys
                                    Text('Type :', style: primaryTextStyle()),
                                    10.width,
                                    Text(item.valueType.validate(), style: primaryTextStyle()),
                                  ],
                                ),
                              ],
                            ).expand(),
                          ],
                        ),
                      );
                    },
                  )
                : !appStore.isLoading
                    ? emptyWidget()
                    : SizedBox(),
            loaderWidget().center().visible(appStore.isLoading),
          ],
        );
      }),
    );
  }
}
