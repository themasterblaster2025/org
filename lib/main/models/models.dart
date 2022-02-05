import 'package:flutter/material.dart';

class WalkThroughItemModel {
  String? image;
  String? title;
  String? subTitle;

  WalkThroughItemModel({this.image, this.title, this.subTitle});
}

class BottomNavigationBarItemModel {
  IconData? icon;
  String? title;
  Widget? widget;

  BottomNavigationBarItemModel({this.icon, this.title, this.widget});
}

class SettingItemModel {
  IconData? icon;
  String? title;
  Widget? widget;

  SettingItemModel({this.icon, this.title, this.widget});
}

class AppModel {
  String? name;
  String? subTitle;
  bool isCheck;

  AppModel({this.name, this.subTitle, this.isCheck = false});
}


