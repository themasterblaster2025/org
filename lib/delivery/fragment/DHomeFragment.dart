import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/delivery/components/NewOrderWidget.dart';
import 'package:mighty_delivery/delivery/screens/ReceivedScreenOrderScreen.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

class DHomeFragment extends StatefulWidget {
  @override
  DHomeFragmentState createState() => DHomeFragmentState();
}

class DHomeFragmentState extends State<DHomeFragment> {
  ScrollController scrollController = ScrollController();
  int currentPage = 1;
  int totalPage = 1;

  bool mIsLastPage = false;
  List<OrderData> orderData = [];

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
  }

  void init() async {
    appStore.setLoading(true);

    getDeliveryBoyList(page: currentPage, deliveryBoyID: getIntAsync(USER_ID)).then((value) {
      appStore.setLoading(false);

      mIsLastPage = value.data!.length != value.pagination!.per_page!;

      currentPage = value.pagination!.currentPage!;
      totalPage = value.pagination!.totalPages!;

      if (currentPage == 1) {
        orderData.clear();
      }
      orderData.addAll(value.data!);
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
    return Stack(
      children: [
        ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.all(16),
          shrinkWrap: true,
          itemCount: orderData.length,
          itemBuilder: (_, index) {
            OrderData data = orderData[index];
            return NewOrderWidget(
              orderData: data,
              name: data.status == ORDER_ASSIGNED ? 'Active' : 'Take Parcel',
              onTap: () async {
                if (data.status == ORDER_ACTIVE) {
                  ReceivedScreenOrderScreen(orderData: data).launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                } else if (data.status == ORDER_ASSIGNED) {
                  await updateOrder(orderStatus: ORDER_ACTIVE, orderId: data.id);
                  init();
                }
              },
            );
          },
        ),
        Observer(builder: (_) => Loader().visible(appStore.isLoading))
      ],
    );
  }
}
