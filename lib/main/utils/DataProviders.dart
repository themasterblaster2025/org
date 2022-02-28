import 'package:flutter/material.dart';
import 'package:mighty_delivery/delivery/fragment/DHomeFragment.dart';
import 'package:mighty_delivery/delivery/fragment/DOrderFragment.dart';
import 'package:mighty_delivery/delivery/fragment/DProfileFragment.dart';
import 'package:mighty_delivery/delivery/screens/AddressSearchScreen.dart';
import 'package:mighty_delivery/main/screens/CitySelectScreen.dart';
import 'package:mighty_delivery/delivery/screens/OrderHistoryScreen.dart';
import 'package:mighty_delivery/delivery/screens/SearchAddressScreen.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/screens/ChangePasswordScreen.dart';
import 'package:mighty_delivery/main/screens/EditProfileScreen.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/user/fragment/AccountFragment.dart';
import 'package:mighty_delivery/user/fragment/OrderFragment.dart';

List<String> weightList = ['Up to 1 kg', 'Up to 5 kg', 'Up to 10 kg', 'Up to 15 kg', 'Up to 20 kg'];
List<String> paymentGatewayList = ['Stripe', 'Razorpay', 'PayStack', 'FlutterWave'];

List<WalkThroughItemModel> getWalkThroughItems() {
  List<WalkThroughItemModel> list = [];
  list.add(WalkThroughItemModel(image: 'assets/walk_through1.png', title: 'Select Pickup Location', subTitle: 'It helps us to get package from your doorstep.'));
  list.add(WalkThroughItemModel(image: 'assets/walk_through2.png', title: 'Select Drop Location', subTitle: 'So that we can deliver the package to the correct person quickly.'));
  list.add(WalkThroughItemModel(image: 'assets/walk_through3.png', title: 'Confirm And Relax', subTitle: 'We will deliver your package on time and in perfect condition.'));
  return list;
}

List<BottomNavigationBarItemModel> getNavBarItems() {
  List<BottomNavigationBarItemModel> list = [];
  //list.add(BottomNavigationBarItemModel(icon:Icons.dashboard,title: 'Home',widget: HomeFragment()));
  list.add(BottomNavigationBarItemModel(icon: Icons.shopping_bag, title: 'Order', widget: OrderFragment()));
  //list.add(BottomNavigationBarItemModel(icon:Icons.notifications,title: 'Notification'));
  list.add(BottomNavigationBarItemModel(icon: Icons.person, title: 'Account', widget: AccountFragment()));
  return list;
}

List<SettingItemModel> getSettingItems() {
  List<SettingItemModel> list = [];
  list.add(SettingItemModel(icon: Icons.person_outline, title: 'Edit Profile', widget: EditProfileScreen()));
  list.add(SettingItemModel(icon: Icons.lock_outline, title: 'Change Password', widget: ChangePasswordScreen()));
  list.add(SettingItemModel(icon: Icons.language, title: 'Language'));
  list.add(SettingItemModel(icon: Icons.wb_sunny_outlined, title: 'DarkMode'));
  list.add(SettingItemModel(icon: Icons.info_outline, title: 'About Us'));
  list.add(SettingItemModel(icon: Icons.help_outline, title: 'Help & Support'));
  list.add(SettingItemModel(icon: Icons.logout, title: 'Logout'));
  return list;
}

List<BottomNavigationBarItemModel> getDeliveryNavBarItems() {
  List<BottomNavigationBarItemModel> list = [];
  list.add(BottomNavigationBarItemModel(icon: Icons.dashboard, title: 'Home', widget: DHomeFragment()));
  list.add(BottomNavigationBarItemModel(icon: Icons.shopping_bag, title: 'Order', widget: DOrderFragment()));
  list.add(BottomNavigationBarItemModel(icon: Icons.person, title: 'Profile', widget: DProfileFragment()));
  return list;
}

List<SettingItemModel> getDeliverySettingItems() {
  List<SettingItemModel> list = [];
  list.add(SettingItemModel(icon: Icons.person_outline, title: 'Edit Profile', widget: EditProfileScreen()));
  list.add(SettingItemModel(icon: Icons.history_outlined, title: 'Order History', widget: OrderHistoryScreen()));
  list.add(SettingItemModel(icon: Icons.lock_outline, title: 'Change Password', widget: ChangePasswordScreen()));
  list.add(SettingItemModel(icon: Icons.location_on_outlined, title: 'Change Location', widget: CitySelectScreen(isBack: true)));
  list.add(SettingItemModel(icon: Icons.language, title: 'Language'));
  list.add(SettingItemModel(icon: Icons.wb_sunny_outlined, title: 'DarkMode', widget: SearchAddressScreen()));
  list.add(SettingItemModel(icon: Icons.info_outline, title: 'About Us',widget: AddressSearchScreen()));
  list.add(SettingItemModel(icon: Icons.help_outline, title: 'Help & Support'));
  list.add(SettingItemModel(icon: Icons.logout, title: 'Logout'));

  return list;
}

List<AppModel> getSearchList() {
  List<AppModel> list = [];
  list.add(AppModel(name: COURIER_ASSIGNED));
  list.add(AppModel(name: COURIER_DEPARTED));
  list.add(AppModel(name: RESTORE));
  list.add(AppModel(name: FORCE_DELETE));

  return list;
}
