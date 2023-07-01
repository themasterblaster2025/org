import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main/services/AuthSertvices.dart';
import 'package:mighty_delivery/user/screens/DashboardScreen.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../delivery/components/OTPDialog.dart';
import '../../delivery/screens/DeliveryDashBoard.dart';
import '../../main.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';

class VerificationScreen extends StatefulWidget {
  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  userDetailGet() async {
    await getUserDetail(getIntAsync(USER_ID)).then((value) async {
      appStore.setLoading(false);
      setValue(OTP_VERIFIED, value.otpVerifyAt != null);
      setState(() {});
      if (getBoolAsync(OTP_VERIFIED).validate()) {
        DashboardScreen().launch(context, isNewTask: true);
      }
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        return Future.delayed(Duration(seconds: 3), () {
          userDetailGet();
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Verification', style: boldTextStyle(color: Colors.white)),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () async {
                  appStore.setLoading(true);
                  await userDetailGet();
                },
                icon: Icon(Icons.refresh)),
            IconButton(
                onPressed: () async {
                  await showConfirmDialogCustom(
                    context,
                    primaryColor: colorPrimary,
                    title: language.logoutConfirmationMsg,
                    positiveText: language.yes,
                    negativeText: language.no,
                    onAccept: (c) {
                      logout(context, isVerification: true);
                    },
                  );
                },
                icon: Icon(Icons.logout)),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              padding: EdgeInsets.all(16),
              children: [
                InkWell(
                  onTap: () async {
                    if (getBoolAsync(OTP_VERIFIED).validate()) {
                      toast('Phone number has already verified.');
                    } else {
                      appStore.setLoading(true);
                      log('-----${getStringAsync(USER_CONTACT_NUMBER)}');
                      sendOtp(context, phoneNumber: getStringAsync(USER_CONTACT_NUMBER), onUpdate: (verificationId) async {
                        await showInDialog(context,
                            builder: (context) => OTPDialog(
                                phoneNumber: getStringAsync(USER_CONTACT_NUMBER),
                                onUpdate: () {
                                  updateUserStatus({"id": getIntAsync(USER_ID), "otp_verify_at": DateTime.now().toString()}).then((value) {
                                    setValue(OTP_VERIFIED, true);
                                    if (getStringAsync(USER_TYPE) == CLIENT) {
                                      DashboardScreen().launch(getContext, isNewTask: true);
                                    } else {
                                      DeliveryDashBoard().launch(getContext, isNewTask: true);
                                    }
                                  });
                                },
                                verificationId: verificationId),
                            barrierDismissible: false);
                      });
                      /* await FirebaseAuth.instance.verifyPhoneNumber(
                        timeout: const Duration(seconds: 60),
                        phoneNumber: getStringAsync(USER_CONTACT_NUMBER),
                        verificationCompleted: (PhoneAuthCredential credential) async {
                          appStore.setLoading(false);
                          toast(language.verificationCompleted);
                        },
                        verificationFailed: (FirebaseAuthException e) {
                          appStore.setLoading(false);
                          if (e.code == 'invalid-phone-number') {
                            toast(language.phoneNumberInvalid);
                            throw language.phoneNumberInvalid;
                          } else {
                            toast(e.toString());
                            throw e.toString();
                          }
                        },
                        codeSent: (String verificationId, int? resendToken) async {
                          appStore.setLoading(false);
                          toast(language.codeSent);
                          await showInDialog(context,
                              builder: (context) => OTPDialog(
                                  phoneNumber: getStringAsync(USER_CONTACT_NUMBER),
                                  onUpdate: () {
                                    updateOtpVerify().then((value) {
                                      DashboardScreen().launch(context);
                                    });
                                  },
                                  verificationId: verificationId),
                              barrierDismissible: false);
                        },
                        codeAutoRetrievalTimeout: (String verificationId) {
                          appStore.setLoading(false);
                        },
                      );*/
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(defaultRadius),
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/phone.png', height: 24, width: 24, fit: BoxFit.cover),
                        SizedBox(width: 8),
                        Expanded(child: Text('Verify Phone Number', style: primaryTextStyle())),
                        SizedBox(width: 16),
                        getBoolAsync(OTP_VERIFIED).validate() ? Icon(Icons.verified, color: Colors.green) : Icon(Icons.navigate_next),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Observer(builder: (context) => Visibility(visible: appStore.isLoading, child: Positioned.fill(child: loaderWidget()))),
          ],
        ),
      ),
    );
  }
}
