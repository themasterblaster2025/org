import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/screens/ChangePasswordScreen.dart';
import 'package:mighty_delivery/main/screens/EditProfileScreen.dart';
import 'package:mighty_delivery/main/screens/LanguageScreen.dart';
import 'package:mighty_delivery/main/screens/ThemeScreen.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/DataProviders.dart';
import 'package:mighty_delivery/user/screens/DraftOrderListScreen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountFragment extends StatefulWidget {
  static String tag = '/AccountFragment';

  @override
  AccountFragmentState createState() => AccountFragmentState();
}

class AccountFragmentState extends State<AccountFragment> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => SingleChildScrollView(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 30),
        child: Column(
          children: [
            commonCachedNetworkImage(getStringAsync(USER_PROFILE_PHOTO).validate(), height: 90, width: 90, fit: BoxFit.cover).cornerRadiusWithClipRRect(50),
            12.height,
            Text(getStringAsync(NAME).validate(), style: boldTextStyle(size: 20)),
            6.height,
            Text(appStore.userEmail.validate(), style: secondaryTextStyle(size: 16)),
            16.height,
            ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                settingItemWidget(Icons.drafts, language.drafts, () {
                  DraftOrderListScreen().launch(context);
                }),
                settingItemWidget(Icons.person_outline, language.edit_profile, () {
                  EditProfileScreen().launch(context);
                }),
                settingItemWidget(Icons.lock_outline, language.change_password, () {
                  ChangePasswordScreen().launch(context);
                }),
                settingItemWidget(Icons.language, language.language, () {
                  LanguageScreen().launch(context);
                }),
                settingItemWidget(Icons.wb_sunny_outlined, language.theme, () {
                  ThemeScreen().launch(context);
                }),
                settingItemWidget(Icons.info_outline, language.about_us, () {
                  launch('https://www.google.com/');
                }),
                settingItemWidget(Icons.help_outline, language.help_and_support, () {
                  launch('https://www.google.com/');
                }),
                settingItemWidget(
                  Icons.logout,
                  language.logout,
                  () async {
                    await showConfirmDialogCustom(
                      context,
                      primaryColor: colorPrimary,
                      title: language.logout_confirmation_msg,
                      positiveText: language.yes,
                      negativeText: language.cancel,
                      onAccept: (c) {
                        logout(context);
                      },
                    );
                  },
                  isLast: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
