import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/extensions/colors.dart';
import 'package:mighty_delivery/extensions/common.dart';
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
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !appStore.isLoading) {
        if (page < totalPage) {
          page++;
          appStore.setLoading(true);
          init();
        }
      }
    });
  }

  void init() {
    getCouponListApiCall();
  }

  Future<void> getCouponListApiCall() async {
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
      appBarTitle: "Coupon List",
      body: Observer(builder: (context) {
        return Stack(
          children: [
            couponList.isNotEmpty
                ? ListView.builder(
                    itemCount: couponList.length,
                    shrinkWrap: true,
                    controller: scrollController,
                    // padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    itemBuilder: (context, index) {
                      CouponModel item = couponList[index];
                      return Container(
                        width: double.infinity,
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: appStore.isDarkMode
                              ? Colors.transparent
                              : Colors.white,
                          borderRadius:
                              BorderRadius.circular(defaultRadius + 5),
                          border: Border.all(color: ColorUtils.colorPrimary),
                        ),
                        height: 100,
                        child: Row(
                          children: [
                            Container(
                              decoration: boxDecorationDefault(
                                  color: ColorUtils.colorPrimary,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(defaultRadius),
                                      bottomLeft:
                                          Radius.circular(defaultRadius))),
                              child: Center(
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: item.valueType == "fixed"
                                      ? Text(
                                          "${appStore.currencySymbol}${item.discountAmount} OFF",
                                          style: boldTextStyle(
                                              color: Colors.white, size: 18),
                                        )
                                      : Text(
                                          "${item.discountAmount}% OFF",
                                          style: boldTextStyle(
                                              color: Colors.white, size: 18),
                                        ),
                                ),
                              ),
                            ).expand(flex: 1),
                            Container(
                              color: appStore.isDarkMode
                                  ? Colors.transparent
                                  : Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${item.couponCode}",
                                            style: boldTextStyle(size: 20),
                                          ),
                                          4.height,
                                          item.valueType == "fixed"
                                              ? Text(
                                                  "Save ${appStore.currencySymbol}${item.discountAmount} On Your Order",
                                                  style: secondaryTextStyle(),
                                                )
                                              : Text(
                                                  "Save ${item.discountAmount}% On Your Order",
                                                  style: secondaryTextStyle(),
                                                ),
                                          4.height,
                                        ],
                                      ),
                                      // Apply Button
                                      TextButton(
                                        onPressed: () {
                                          pop(item);
                                        },
                                        child: Text(
                                          'Select',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ).paddingSymmetric(
                                      horizontal: 10, vertical: 1),
                                  Divider(
                                    color: Colors.grey,
                                  ),
                                  2.height,
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Expires In: ",
                                        style: secondaryTextStyle(),
                                      ),
                                      CountdownTimer(
                                        startDate:
                                            DateTime.parse(item.startDate!),
                                        targetDate: DateTime.parse(item
                                            .endDate!), // Target date and time
                                      ),
                                    ],
                                  ).paddingSymmetric(horizontal: 10)
                                ],
                              ),
                            ).expand(flex: 9),
                          ],
                        ),
                      ).onTap(() {
                        pop(item);
                      }).paddingSymmetric(vertical: 10, horizontal: 10);
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

class CountdownTimer extends StatefulWidget {
  final DateTime startDate;
  final DateTime targetDate;

  CountdownTimer({required this.startDate, required this.targetDate});

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _timeLeft = Duration();

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _startTimer();
  }

  void _calculateTimeLeft() {
    setState(() {
      if (widget.startDate.day == widget.targetDate.day &&
          widget.startDate.month == widget.targetDate.month &&
          widget.startDate.year == widget.targetDate.year) {
        DateTime endOfDay = DateTime(
          widget.startDate.year,
          widget.startDate.month,
          widget.startDate.day,
          23,
          59,
          59,
        );
        _timeLeft = endOfDay.difference(DateTime.now());
      } else {
        _timeLeft = widget.targetDate.difference(DateTime.now());
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _calculateTimeLeft();
      if (_timeLeft.isNegative) {
        _timer.cancel();
      }
    });
  }

  String _formatTime() {
    if (widget.startDate.day == widget.targetDate.day &&
        widget.startDate.month == widget.targetDate.month &&
        widget.startDate.year == widget.targetDate.year) {
      final hours = _timeLeft.inHours;
      final minutes = _timeLeft.inMinutes % 60;
      final seconds = _timeLeft.inSeconds % 60;
      return "$hours hrs $minutes mins $seconds secs";
    } else {
      final days = _timeLeft.inDays;
      final hours = _timeLeft.inHours % 24;
      final minutes = _timeLeft.inMinutes % 60;
      final seconds = _timeLeft.inSeconds % 60;
      return "$days days $hours hrs $minutes mins $seconds secs";
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _timeLeft.isNegative ? "Time's up!" : _formatTime(),
      style: boldTextStyle(size: 12, color: darkRed),
    );
  }
}
