import 'package:flutter/material.dart';

class WalkThroughItemModel{
  String? image;
  String? title;
  String? subTitle;

  WalkThroughItemModel({this.image, this.title,this.subTitle});
}

class BottomNavigationBarItemModel{
  IconData? icon;
  String? title;

  BottomNavigationBarItemModel({this.icon, this.title});
}