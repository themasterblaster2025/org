import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:mighty_delivery/extensions/decorations.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/extensions/text_styles.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Images.dart';

import '../../extensions/app_button.dart';
import '../../extensions/colors.dart';
import '../../extensions/common.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/utils/Constants.dart';

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      //TODO add keys
      appBarTitle: "Refer & Earn",
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(ic_refer_earn, width: 200),
              10.height,
              Text("Refer to your friend and get a cash reward of 50 ", style: boldTextStyle()),
              20.height,
              Text(
                  "Share this code with your friend and after they register order,both of you will get 50 cash rewards"
                  ". ",
                  style: primaryTextStyle(),
                  textAlign: TextAlign.center),
              30.height,
              DottedBorder(
                  dashPattern: [6, 3, 2, 3],
                  color: viewLineColor,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("AD9TYE", style: boldTextStyle(size: 20)).paddingAll(8),
                      Icon(Icons.copy, size: 18).paddingAll(8)
                    ],
                  )).onTap(() {
                Clipboard.setData(ClipboardData(text: "AD9TYE")).then((_) {
                  //TODO add key
                  snackBar(context, content: Text("AD9TYE  copied to clipboard"));
                });
              }),
              30.height,
              Divider(thickness: 1, color: Colors.grey.withOpacity(0.3)),
            ],
          ).paddingAll(20),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: AppButton(
              width: context.width(),
              color: colorPrimary,
              text: "Refer & Earn",
              textStyle: primaryTextStyle(color: white),
              onTap: () {},
            ).expand(),
          ),
        ],
      ),
    );
  }
}
