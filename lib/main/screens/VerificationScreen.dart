import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main/components/CommonScaffoldComponent.dart';
import 'package:mighty_delivery/main/services/AuthServices.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:mighty_delivery/user/screens/DashboardScreen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:otp_text_field/style.dart';
import '../../delivery/screens/DeliveryDashBoard.dart';
import 'package:otp_text_field/otp_field.dart' as otp;

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
  bool? isOtpSend = false;
  String verId = '';
  String? otpPin = '';

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
      child: CommonScaffoldComponent(
        appBarTitle: language.verification,
        showBack: false,
        action: [
          IconButton(
            onPressed: () async {
              appStore.setLoading(true);
              await userDetailGet();
            },
            icon: Icon(Icons.refresh),
          ),
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
            icon: Icon(Icons.logout),
          ),
        ],
        body: Stack(
          children: [
            isOtpSend == false
                ? Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        16.height,
                        Text(language.phoneNumberVerification, style: boldTextStyle(size: 18)),
                        16.height,
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: secondaryTextStyle(),
                            children: [
                              TextSpan(text: '${language.weSend} '),
                              TextSpan(text: language.oneTimePassword, style: boldTextStyle()),
                              TextSpan(text: " ${language.on} " + getStringAsync(USER_CONTACT_NUMBER).replaceAll(RegExp(r'(?<=.*).(?=.{2})'), '*') ?? "-")
                            ],
                          ),
                        ),

                        16.height,
                        commonButton(language.getOTP, () {
                          // isOtpSend = true;
                          sendOtp(context, phoneNumber: getStringAsync(USER_CONTACT_NUMBER).validate(), onUpdate: (verificationId) {
                            verId = verificationId;
                            isOtpSend = true;
                            setState(() {});
                          });
                          setState(() {});
                        }, width: context.width())
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        16.height,
                        Text(language.confirmationCode, style: boldTextStyle(size: 18)),
                        16.height,
                        Text("${language.confirmationCodeSent} " + getStringAsync(USER_CONTACT_NUMBER).replaceAll(RegExp(r'(?<=.*).(?=.{2})'), '*') ?? "-",
                            style: secondaryTextStyle(size: 16), textAlign: TextAlign.center),
                        30.height,
                        otp.OTPTextField(
                          length: 6,
                          width: MediaQuery.of(context).size.width,
                          fieldWidth: 35,
                          style: primaryTextStyle(),
                          textFieldAlignment: MainAxisAlignment.spaceAround,
                          fieldStyle: FieldStyle.box,
                          onChanged: (s) {
                            //
                          },
                          onCompleted: (pin) async {
                            otpPin = pin;
                            setState(() {});
                          },
                        ),
                        30.height,
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(language.didNotReceiveTheCode, style: secondaryTextStyle(size: 16)),
                            4.width,
                            Text(language.resend, style: boldTextStyle(color: colorPrimary)).onTap(() {
                              sendOtp(context, phoneNumber: getStringAsync(USER_CONTACT_NUMBER).validate(), onUpdate: (verificationId) {
                                verId = verificationId;
                                setState(() {});
                              });
                            }),
                          ],
                        ),
                        16.height,
                        commonButton(language.submit, () async {
                          appStore.setLoading(true);
                          AuthCredential credential = PhoneAuthProvider.credential(verificationId: verId, smsCode: otpPin.validate());
                          await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
                            appStore.setLoading(false);
                            updateUserStatus({"id": getIntAsync(USER_ID), "otp_verify_at": DateTime.now().toString()}).then((value) {
                              setValue(OTP_VERIFIED, true);
                              if (getStringAsync(USER_TYPE) == CLIENT) {
                                DashboardScreen().launch(getContext, isNewTask: true);
                              } else {
                                DeliveryDashBoard().launch(getContext, isNewTask: true);
                              }
                            });
                          }).catchError((error) {
                            appStore.setLoading(false);
                            toast(language.invalidVerificationCode);
                            finish(context);
                          });
                          setState(() {});
                        }, width: context.width())
                      ],
                    ),
                  ),
            Observer(builder: (context) => Visibility(visible: appStore.isLoading, child: Positioned.fill(child: loaderWidget()))),
          ],
        ),
      ),
    );
  }
}
