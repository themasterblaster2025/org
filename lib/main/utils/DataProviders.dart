import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/user/fragment/AccountFragment.dart';
import 'package:mighty_delivery/user/fragment/HomeFragment.dart';
import 'package:mighty_delivery/user/fragment/OrderFragment.dart';
import 'package:mighty_delivery/user/screens/ChangePasswordScreen.dart';
import 'package:mighty_delivery/user/screens/EditProfileScreen.dart';

List<String> weightList = ['Up to 1 kg','Up to 5 kg','Up to 10 kg','Up to 15 kg','Up to 20 kg'];
List<String> packageList = ['Documents','Food','Cloth','Groceries','Cake','Flowers'];

List<WalkThroughItemModel> getWalkThroughItems(){
  List<WalkThroughItemModel> list = [];
  list.add(WalkThroughItemModel(image: 'assets/walk_through1.png',title: 'Select Pickup Location',subTitle: 'It helps us to get package from your doorstep.'));
  list.add(WalkThroughItemModel(image: 'assets/walk_through2.png',title: 'Select Drop Location',subTitle: 'So that we can deliver the package to the correct person quickly.'));
  list.add(WalkThroughItemModel(image: 'assets/walk_through3.png',title: 'Confirm And Relax',subTitle: 'We will deliver your package on time and in perfect condition.'));
  return list;
}

List<BottomNavigationBarItemModel> getNavBarItems(){
  List<BottomNavigationBarItemModel> list = [];
  list.add(BottomNavigationBarItemModel(icon:Icons.dashboard,title: 'Home',widget: HomeFragment()));
  list.add(BottomNavigationBarItemModel(icon:Icons.shopping_bag,title: 'Order',widget: OrderFragment()));
  //list.add(BottomNavigationBarItemModel(icon:Icons.notifications,title: 'Notification'));
  list.add(BottomNavigationBarItemModel(icon:Icons.person,title: 'Account',widget: AccountFragment()));
  return list;
}

List<SettingItemModel> getSettingItems(){
  List<SettingItemModel> list = [];
  list.add(SettingItemModel(icon: Icons.person_outline,title: 'Edit Profile',widget: EditProfileScreen()));
  list.add(SettingItemModel(icon: Icons.lock_outline,title: 'Change Password',widget: ChangePasswordScreen()));
  list.add(SettingItemModel(icon: Icons.language,title: 'Language'));
  list.add(SettingItemModel(icon: Icons.wb_sunny_outlined,title: 'DarkMode'));
  list.add(SettingItemModel(icon: Icons.info_outline,title: 'About Us'));
  list.add(SettingItemModel(icon: Icons.help_outline,title: 'Help & Support'));
  return list;
}

List<DateTime> getDaysList(){
  List<DateTime> list = [];
  DateTime todayDate = DateTime.now();
  List.generate(15, (index){
    list.add(todayDate.add(Duration(days: index)));
  }).toList();
  return list;
}


