import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/screens/ChangePasswordScreen.dart';
import 'package:mighty_delivery/main/screens/CitySelectScreen.dart';
import 'package:mighty_delivery/main/screens/EditProfileScreen.dart';
import 'package:mighty_delivery/main/screens/LanguageScreen.dart';
import 'package:mighty_delivery/main/screens/ThemeScreen.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/user/components/UserCitySelectScreen.dart';
import 'package:mighty_delivery/user/fragment/AccountFragment.dart';
import 'package:mighty_delivery/user/fragment/OrderFragment.dart';
import 'package:mighty_delivery/user/screens/DraftOrderListScreen.dart';
import 'package:nb_utils/nb_utils.dart';

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(id: 1, name: 'English', subTitle: 'English', languageCode: 'en', fullLanguageCode: 'en-US', flag: 'assets/flag/ic_us.png'),
    LanguageDataModel(id: 2, name: 'Hindi', subTitle: 'हिंदी', languageCode: 'hi', fullLanguageCode: 'hi-IN', flag: 'assets/flag/ic_india.png'),
    LanguageDataModel(id: 3, name: 'Arabic', subTitle: 'عربي', languageCode: 'ar', fullLanguageCode: 'ar-AR', flag: 'assets/flag/ic_ar.png'),
  ];
}

List<String> weightList = ['Up to 1 kg', 'Up to 5 kg', 'Up to 10 kg', 'Up to 15 kg', 'Up to 20 kg'];

List<WalkThroughItemModel> getWalkThroughItems() {
  List<WalkThroughItemModel> list = [];
  list.add(WalkThroughItemModel(image: 'assets/walk_through1.png', title: 'Select Pickup Location', subTitle: 'It helps us to get package from your doorstep.'));
  list.add(WalkThroughItemModel(image: 'assets/walk_through2.png', title: 'Select Drop Location', subTitle: 'So that we can deliver the package to the correct person quickly.'));
  list.add(WalkThroughItemModel(image: 'assets/walk_through3.png', title: 'Confirm And Relax', subTitle: 'We will deliver your package on time and in perfect condition.'));
  return list;
}

List<BottomNavigationBarItemModel> getNavBarItems() {
  List<BottomNavigationBarItemModel> list = [];
  list.add(BottomNavigationBarItemModel(icon: Icons.shopping_bag, title: 'Order', widget: OrderFragment()));
  list.add(BottomNavigationBarItemModel(icon: Icons.person, title: 'Account', widget: AccountFragment()));
  return list;
}

List<SettingItemModel> getSettingItems() {
  List<SettingItemModel> list = [];
  list.add(SettingItemModel(icon: Icons.drafts, title: 'Drafts', widget: DraftOrderListScreen()));
  list.add(SettingItemModel(icon: Icons.person_outline, title: 'Edit Profile', widget: EditProfileScreen()));
  list.add(SettingItemModel(icon: Icons.lock_outline, title: 'Change Password', widget: ChangePasswordScreen()));
  list.add(SettingItemModel(icon: Icons.language, title: 'Language',widget: LanguageScreen()));
  list.add(SettingItemModel(icon: Icons.wb_sunny_outlined, title: 'DarkMode',widget: ThemeScreen()));
  list.add(SettingItemModel(icon: Icons.info_outline, title: 'About Us'));
  list.add(SettingItemModel(icon: Icons.help_outline, title: 'Help & Support'));
  list.add(SettingItemModel(icon: Icons.logout, title: 'Logout'));
  return list;
}


List<SettingItemModel> getDeliverySettingItems() {
  List<SettingItemModel> list = [];
  list.add(SettingItemModel(icon: Icons.person_outline, title: 'Edit Profile', widget: EditProfileScreen()));
  list.add(SettingItemModel(icon: Icons.lock_outline, title: 'Change Password', widget: ChangePasswordScreen()));
  list.add(SettingItemModel(icon: Icons.location_on_outlined, title: 'Change Location', widget: UserCitySelectScreen(isBack: true)));
  list.add(SettingItemModel(icon: Icons.language, title: 'Language'));
  list.add(SettingItemModel(icon: Icons.wb_sunny_outlined, title: 'DarkMode'));
  list.add(SettingItemModel(icon: Icons.info_outline, title: 'About Us'));
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

List<AppModel> getReasonList() {
  List<AppModel> list = [];
  list.add(AppModel(name: 'Personal Reason'));
  list.add(AppModel(name: 'I have change my mind'));
  list.add(AppModel(name: 'I place duplicate order'));
  list.add(AppModel(name: 'Tutoring no longer needed'));
  list.add(AppModel(name: 'I do not need this order any more'));
  list.add(AppModel(name: 'Payment declined'));
  list.add(AppModel(name: 'Delivery date missed'));

  return list;
}
