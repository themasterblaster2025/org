import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

InputDecoration commonInputDecoration({String? hintText, IconData? suffixIcon, Function()? suffixOnTap, Widget? dateTime}) {
  return InputDecoration(
    contentPadding: EdgeInsets.all(12),
    filled: true,
    hintText: hintText != null ? hintText : '',
    hintStyle: secondaryTextStyle(),
    fillColor: Colors.grey.withOpacity(0.15),
    counterText: '',
    suffixIcon: dateTime != null
        ? dateTime
        : suffixIcon != null
            ? Icon(suffixIcon, color: Colors.grey, size: 22).onTap(suffixOnTap)
            : null,
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.none), borderRadius: BorderRadius.circular(defaultRadius)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary), borderRadius: BorderRadius.circular(defaultRadius)),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(defaultRadius)),
    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(defaultRadius)),
  );
}

Widget commonCachedNetworkImage(
  String? url, {
  double? height,
  double? width,
  BoxFit? fit,
  AlignmentGeometry? alignment,
  bool usePlaceholderIfUrlEmpty = true,
  double? radius,
}) {
  if (url.validate().isEmpty) {
    return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
  } else if (url.validate().startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: url!,
      height: height,
      width: width,
      fit: fit,
      alignment: alignment as Alignment? ?? Alignment.center,
      errorWidget: (_, s, d) {
        return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
      },
      placeholder: (_, s) {
        if (!usePlaceholderIfUrlEmpty) return SizedBox();
        return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
      },
    );
  } else {
    return Image.asset(url!, height: height, width: width, fit: fit, alignment: alignment ?? Alignment.center).cornerRadiusWithClipRRect(radius ?? defaultRadius);
  }
}

Widget placeHolderWidget({double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment, double? radius}) {
  return Image.asset('assets/placeholder.jpg', height: height, width: width, fit: fit ?? BoxFit.cover, alignment: alignment ?? Alignment.center).cornerRadiusWithClipRRect(radius ?? defaultRadius);
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

String? getOrderStatus(String orderStatus) {
  if (orderStatus == COURIER_ASSIGNED) {
    return 'Assigned';
  } else if (orderStatus == COURIER_DEPARTED) {
    return 'Departed';
  } else if (orderStatus == RESTORE) {
    return 'Restore';
  } else if (orderStatus == FORCE_DELETE) {
    return 'Delete';
  }
  return orderStatus;
}

Color statusColor(String status) {
  Color color = colorPrimary;
  switch (status) {
    case "active":
      return activeColor;
    case "canceled":
      return cancelledColor;
    case "completed":
      return completeColor;
    case "failed":
      return failedColor;
  }
  return color;
}

String parcelTypeIcon(String parcelType) {
  String icon = 'https://cdn-icons-png.flaticon.com/512/2991/2991112.png';
  switch (parcelType) {
    case "documents":
      return 'https://cdn-icons-png.flaticon.com/512/2991/2991112.png';
    case "food":
      return 'https://cdn-icons-png.flaticon.com/512/2991/2991112.png';
    case "cloths":
      return 'https://cdn-icons-png.flaticon.com/512/2991/2991112.png';
    case "groceries":
      return 'https://cdn-icons-png.flaticon.com/512/2991/2991112.png';
    case "cake":
      return 'https://cdn-icons-png.flaticon.com/512/918/918234.png';
    case "flowers":
      return 'https://cdn-icons-png.flaticon.com/512/149/149569.png';
  }
  return icon;
}

containerDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(defaultRadius),
    color: Colors.white,
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 1),
    ],
  );
}

String printDate(String date) {
  return DateFormat.yMd().add_jm().format(DateTime.parse(date).toLocal());
}

