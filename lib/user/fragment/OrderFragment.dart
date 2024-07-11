import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/list_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/extensions/text_styles.dart';
import 'package:mighty_delivery/main/models/AppSettingModel.dart';
import 'package:mighty_delivery/main/screens/VerificationListScreen.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';

import '../../extensions/LiveStream.dart';
import '../../extensions/animatedList/animated_configurations.dart';
import '../../extensions/animatedList/animated_list_view.dart';
import '../../extensions/app_button.dart';
import '../../extensions/common.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../main.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/models/models.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../components/OrderCardComponent.dart';
import '../screens/StoreListScreen.dart';

class OrderFragment extends StatefulWidget {
  static String tag = '/OrderFragment';

  @override
  OrderFragmentState createState() => OrderFragmentState();
}

class OrderFragmentState extends State<OrderFragment> {
  List<OrderData> orderList = [];
  int page = 1;
  int totalPage = 1;
  bool isLastPage = false;
  List storeList = [];

  @override
  void initState() {
    super.initState();
    init();
    LiveStream().on('UpdateOrderData', (p0) {
      page = 1;
      getOrderListApiCall();
      setState(() {});
    });
  }

  Future<void> getOrderData() async {
    await getOrderListApiCall();
  }

  Future<void> init() async {
    getOrderData();

    await getAppSetting().then((value) {
      appStore.setOtpVerifyOnPickupDelivery(value.otpVerifyOnPickupDelivery == 1);
      appStore.setCurrencyCode(value.currencyCode ?? CURRENCY_CODE);
      appStore.setCurrencySymbol(value.currency ?? CURRENCY_SYMBOL);
      appStore.setCurrencyPosition(value.currencyPosition ?? CURRENCY_POSITION_LEFT);
      appStore.isVehicleOrder = value.isVehicleInOrder ?? 0;
      appStore.setDistanceUnit(value.distanceUnit ?? DISTANCE_UNIT_KM);
      if (value.storeType!.validate().isNotEmpty) {
        storeList = value.storeType.validate();
        setState(() {});
        // storeList.add(value.storeManage.validate());
      }
    }).catchError((error) {
      log(error.toString());
    });
    await getInvoiceSetting().then((value) {
      if (value.invoiceData != null && value.invoiceData!.isNotEmpty) {
        appStore.setInvoiceCompanyName(value.invoiceData!
            .firstWhere((element) => element.key == 'company_name')
            .value
            .validate());
        appStore.setInvoiceContactNumber(value.invoiceData!
            .firstWhere((element) => element.key == 'company_contact_number')
            .value
            .validate());
        appStore.setCompanyAddress(value.invoiceData!
            .firstWhere((element) => element.key == 'company_address')
            .value
            .validate());
        appStore.setInvoiceCompanyLogo(value.invoiceData!
            .firstWhere((element) => element.key == 'company_logo')
            .value
            .validate());
      }
    }).catchError((error) {
      toast(error.toString());
    }).whenComplete(() {
      appStore.setLoading(false);
    });
  }

  getOrderListApiCall() async {
    appStore.setLoading(true);

    FilterAttributeModel filterData = FilterAttributeModel.fromJson(getJSONAsync(FILTER_DATA));

    await getOrderList(
            page: page,
            orderStatus: filterData.orderStatus,
            fromDate: filterData.fromDate,
            toDate: filterData.toDate,
            excludeStatus: ORDER_DRAFT)
        .then((value) {
      appStore.setAllUnreadCount(value.allUnreadCount.validate());
      totalPage = value.pagination!.totalPages.validate(value: 1);
      page = value.pagination!.currentPage.validate(value: 1);

      if (value.walletData != null) {
        appStore.availableBal = value.walletData!.totalAmount;
      }

      isLastPage = false;
      if (page == 1) orderList.clear();
      orderList.addAll(value.data!);

      setState(() {});
    }).catchError((e) {
      isLastPage = true;
      toast(e.toString(), print: true);
    }).whenComplete(() => appStore.setLoading(false));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      // shrinkWrap: true,
      children: [
        if (storeList.isNotEmpty) ...[
          10.height,
          Row(
            children: [
              Text(
                language.whatCanWeGetYou,
                style: boldTextStyle(size: 16, color: colorPrimary),
              ),
              Spacer(),
              Icon(
                Icons.navigate_next,
                color: colorPrimary,
              ).onTap(() {
                StoreListScreen().launch(context);
              }),
            ],
          ).paddingSymmetric(horizontal: 10),
          8.height,
          CarouselSlider(
            options: CarouselOptions(
              // autoPlay: true,
              aspectRatio: 2.2,
              viewportFraction: 0.43,

              disableCenter: true,
              enlargeCenterPage: true,
            ),
            items: storeList.map((e) {
              StoreType item = e;
              return InkWell(
                onTap: () {
                  StoreListScreen(type: item.id.validate()).launch(context);
                },
                child: Column(
                  children: [
                    commonCachedNetworkImage(
                      // appStore.userProfile.validate(),
                      item.image.validate(),
                      height: context.height() * 0.18,
                      fit: BoxFit.cover,
                    ).cornerRadiusWithClipRRect(5),
                    4.height,
                    Text(
                      item.name.validate(),
                      style: boldTextStyle(size: 14),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          Divider(
            height: 6,
            color: dividerColor,
          ),
        ],
        Row(
          children: [
            Text(
              language.myOrders,
              style: boldTextStyle(size: 16, color: colorPrimary),
            ),
            Spacer(),
            Row(
              children: [
                Icon(
                  Icons.navigate_before,
                  color: colorPrimary,
                  size: 26,
                ).visible(page != 1).onTap(() {
                  page--;
                  orderList.clear();
                  setState(() {});
                  getOrderData();
                }),
                Text(
                  "Page $page of $totalPage",
                  style: boldTextStyle(size: 15, color: colorPrimary),
                ),
                Icon(
                  Icons.navigate_next,
                  color: colorPrimary,
                ).visible(page != totalPage).onTap(() {
                  page++;
                  orderList.clear();
                  setState(() {});
                  getOrderData();
                }),
              ],
            ),
          ],
        ).paddingSymmetric(horizontal: 10),
        AnimatedListView(
          itemCount: orderList.length,
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          listAnimationType: ListAnimationType.Slide,
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 60),
          flipConfiguration:
              FlipConfiguration(duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn),
          fadeInConfiguration:
              FadeInConfiguration(duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn),
          onNextPage: () {
            if (page < totalPage) {
              page++;
              setState(() {});
              getOrderData();
            }
          },
          emptyWidget: Stack(
            children: [
              loaderWidget().visible(appStore.isLoading),
              emptyWidget().visible(!appStore.isLoading),
            ],
          ),
          onSwipeRefresh: () async {
            page = 1;
            getOrderData();
            return Future.value(true);
          },
          itemBuilder: (context, i) {
            OrderData item = orderList[i];
            return item.status != ORDER_DRAFT ? OrderCardComponent(item: item) : SizedBox();
          },
        ),
      ],
    );
  }
}
