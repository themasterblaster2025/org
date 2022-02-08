import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/components/LocationChangeDialog.dart';
import 'package:nb_utils/nb_utils.dart';

import 'Colors.dart';

Widget commonButton(String title, Function() onTap, {double? width}) {
  return SizedBox(
    width: width,
    child: AppButton(
      shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
      elevation: 0,
      child: Text(
        title,
        style: boldTextStyle(color: white),
      ),
      color: colorPrimary,
      onTap: onTap,
    ),
  );
}

Widget outlineButton(String title, Function() onTap, {double? width}) {
  return SizedBox(
    width: width,
    child: AppButton(
      shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius), side: BorderSide(color: borderColor)),
      elevation: 0,
      child: Text(
        title,
        style: boldTextStyle(),
      ),
      color: Colors.transparent,
      onTap: onTap,
    ),
  );
}

Widget customAppBarWidget(BuildContext context, String title, {bool isShowBack = false, bool isShowLocation = false}) {
  return Container(
    height: 120,
    alignment: Alignment.center,
    width: context.width(),
    color: colorPrimary,
    padding: EdgeInsets.all(16),
    child: Row(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        isShowBack
            ? Icon(Icons.arrow_back_outlined, color: white).onTap(() {
                finish(context);
              })
            : SizedBox(),
        16.width,
        Text(title, style: boldTextStyle(color: white, size: 24)).expand(),
        16.width,
        isShowLocation
            ? Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white),
                  8.width,
                  Text('Surat', style: primaryTextStyle(color: white)),
                ],
              ).onTap(() {
                showInDialog(
                  context,
                  contentPadding: EdgeInsets.all(16),
                  builder: (context) {
                    return LocationChangeDialog();
                  },
                );
              })
            : SizedBox(),
      ],
    ),
  );
}

Widget containerWidget(BuildContext context, Widget? child) {
  return Container(
    margin: EdgeInsets.only(top: 90),
    height: context.height(),
    width: context.width(),
    decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    child: child,
  );
}

Widget scheduleOptionWidget(bool isSelected, String imagePath, String title) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: boxDecorationWithRoundedCorners(border: Border.all(color: isSelected ? colorPrimary : borderColor)),
    child: Column(
      children: [
        ImageIcon(AssetImage(imagePath), size: 20, color: isSelected ? colorPrimary : Colors.grey),
        16.height,
        Text(title, style: boldTextStyle()),
      ],
    ),
  );
}
