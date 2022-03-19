import 'package:flutter/material.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/screens/ChangePasswordScreen.dart';
import 'package:mighty_delivery/main/screens/EditProfileScreen.dart';
import 'package:mighty_delivery/main/screens/LanguageScreen.dart';
import 'package:mighty_delivery/main/screens/ThemeScreen.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/user/components/UserCitySelectScreen.dart';
import 'package:nb_utils/nb_utils.dart';

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(id: 1, name: 'English', subTitle: 'English', languageCode: 'en', fullLanguageCode: 'en-US', flag: 'assets/flag/ic_us.png'),
    LanguageDataModel(id: 2, name: 'Hindi', subTitle: 'हिंदी', languageCode: 'hi', fullLanguageCode: 'hi-IN', flag: 'assets/flag/ic_india.png'),
    LanguageDataModel(id: 3, name: 'Arabic', subTitle: 'عربي', languageCode: 'ar', fullLanguageCode: 'ar-AR', flag: 'assets/flag/ic_ar.png'),
  ];
}

List<WalkThroughItemModel> getWalkThroughItems() {
  List<WalkThroughItemModel> list = [];
  list.add(WalkThroughItemModel(image: 'assets/walk_through1.png', title: language.walk_through1_title, subTitle: language.walk_through1_subtitle));
  list.add(WalkThroughItemModel(image: 'assets/walk_through2.png', title: language.walk_through2_title, subTitle: language.walk_through2_subtitle));
  list.add(WalkThroughItemModel(image: 'assets/walk_through3.png', title: language.walk_through3_title, subTitle: language.walk_through3_subtitle));
  return list;
}

List<SettingItemModel> getDeliverySettingItems() {
  List<SettingItemModel> list = [];
  list.add(SettingItemModel(icon: Icons.person_outline, title: language.edit_profile, widget: EditProfileScreen()));
  list.add(SettingItemModel(icon: Icons.lock_outline, title: language.change_password, widget: ChangePasswordScreen()));
  list.add(SettingItemModel(icon: Icons.location_on_outlined, title: language.change_location, widget: UserCitySelectScreen(isBack: true)));
  list.add(SettingItemModel(icon: Icons.language, title: language.language,widget: LanguageScreen()));
  list.add(SettingItemModel(icon: Icons.wb_sunny_outlined, title: language.theme,widget: ThemeScreen()));
  list.add(SettingItemModel(icon: Icons.info_outline, title: language.about_us));
  list.add(SettingItemModel(icon: Icons.help_outline, title: language.help_and_support));
  list.add(SettingItemModel(icon: Icons.logout, title: language.logout));

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
  // TODO localization
  list.add(AppModel(name: 'Personal Reason'));
  list.add(AppModel(name: 'I have change my mind'));
  list.add(AppModel(name: 'I place duplicate order'));
  list.add(AppModel(name: 'Tutoring no longer needed'));
  list.add(AppModel(name: 'I do not need this order any more'));
  list.add(AppModel(name: 'Payment declined'));
  list.add(AppModel(name: 'Delivery date missed'));

  return list;
}
