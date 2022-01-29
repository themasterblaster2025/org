import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';

InputDecoration commonInputDecoration({String? hintText}) {
  return InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
    filled: true,
    hintText: hintText != null ? hintText : '',
    hintStyle: secondaryTextStyle(),
    fillColor: Colors.grey.withOpacity(0.15),
    counterText: '',
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.none), borderRadius: BorderRadius.circular(defaultRadius)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary), borderRadius: BorderRadius.circular(defaultRadius)),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(defaultRadius)),
  );
}
