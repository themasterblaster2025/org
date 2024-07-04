import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/delivery/screens/VerifyDeliveryPersonScreen.dart';
import 'package:mighty_delivery/extensions/extension_util/bool_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main/components/CommonScaffoldComponent.dart';
import 'package:mighty_delivery/main/models/LoginResponse.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';

import '../../delivery/screens/DeliveryDashBoard.dart';
import '../../extensions/app_button.dart';
import '../../extensions/common.dart';
import '../../extensions/confirmation_dialog.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../user/screens/DashboardScreen.dart';
import '../models/CityListModel.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import 'EmailVerificationScreen.dart';
import 'UserCitySelectScreen.dart';
import 'VerificationScreen.dart';

class VerificationListScreen extends StatefulWidget {
  final bool? isSignIn;

  VerificationListScreen({this.isSignIn = false});

  @override
  State<VerificationListScreen> createState() => _VerificationListScreenState();
}

class _VerificationListScreenState extends State<VerificationListScreen> {
  UserData? data;
  List<VerificationStep> verificationSteps = [];

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  Future<void> getUserData() async {
    appStore.setLoading(true);
    await getUserDetail(getIntAsync(USER_ID)).then((value) async {
      data = value;
      verificationSteps.clear();
      if (!data!.isEmailVerification.validate()) {
        VerificationStatus status = data!.emailVerifiedAt.isEmptyOrNull
            ? VerificationStatus.pending
            : VerificationStatus.completed;
        verificationSteps.add(
          VerificationStep(
              title: 'Email OTP',
              // todo
              image: Icons.email,
              description: 'Verify your email address.',
              // todo
              status: data!.emailVerifiedAt.isEmptyOrNull
                  ? VerificationStatus.pending
                  : VerificationStatus.completed,
              fun: () {
                if (status == VerificationStatus.pending) {
                  EmailVerificationScreen(
                    isSignIn: widget.isSignIn,
                  )
                      .launch(context, pageRouteAnimation: PageRouteAnimation.Slide)
                      .then((value) => getUserData());
                }
              }),
        );
        // setState(() {});
      }

      if (!data!.isMobileVerification.validate()) {
        VerificationStatus status = data!.otpVerifyAt.isEmptyOrNull
            ? VerificationStatus.pending
            : VerificationStatus.completed;
        verificationSteps.add(
          VerificationStep(
              title: 'Mobile OTP',
              // todo
              description: 'Verify your mobile number.',
              // todo
              image: Icons.phone,
              status: data!.otpVerifyAt.isEmptyOrNull
                  ? VerificationStatus.pending
                  : VerificationStatus.completed,
              fun: () {
                if (status == VerificationStatus.pending) {
                  VerificationScreen()
                      .launch(context, pageRouteAnimation: PageRouteAnimation.Slide)
                      .then((value) => getUserData());
                }
              }),
        );
        // setState(() {});
      }
      if (!data!.isDocumentVerification.validate() &&
          data?.userType.validate() == DELIVERY_MAN) {
        VerificationStatus status = data!.isVerifiedDeliveryMan.validate() == 0
            ? VerificationStatus.pending
            : VerificationStatus.completed;
        verificationSteps.add(
          VerificationStep(
              title: 'Document Verification',
              // todo
              description: 'Upload your documents for verification.',
              // todo
              image: Icons.newspaper_rounded,
              status: data!.isVerifiedDeliveryMan.validate() == 0
                  ? VerificationStatus.pending
                  : VerificationStatus.completed,
              fun: () {
                if (status == VerificationStatus.pending) {
                  VerifyDeliveryPersonScreen()
                      .launch(context, pageRouteAnimation: PageRouteAnimation.Slide)
                      .then((value) => getUserData());
                }
              }),
        );
        // setState(() {});
      }

      appStore.setLoading(false);

      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: "Verification You must do", // todo
      showBack: false,
      action: [
        IconButton(
          onPressed: () async {
            await showConfirmDialogCustom(
              context,
              primaryColor: colorPrimary,
              title: language.logoutConfirmationMsg,
              positiveText: language.yes,
              negativeText: language.no,
              onAccept: (c) async {
                appStore.setLoading(true);
                try {
                  await logout(context, isVerification: true).then((value) async {
                    appStore.setLoading(false);
                  });
                } catch (e) {
                  print(e.toString());
                }
              },
            );
          },
          icon: Icon(Icons.logout, color: Colors.white),
        ),
      ],
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                /* LinearProgressIndicator(
                  value: calculateProgress(),
                  minHeight: 8,
                  backgroundColor: Colors.grey[500],
                  valueColor: AlwaysStoppedAnimation<Color>(colorPrimary),
                ),*/
                20.height,
                ListView.builder(
                  itemCount: verificationSteps.length,
                  itemBuilder: (context, index) {
                    final step = verificationSteps[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(step.image),
                        title: Text(step.title),
                        subtitle: Text(step.description),
                        trailing: getActionButton(step.status, step.fun),
                      ),
                    );
                  },
                ).expand(),
                // Spacer(),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: boxDecorationWithRoundedCorners(backgroundColor: colorPrimary),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        language.next,
                        style: secondaryTextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).onTap(() async {
                  if (verificationSteps
                      .any((element) => element.status == VerificationStatus.pending)) {
                    toast("You must verify above all"); // todo
                  } else {
                    goToDashboard();
                  }
                })
              ],
            ),
          ),
          Observer(
              builder: (context) => Visibility(
                  visible: appStore.isLoading, child: Positioned.fill(child: loaderWidget()))),
        ],
      ),
    );
  }

  double calculateProgress() {
    final completedSteps =
        verificationSteps.where((step) => step.status == VerificationStatus.completed).length;
    return completedSteps / verificationSteps.length;
  }

  Future<void> goToDashboard() async {
    if (data!.countryId != null && data!.cityId != null) {
      await getCountryDetailApiCall(data!.countryId.validate());
      getCityDetailApiCall(data!.cityId.validate(), context);
    } else {
      if (CityModel.fromJson(getJSONAsync(CITY_DATA)).name.validate().isNotEmpty) {
        if (getStringAsync(USER_TYPE) == CLIENT) {
          DashboardScreen().launch(context, isNewTask: true);
        } else {
          DeliveryDashBoard().launch(context, isNewTask: true);
        }
      } else {
        UserCitySelectScreen().launch(context, isNewTask: true);
      }
    }
  }

  Widget getActionButton(VerificationStatus status, Function fun) {
    switch (status) {
      case VerificationStatus.completed:
        return commonAppButton(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Verified", //  todo
                    style: primaryTextStyle(
                      color: Colors.green.shade600,
                    )),
                4.width,
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 17,
                ),
              ],
            ),
            () => fun,
            borderColor: Colors.green.shade600);

      case VerificationStatus.pending:
        return commonAppButton(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Verify", //  todo
                    style: primaryTextStyle(color: Colors.red)),
                Icon(Icons.arrow_right, color: Colors.red),
              ],
            ),
            () => fun(),
            borderColor: Colors.red);
      default:
        return ElevatedButton(
          onPressed: () {},
          child: Text('Verify'),
        );
    }
  }
}

enum VerificationStatus { pending, completed }

class VerificationStep {
  String title;
  String description;
  IconData image;
  VerificationStatus status;
  Function fun;

  VerificationStep(
      {required this.title,
      required this.image,
      required this.description,
      required this.status,
      required this.fun});
}

Widget commonAppButton(Widget child, Function() fn, {Color? borderColor}) {
  return AppButton(
    elevation: 0,
    height: 30,
    color: Colors.transparent,
    padding: EdgeInsets.symmetric(horizontal: 8),
    shapeBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(defaultRadius),
      side: BorderSide(color: borderColor ?? colorPrimary),
    ),
    child: child,
    onTap: fn,
  );
}

getCountryDetailApiCall(int countryId) async {
  await getCountryDetail(countryId).then((value) {
    setValue(COUNTRY_DATA, value.data!.toJson());
  }).catchError((error) {});
}

getCityDetailApiCall(int cityId, BuildContext context) async {
  await getCityDetail(cityId).then((value) async {
    await setValue(CITY_DATA, value.data!.toJson());
    if (CityModel.fromJson(getJSONAsync(CITY_DATA)).name.validate().isNotEmpty) {
      if (getStringAsync(USER_TYPE) == CLIENT) {
        DashboardScreen().launch(context, isNewTask: true);
      } else {
        DeliveryDashBoard().launch(context, isNewTask: true);
      }
    } else {
      UserCitySelectScreen().launch(context, isNewTask: true);
    }
  }).catchError((error) {
    if (error.toString() == CITY_NOT_FOUND_EXCEPTION) {
      UserCitySelectScreen()
          .launch(getContext, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
    }
  });
}
