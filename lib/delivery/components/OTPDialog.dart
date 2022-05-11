import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

class OTPDialog extends StatefulWidget {
  final String? verificationId;
  final Function()? onUpdate;

  OTPDialog({this.verificationId,this.onUpdate});

  @override
  OTPDialogState createState() => OTPDialogState();
}
class OTPDialogState extends State<OTPDialog> {
  OtpFieldController otpController = OtpFieldController();

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO Localization
            Text('Enter OTP', style: boldTextStyle()),
            30.height,
            OTPTextField(
              controller: otpController,
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
                appStore.setLoading(true);
                AuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verificationId!, smsCode: pin);
                print('credential:${credential.toString()}');
                await FirebaseAuth.instance.signInWithCredential(credential).then((value){
                  appStore.setLoading(false);
                  finish(context);
                 widget.onUpdate!.call();
                }).catchError((error){
                  appStore.setLoading(false);
                  toast('Invalid Verification Code');
                  finish(context);
                });
              },
            ),
          ],
        ),
        Observer(builder:(context) => loaderWidget().visible(appStore.isLoading)),
      ],
    );
  }
}