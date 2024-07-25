import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/delivery/screens/EarningHistoryScreen.dart';
import 'package:mighty_delivery/delivery/screens/FilterCountScreen.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/num_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main/models/DashboardCountModel.dart';
import 'package:mighty_delivery/user/screens/WalletScreen.dart';

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
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../delivery/fragment/DProfileFragment.dart';
import '../../extensions/common.dart';
import '../../main/screens/NotificationScreen.dart';
import '../screens/DeliveryDashBoard.dart';
import '../screens/WithDrawScreen.dart';

class DHomeFragment extends StatefulWidget {
  @override
  State<DHomeFragment> createState() => _DHomeFragmentState();
}

class _DHomeFragmentState extends State<DHomeFragment> {
  int currentPage = 1;
  DashboardCount? countData;

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
  }

  Future<void> init() async {
    await getAppSetting().then((value) {
      appStore.setCurrencyCode(value.currencyCode ?? CURRENCY_CODE);
      appStore.setCurrencySymbol(value.currency ?? CURRENCY_SYMBOL);
      appStore.setCurrencyPosition(value.currencyPosition ?? CURRENCY_POSITION_LEFT);
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
            decoration:
                boxDecorationWithRoundedCorners(borderRadius: radius(defaultRadius), backgroundColor: Colors.white24),
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
              Align(
                  alignment: AlignmentDirectional.center,
                  child: Icon(Ionicons.md_notifications_outline, color: Colors.white)),
              Observer(builder: (context) {
                return Positioned(
                  right: 0,
                  top: 2,
                  child: Container(
                      height: 20,
                      width: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                      child: Text('${appStore.allUnreadCount < 99 ? appStore.allUnreadCount : '99+'}',
                          style: primaryTextStyle(size: appStore.allUnreadCount < 99 ? 12 : 8, color: Colors.white))),
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
        onRefresh: ()async{
          getDashboardCountDataApi();
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  12.height,
                  Row(
                    children: [
                      Text(
                        language.filterBelowCount,
                        style: boldTextStyle(size: 16, color: colorPrimary),
                      ),
                      Spacer(),
                      Icon(
                        Icons.filter_list,
                        color: colorPrimary,
                      ).onTap(() async {
                        await showInDialog(context,
                                shape: RoundedRectangleBorder(borderRadius: radius()),
                                builder: (_) => FilterCountScreen(),
                                contentPadding: EdgeInsets.zero)
                            .then((value) {
                          String startDate = DateFormat('yyyy-MM-dd').format(value[0]);
                          String endDate = DateFormat('yyyy-MM-dd').format(value[1]);
                          getDashboardCountDataApi(startDate: startDate, endDate: endDate);
                        });
                      }),
                    ],
                  ).paddingSymmetric(horizontal: 10),
                  8.height,
                  // Wrap(
                  //   runSpacing: 8.0,
                  //   children:[
                  //     countWidget(text: "Today Order", value: 2).paddingOnly(right: 8),
                  //     countWidget(text: "Remaining Order", value: 2).paddingOnly(right: 8),
                  //     countWidget(text: "Completed Order", value: 2).paddingOnly(right: 8),
                  //     countWidget(text: "InProgress Order", value: 2).paddingOnly(right: 8),
                  //     countWidget(text: "Commission", value: 2).paddingOnly(right: 8),
                  //     countWidget(text: "Wallet Balance", value: 2).paddingOnly(right: 8),
                  //     countWidget(text: "Pending Withdrawal Request", value: 2).paddingOnly(right: 8),
                  //     countWidget(text: "Completed Withdrawal Request", value: 2).paddingOnly(right: 8),
                  //   ],),

                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.45,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    cacheExtent: 2.0,
                    shrinkWrap: false,
                    physics: AlwaysScrollableScrollPhysics(),
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(7, 5, 7, 5),
                    itemBuilder: (context, index) {
                      return countWidget(text: items[index], value: getCount(index), color: colorList[index]).onTap(() {
                        goToCountScreen(index);
                      });
                    },
                    itemCount: items.length,
                  ).expand(),
                  8.height,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: boxDecorationWithRoundedCorners(backgroundColor: colorPrimary),
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
                  10.height,
                ],
              ),
            ),
            Observer(builder: (context) => Positioned.fill(child: loaderWidget().visible(appStore.isLoading))),
          ],
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
      decoration: appStore.isDarkMode
          ? boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(defaultRadius), backgroundColor: color)
          : boxDecorationRoundedWithShadow(defaultRadius.toInt(), backgroundColor: color),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$value', style: boldTextStyle(size: 27, color: textPrimaryColor)),
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
