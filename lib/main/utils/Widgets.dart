import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'Colors.dart';

Widget commonButton(String title,Function() onTap,{double? width,Color? color}){
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