import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'Colors.dart';

Widget commonButton(String title, Function() onTap, {double? width, Color? color}) {
  return SizedBox(
    width: width,
    child: AppButton(
      shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
      elevation: 0,
      child: Text(
        title,
        style: boldTextStyle(color: white),
      ),
      color: color ?? colorPrimary,
      onTap: onTap,
    ),
  );
}

Widget customAppBarWidget(BuildContext context, String title, {bool isShowBack = false}) {
  return Container(
    height: 100,
    alignment: Alignment.center,
    width: context.width(),
    color: colorPrimary,
    padding: EdgeInsets.all(16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        isShowBack
            ? Icon(Icons.arrow_back_outlined,color: white).onTap(() {
                finish(context);
              })
            : SizedBox(),
        Text(title, style: boldTextStyle(color: white, size: 20)),
        SizedBox(),
      ],
    ),
  );
}

Widget containerWidget(BuildContext context, Widget? child) {
  return Container(
    margin: EdgeInsets.only(top: 80),
    height: context.height() - 100,
    width: context.width(),
    decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    child: child,
  );
}
