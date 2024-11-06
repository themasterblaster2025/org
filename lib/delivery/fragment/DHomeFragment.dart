import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import '../../bidding/delivery/models/BidOrderModel.dart';
import '../../bidding/delivery/network/RestApis.dart';
import '../../bidding/delivery/screens/DeliveryBidListScreen.dart';
import '../../bidding/utils/Constants.dart';
import '../../delivery/screens/EarningHistoryScreen.dart';
import '../../delivery/screens/FilterCountScreen.dart';

import '../../extensions/app_text_field.dart';
import '../../extensions/confirmation_dialog.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/num_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/models/DashboardCountModel.dart';
import '../../main/models/OrderListModel.dart';
import '../../user/screens/OrderDetailScreen.dart';
import '../../user/screens/WalletScreen.dart';

import '../../extensions/LiveStream.dart';
import '../../extensions/colors.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/text_styles.dart';
import '../../extensions/widgets.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/CityListModel.dart';
import '../../main/models/LoginResponse.dart';
import '../../main/network/RestApis.dart';
import '../../main/screens/BankDetailScreen.dart';
import '../../main/screens/UserCitySelectScreen.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../delivery/fragment/DProfileFragment.dart';
import '../../extensions/common.dart';
import '../../main/screens/NotificationScreen.dart';
import '../../main/utils/dynamic_theme.dart';
import '../screens/DeliveryDashBoard.dart';
import '../screens/WithDrawScreen.dart';

class DHomeFragment extends StatefulWidget {
  @override
  State<DHomeFragment> createState() => _DHomeFragmentState();
}

class _DHomeFragmentState extends State<DHomeFragment> {
  int currentPage = 1;
  DashboardCount? countData;

  late double biddedAmount;
  TextEditingController reasonController = TextEditingController();
  late StreamSubscription _getOrdersWithBidsStream;
  late StreamSubscription _getOrdersWithBidsStreamToCancelBid;

  List<OrderData> orderList = [];
  BidOrderModel? latestOrder;
  BidOrderModel? latestOrderToCancelBid;

  ScrollController scrollController = ScrollController();
  UserBankAccount? userBankAccount;
  List items = [
    TODAY_ORDER,
    REMAINING_ORDER,
    COMPLETED_ORDER,
    INPROGRESS_ORDER,
    TOTAL_EARNING,
    WALLET_BALANCE,
    PENDING_WITHDRAW_REQUEST,
    COMPLETED_WITHDRAW_REQUEST,
  ];

  List<Color> colorList = [
    Color(0xFFF6D7D3),
    Color(0xFFE5D7D7),
    Color(0xFFE5D1EA),
    Color(0xFFD0E5F6),
    Color(0xFFD9F6D0),
    Color(0xFFF6D3E8),
    Color(0xFFFFDFDA),
    Color(0xFFD9D9F6),
    Color(0xFFE4D2E9),
  ];

  String getCount(int index) {
    switch (index) {
      case 0:
        return (countData?.todayOrder).toString().validate();
      case 1:
        return (countData?.pendingOrder).toString().validate();
      case 2:
        return (countData?.completeOrder).toString().validate();
      case 3:
        return (countData?.inprogressOrder).toString().validate();
      case 4:
        return printAmount((countData?.commission).validate());
      case 5:
        return printAmount((countData?.walletBalance).validate());
      case 6:
        return (countData?.pendingWithdrawRequest).toString().validate();
      case 7:
        return (countData?.completeWithdrawRequest).toString().validate();
      default:
        return "0";
    }
  }

  Future<void> goToCountScreen(int index) async {
    if (index == 0 || index == 1) {
      DeliveryDashBoard().launch(context).then((value) {
        setState(() {});
        getDashboardCountDataApi();
      });
    } else if (index == 2) {
      DeliveryDashBoard(
        selectedIndex: 5,
      ).launch(context).then((value) {
        setState(() {});
        getDashboardCountDataApi();
      });
    } else if (index == 3) {
      DeliveryDashBoard(
        selectedIndex: 1,
      ).launch(context).then((value) {
        setState(() {});
        getDashboardCountDataApi();
      });
    } else if (index == 4) {
      EarningHistoryScreen().launch(context);
    } else if (index == 5) {
      WalletScreen().launch(context).then((value) {
        getDashboardCountDataApi();
      });
    } else {
      if (countData?.walletBalance.validate() != 0) {
        await getBankDetail();
        if (userBankAccount != null)
          WithDrawScreen(
            onTap: () {},
          ).launch(context);
        else {
          toast(language.bankNotFound);
          BankDetailScreen(isWallet: true).launch(context);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    LiveStream().on('UpdateLanguage', (p0) {
      setState(() {});
    });
    LiveStream().on('UpdateTheme', (p0) {
      setState(() {});
    });
    init();
    getDashboardCountDataApi();

    listenToOrderWithBidsStream();

    listenToOrderWithBidsStreamToCancelBid();
  }

  Future<void> init() async {
    await getAppSetting().then((value) {
      appStore.setCurrencyCode(value.currencyCode ?? CURRENCY_CODE);
      appStore.setCurrencySymbol(value.currency ?? CURRENCY_SYMBOL);
      appStore.setCopyRight(value.siteCopyright ?? "");
      appStore.setSiteEmail(value.siteEmail ?? "");
      appStore.setDistanceUnit(value.distanceUnit ?? DISTANCE_UNIT_KM);
      //  appStore.setOrderTrackingIdPrefix(value.orderTrackingIdPrefix ?? "");
      appStore.setIsInsuranceAllowed(value.isInsuranceAllowed ?? "0");
      appStore.setInsurancePercentage(value.insurancePercentage ?? "0");
      appStore.setCurrencyPosition(value.currencyPosition ?? CURRENCY_POSITION_LEFT);
      appStore.setInsuranceDescription(value.insuranceDescription ?? '');
      appStore.setMaxAmountPerMonth(value.maxEarningsPerMonth ?? '');
      setState(() {});
    }).catchError((error) {
      log(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> getDashboardCountDataApi({String? startDate, String? endDate}) async {
    appStore.setLoading(true);
    await getDashboardCount(startDate: startDate, endDate: endDate).then((value) {
      appStore.setLoading(false);
      countData = value;
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  getBankDetail() async {
    appStore.setLoading(true);
    await getUserDetail(getIntAsync(USER_ID)).then((value) {
      appStore.setLoading(false);
      userBankAccount = value.userBankAccount;
    }).then((value) {
      log(value.toString());
    });
  }

  void _showBidBottomSheet(BuildContext context) {
    biddedAmount = orderList[0].totalAmount!.toDouble();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: appStore.isDarkMode ? ColorUtils.scaffoldSecondaryDark : ColorUtils.scaffoldColorLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.placeYourBid, style: boldTextStyle(size: 20)),
                          IconButton(
                            icon: Icon(Icons.close, color: ColorUtils.colorPrimary, size: 30),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      24.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: boxDecorationWithRoundedCorners(
                              boxShape: BoxShape.circle,
                              border: Border.all(color: Colors.red),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.remove, color: Colors.red, size: 30),
                              onPressed: () {
                                setModalState(() {
                                  if (biddedAmount > 0) {
                                    biddedAmount -= (biddedAmount >= 10) ? 10 : 1;
                                    if (biddedAmount < 0) {
                                      biddedAmount = 0;
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                          24.width,
                          Text('${appStore.currencyCode}', style: boldTextStyle(size: 24)),
                          SizedBox(width: 4),
                          Text(biddedAmount.toStringAsFixed(2), style: boldTextStyle(size: 40)),
                          24.width,
                          Container(
                            decoration: boxDecorationWithRoundedCorners(
                              boxShape: BoxShape.circle,
                              border: Border.all(color: Colors.green),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.add, color: Colors.green, size: 30),
                              onPressed: () {
                                setModalState(() {
                                  biddedAmount += 10;
                                });
                              },
                            ),
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 16, vertical: 12),
                      16.height,
                      Text(language.saySomething, style: boldTextStyle(size: 16)),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: ColorUtils.colorPrimary.withOpacity(0.3),
                        ),
                        child: AppTextField(
                          controller: reasonController,
                          textFieldType: TextFieldType.NAME,
                          decoration: InputDecoration(
                            hintText: language.writeAMessage,
                            hintStyle: secondaryTextStyle(size: 16, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      20.height,
                      ElevatedButton(
                        onPressed: () async {
                          hideKeyboard(context);
                          context.pop();
                          await showConfirmDialogCustom(
                            context,
                            primaryColor: ColorUtils.colorPrimary,
                            title: "${language.confirmBid}?",
                            positiveText: language.yes,
                            negativeText: language.no,
                            onAccept: (c) async {
                              createApplyForBidApiCall();
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorUtils.colorPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(language.confirm, style: boldTextStyle(size: 20, color: Colors.white)),
                      ).withSize(width: context.width(), height: 60),
                      8.height,
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  createApplyForBidApiCall() async {
    log('createApplyForBidApiCall called');
    appStore.setLoading(true);

    Map req = {
      "order_id": latestOrder!.orderId,
      "bid_amount": biddedAmount.toDouble(),
      "notes": reasonController.text.trim(),
    };

    try {
      await createBid(req).then((value) {
        appStore.setLoading(false);
        toast(value.message);
        DHomeFragment().launch(context, isNewTask: true);
      }).whenComplete(
        () {
          appStore.setLoading(false);
        },
      );
    } catch (error) {
      appStore.setLoading(false);
      log('Error during apply bid API call: $error');
      toast(language.errorSomethingWentWrong);
    }
  }

  @override
  void dispose() {
    _getOrdersWithBidsStream.cancel();
    _getOrdersWithBidsStreamToCancelBid.cancel();
    reasonController.dispose();
    super.dispose();
  }

  Widget bidAcceptView({required BidOrderModel? order}) {
    if (orderList.isEmpty || order == null) return SizedBox();
    biddedAmount = orderList[0].totalAmount!.toDouble();
    return InkWell(
      onTap: () {
        OrderDetailScreen(
          orderId: order.orderId,
        ).launch(context);
      },
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                color: appStore.isDarkMode ? ColorUtils.scaffoldSecondaryDark : ColorUtils.scaffoldColorLight,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(2 * defaultRadius), topRight: Radius.circular(2 * defaultRadius)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.only(top: 16),
                        height: 6,
                        width: 60,
                        decoration: BoxDecoration(color: ColorUtils.themeColor, borderRadius: BorderRadius.circular(defaultRadius)),
                        alignment: Alignment.center,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text("${language.acceptBid}?", style: primaryTextStyle(size: 18)),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          decoration: BoxDecoration(color: appStore.isDarkMode ? ColorUtils.scaffoldSecondaryDark : ColorUtils.scaffoldColorLight, borderRadius: BorderRadius.circular(defaultRadius), border: Border.all(color: ColorUtils.colorPrimary)),
                          child: Text(language.viewAll, style: boldTextStyle(color: ColorUtils.colorPrimary), textAlign: TextAlign.center),
                        ).onTap(() {
                          DeliveryBidListScreen().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                        })
                      ],
                    ).paddingSymmetric(horizontal: 16),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(defaultRadius),
                                child: commonCachedNetworkImage(order.clientImage.validate(), height: 35, width: 35, fit: BoxFit.cover),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${order.clientName.validate().capitalizeFirstLetter()}', maxLines: 1, overflow: TextOverflow.ellipsis, style: boldTextStyle(size: 14)),
                                    SizedBox(height: 4),
                                    Text('${order.clientEmail.validate()}', maxLines: 1, overflow: TextOverflow.ellipsis, style: secondaryTextStyle()),
                                  ],
                                ),
                              ),
                              RichText(text: TextSpan(children: [TextSpan(text: "${language.orderId}: ", style: secondaryTextStyle(size: 16)), TextSpan(text: '#${order.orderId}', style: boldTextStyle(size: 14))])),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [Text('${language.estimateAmount}:', style: secondaryTextStyle(size: 16)), SizedBox(width: 4), Text("${printAmount(orderList[0].totalAmount)}", maxLines: 1, overflow: TextOverflow.ellipsis, style: boldTextStyle(size: 14))],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [Text('${language.distance}:', style: secondaryTextStyle(size: 16)), SizedBox(width: 4), Text('${orderList[0].totalDistance} km', maxLines: 1, overflow: TextOverflow.ellipsis, style: boldTextStyle(size: 14))],
                                ),
                              ],
                            ),
                            width: context.width(),
                          ),
                          addressDisplayWidget(
                            startAddress: "${orderList[0].pickupPoint?.address ?? ''}",
                            endAddress: "${orderList[0].deliveryPoint?.address ?? ''}",
                            startLatLong: LatLng(1, 1),
                            endLatLong: LatLng(1, 1),
                          ),
                          16.height,
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), border: Border.all(color: Colors.red)),
                                  child: Text(language.decline, style: boldTextStyle(color: Colors.red), textAlign: TextAlign.center),
                                ).onTap(appStore.isLoading
                                    ? null
                                    : () async {
                                        await showConfirmDialogCustom(
                                          context,
                                          primaryColor: ColorUtils.colorPrimary,
                                          title: "${language.declineBidConfirm}?",
                                          positiveText: language.yes,
                                          negativeText: language.no,
                                          onAccept: (c) {
                                            declineOrCancelBid(isDecline: true);
                                          },
                                        );
                                      }),
                              ),
                              16.width,
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), border: Border.all(color: Colors.green)),
                                  child: Text(language.accept, style: boldTextStyle(color: Colors.green), textAlign: TextAlign.center),
                                ).onTap(appStore.isLoading
                                    ? null
                                    : () {
                                        _showBidBottomSheet(context);
                                      }),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Observer(builder: (context) {
              return appStore.isLoading ? SizedBox.shrink() : SizedBox();
            })
          ],
        ),
      ),
    );
  }

  Widget bidCancelView({required BidOrderModel? order}) {
    if (orderList.isEmpty || order == null) return SizedBox();
    return InkWell(
      onTap: () {
        OrderDetailScreen(
          orderId: order.orderId,
        ).launch(context);
      },
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                color: appStore.isDarkMode ? ColorUtils.scaffoldSecondaryDark : ColorUtils.scaffoldColorLight,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(2 * defaultRadius), topRight: Radius.circular(2 * defaultRadius)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.only(top: 16),
                        height: 6,
                        width: 60,
                        decoration: BoxDecoration(color: ColorUtils.themeColor, borderRadius: BorderRadius.circular(defaultRadius)),
                        alignment: Alignment.center,
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text("${language.cancelBid}?", style: primaryTextStyle(size: 18)),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(defaultRadius),
                                child: commonCachedNetworkImage(order.clientImage.validate(), height: 40, width: 40, fit: BoxFit.cover),
                              ),
                              12.width,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${order.clientName.validate().capitalizeFirstLetter()}', maxLines: 1, overflow: TextOverflow.ellipsis, style: boldTextStyle(size: 14)),
                                    SizedBox(height: 4),
                                    Text('${order.clientEmail.validate()}', maxLines: 1, overflow: TextOverflow.ellipsis, style: secondaryTextStyle()),
                                  ],
                                ),
                              ),
                              12.width,
                              RichText(text: TextSpan(children: [TextSpan(text: "${language.orderId}: ", style: secondaryTextStyle(size: 16)), TextSpan(text: '#${order.orderId}', style: boldTextStyle(size: 14))]))
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [Text('${language.estimateAmount}:', style: secondaryTextStyle(size: 16)), SizedBox(width: 4), Text("${printAmount(orderList[0].totalAmount)}", maxLines: 1, overflow: TextOverflow.ellipsis, style: boldTextStyle(size: 14))],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [Text('${language.distance}:', style: secondaryTextStyle(size: 16)), SizedBox(width: 4), Text('${orderList[0].totalDistance} km', maxLines: 1, overflow: TextOverflow.ellipsis, style: boldTextStyle(size: 14))],
                                ),
                              ],
                            ),
                            width: context.width(),
                          ),
                          addressDisplayWidget(
                            startAddress: "${orderList[0].pickupPoint?.address ?? ''}",
                            endAddress: "${orderList[0].deliveryPoint?.address ?? ''}",
                            startLatLong: LatLng(1, 1),
                            endLatLong: LatLng(1, 1),
                          ),
                          16.height,
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), border: Border.all(color: Colors.red)),
                                  child: Text("${language.withdrawBid}", style: boldTextStyle(color: Colors.red), textAlign: TextAlign.center),
                                ).onTap(appStore.isLoading
                                    ? null
                                    : () async {
                                        await showConfirmDialogCustom(
                                          context,
                                          primaryColor: ColorUtils.colorPrimary,
                                          title: "${language.withdrawBidConfirm}?",
                                          positiveText: language.yes,
                                          negativeText: language.no,
                                          onAccept: (c) {
                                            declineOrCancelBid(isDecline: false);
                                          },
                                        );
                                      }),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Observer(builder: (context) {
              return appStore.isLoading ? SizedBox.shrink() : SizedBox();
            })
          ],
        ),
      ),
    );
  }

  Widget addressDisplayWidget({String? startAddress, String? endAddress, required LatLng startLatLong, required LatLng endLatLong, bool? isMultiple}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.near_me, color: Colors.green, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text(startAddress ?? ''.validate(), style: primaryTextStyle(size: 14), maxLines: 2)),
            // mapRedirectionWidget(
            //     latLong: LatLng(startLatLong.latitude.toDouble(),
            //         startLatLong.longitude.toDouble()))
          ],
        ),
        Row(
          children: [
            SizedBox(width: 8),
            SizedBox(
              height: 24,
              child: DottedLine(
                direction: Axis.vertical,
                lineLength: double.infinity,
                lineThickness: 1,
                dashLength: 2,
                dashColor: Colors.grey,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.red, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text(endAddress ?? '', style: primaryTextStyle(size: 14), maxLines: 2)),
            SizedBox(width: 8),
            // mapRedirectionWidget(
            //     latLong: LatLng(endLatLong.latitude.toDouble(),
            //         endLatLong.longitude.toDouble()))
          ],
        ),
      ],
    );
  }

  listenToOrderWithBidsStream() {
    _getOrdersWithBidsStream = FirebaseFirestore.instance
        .collection(ORDERS_BID_COLLECTION)
        .where(ALL_DELIVERY_MAN_IDS, arrayContains: getIntAsync(USER_ID))
        // .where(ORDER_STATUS, isEqualTo: ORDER_CREATED)
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.docs.isNotEmpty) {
          try {
            List<BidOrderModel> data = snapshot.docs.map((e) => BidOrderModel.fromJson(e.data())).toList();

            if (data.isNotEmpty) {
              latestOrder = data[0];
              if (latestOrder?.status == ORDER_CREATED) {
                getOrderListApiCall(latestOrder!.orderId);
              }
            }
          } catch (e) {
            log("ERROR::: $e");
          }
        } else {
          latestOrder = null;
          orderList = [];
          setState(() {});
        }
      },
      onError: (error) {
        // Handle error here
        log("ERROR::: $error");
      },
    );
  }

  listenToOrderWithBidsStreamToCancelBid() {
    _getOrdersWithBidsStreamToCancelBid = FirebaseFirestore.instance.collection(ORDERS_BID_COLLECTION).where(ACCEPTED_DELIVERY_MAN_IDS, arrayContains: getIntAsync(USER_ID)).snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        try {
          List<BidOrderModel> data = snapshot.docs.map((e) => BidOrderModel.fromJson(e.data())).toList();

          if (data.isNotEmpty) {
            latestOrderToCancelBid = data[0];
            if (latestOrderToCancelBid?.status == ORDER_CREATED) {
              getOrderListApiCall(latestOrderToCancelBid!.orderId);
            }
          }
        } catch (e) {
          log("ERROR::: $e");
        }
      } else {
        latestOrderToCancelBid = null;
        orderList = [];
        setState(() {});
      }
    });
  }

  getOrderListApiCall(int orderId) async {
    await getOrderDetails(orderId).then((value) {
      orderList.add(value.data!);
      setState(() {});
    }).catchError((e, s) {
      log("ERROR::: $e:::STACK::::$s");
    }).whenComplete(() => appStore.setLoading(false));
  }

  declineOrCancelBid({required bool isDecline}) async {
    appStore.setLoading(true);
    Map req = {"id": isDecline ? latestOrder!.orderId : latestOrderToCancelBid!.orderId, "delivery_man_id": getIntAsync(USER_ID).toString(), "is_bid_accept": isDecline ? "2" : "3"};

    try {
      await acceptOrRejectBid(req).then(
        (value) {
          appStore.setLoading(false);
          toast(value.message);
          DHomeFragment().launch(context, isNewTask: true);
        },
      ).whenComplete(
        () {
          appStore.setLoading(false);
        },
      );
    } catch (e) {
      appStore.setLoading(false);
      toast(language.errorSomethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBar: commonAppBarWidget(
        '${language.hey} ${getStringAsync(NAME)} 👋',
        showBack: false,
        actions: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: boxDecorationWithRoundedCorners(borderRadius: radius(defaultRadius), backgroundColor: Colors.white24),
            child: Row(children: [
              Icon(Ionicons.ios_location_outline, color: Colors.white, size: 18),
              8.width,
              Text(CityModel.fromJson(getJSONAsync(CITY_DATA)).name!.validate(), style: primaryTextStyle(color: white)),
            ]).onTap(() {
              UserCitySelectScreen(
                isBack: true,
                onUpdate: () {
                  currentPage = 1;
                  setState(() {});
                },
              ).launch(context);
            }, highlightColor: Colors.transparent, hoverColor: Colors.transparent, splashColor: Colors.transparent),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Align(alignment: AlignmentDirectional.center, child: Icon(Ionicons.md_notifications_outline, color: Colors.white)),
              Observer(builder: (context) {
                return Positioned(
                  right: 0,
                  top: 2,
                  child: Container(
                      height: 20,
                      width: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                      child: Text('${appStore.allUnreadCount < 99 ? appStore.allUnreadCount : '99+'}', style: primaryTextStyle(size: appStore.allUnreadCount < 99 ? 12 : 8, color: Colors.white))),
                ).visible(appStore.allUnreadCount != 0);
              }),
            ],
          ).withWidth(30).onTap(() {
            NotificationScreen().launch(context);
          }),
          IconButton(
            padding: EdgeInsets.only(right: 8),
            onPressed: () async {
              DProfileFragment().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
            },
            icon: Icon(Ionicons.settings_outline, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getDashboardCountDataApi();
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListView(
                physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                children: [
                  12.height,
                  Row(
                    children: [
                      Text(
                        language.filterBelowCount,
                        style: boldTextStyle(size: 16, color: ColorUtils.colorPrimary),
                      ),
                      Spacer(),
                      Icon(
                        Icons.filter_list,
                        color: ColorUtils.colorPrimary,
                      ).onTap(() async {
                        await showInDialog(context, shape: RoundedRectangleBorder(borderRadius: radius()), builder: (_) => FilterCountScreen(), contentPadding: EdgeInsets.zero).then((value) {
                          String startDate = DateFormat('yyyy-MM-dd').format(value[0]);
                          String endDate = DateFormat('yyyy-MM-dd').format(value[1]);
                          getDashboardCountDataApi(startDate: startDate, endDate: endDate);
                        });
                      }),
                    ],
                  ).paddingSymmetric(horizontal: 10),
                  8.height,
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.45,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    cacheExtent: 2.0,
                    shrinkWrap: true,
                    // physics: BouncingScrollPhysics(
                    //     parent: AlwaysScrollableScrollPhysics()),
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(7, 5, 7, 5),
                    itemBuilder: (context, index) {
                      return countWidget(text: items[index], value: getCount(index), color: colorList[index]).onTap(() {
                        goToCountScreen(index);
                      });
                    },
                    itemCount: items.length,
                  ),
                ],
              ),
            ),
            latestOrderToCancelBid != null ? bidCancelView(order: latestOrderToCancelBid ?? null) : bidAcceptView(order: latestOrder ?? null),
            Observer(builder: (context) => Positioned.fill(child: loaderWidget().visible(appStore.isLoading))),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: boxDecorationWithRoundedCorners(backgroundColor: ColorUtils.colorPrimary),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(language.viewAllOrders, style: boldTextStyle(color: Colors.white)),
            ],
          ).onTap(() {
            DeliveryDashBoard().launch(context).then((value) {
              setState(() {});
              getDashboardCountDataApi();
            });
          }),
        ),
      ),
    );
  }

  Widget countWidget({
    required String text,
    required String value,
    required Color color,
  }) {
    // Color color =
    return Container(
      decoration: appStore.isDarkMode ? boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(defaultRadius), backgroundColor: color) : boxDecorationRoundedWithShadow(defaultRadius.toInt(), backgroundColor: color),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: boldTextStyle(size: 27, color: textPrimaryColor),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          4.height,
          Text(
            countName(text),
            style: primaryTextStyle(size: 13, color: textPrimaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
