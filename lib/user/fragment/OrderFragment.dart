import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/models/models.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Images.dart';
import '../../user/screens/OrderTrackingScreen.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../user/screens/OrderDetailScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/GenerateInvoice.dart';
import '../components/OrderCardComponent.dart';

class OrderFragment extends StatefulWidget {
  static String tag = '/OrderFragment';

  @override
  OrderFragmentState createState() => OrderFragmentState();
}

class OrderFragmentState extends State<OrderFragment> {
  List<OrderData> orderList = [];
  ScrollController scrollController = ScrollController();
  int page = 1;
  int totalPage = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !appStore.isLoading) {
        if (page < totalPage) {
          page++;
          getOrderListApiCall();
        }
      }
    });
    LiveStream().on('UpdateOrderData', (p0) {
      page = 1;
      getOrderListApiCall();
      setState(() {});
    });
  }

  Future<void> init() async {
    await getOrderListApiCall();
    await getAppSetting().then((value) {
      appStore.setOtpVerifyOnPickupDelivery(value.otpVerifyOnPickupDelivery == 1);
      appStore.setCurrencyCode(value.currencyCode ?? currencyCode);
      appStore.setCurrencySymbol(value.currency ?? currencySymbol);
      appStore.setCurrencyPosition(value.currencyPosition ?? CURRENCY_POSITION_LEFT);
      appStore.isVehicleOrder = value.isVehicleInOrder ?? 0;
    }).catchError((error) {
      log(error.toString());
    });
    await getInvoiceSetting().then((value) {
      if (value.invoiceData != null && value.invoiceData!.isNotEmpty) {
        appStore.setInvoiceCompanyName(value.invoiceData!.firstWhere((element) => element.key == 'company_name').value.validate());
        appStore.setInvoiceContactNumber(value.invoiceData!.firstWhere((element) => element.key == 'company_contact_number').value.validate());
        appStore.setCompanyAddress(value.invoiceData!.firstWhere((element) => element.key == 'company_address').value.validate());
        appStore.setInvoiceCompanyLogo(value.invoiceData!.firstWhere((element) => element.key == 'company_logo').value.validate());
      }
    }).catchError((error) {
      toast(error.toString());
    });
  }

  getOrderListApiCall() async {
    appStore.setLoading(true);
    FilterAttributeModel filterData = FilterAttributeModel.fromJson(getJSONAsync(FILTER_DATA));
    await getOrderList(page: page, orderStatus: filterData.orderStatus, fromDate: filterData.fromDate, toDate: filterData.toDate, excludeStatus: ORDER_DRAFT).then((value) {
      appStore.setLoading(false);
      appStore.setAllUnreadCount(value.allUnreadCount.validate());
      totalPage = value.pagination!.totalPages.validate(value: 1);
      page = value.pagination!.currentPage.validate(value: 1);
      if (value.walletData != null) {
        appStore.availableBal = value.walletData!.totalAmount;
      }
      isLastPage = false;
      if (page == 1) {
        orderList.clear();
      }
      orderList.addAll(value.data!);
      setState(() {});
    }).catchError((e) {
      isLastPage = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(Duration(milliseconds: 1500));
        page = 1;
        init();
      },
      child: Observer(builder: (context) {
        return Stack(
          children: [
            orderList.isNotEmpty
                ? ListView(
                    shrinkWrap: true,
                    controller: scrollController,
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: context.height() * 0.1, top: 16),
                    children: orderList.map((item) {
                      return item.status != ORDER_DRAFT ? OrderCardComponent(item: item) : SizedBox();
                    }).toList(),
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
