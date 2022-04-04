import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/screens/LanguageScreen.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main/screens/AboutUsScreen.dart';
import '../../main/screens/ChangePasswordScreen.dart';
import '../../main/screens/EditProfileScreen.dart';
import '../../main/screens/ThemeScreen.dart';
import '../../main/components/UserCitySelectScreen.dart';

class DProfileFragment extends StatefulWidget {
  @override
  DProfileFragmentState createState() => DProfileFragmentState();
}

class DProfileFragmentState extends State<DProfileFragment> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    LiveStream().on('UpdateLanguage', (p0) {
      setState(() {});
    });
    LiveStream().on('UpdateTheme', (p0) {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language.profile)),
      body: Observer(
        builder: (_) => BodyCornerWidget(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                commonCachedNetworkImage(getStringAsync(USER_PROFILE_PHOTO).validate(), height: 90, width: 90, fit: BoxFit.cover).cornerRadiusWithClipRRect(50),
                12.height,
                Text(getStringAsync(NAME).validate(), style: boldTextStyle(size: 20)),
                6.height,
                Text(appStore.userEmail, style: secondaryTextStyle(size: 16)),
                16.height,
                ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    settingItemWidget(Icons.person_outline, language.editProfile, () {
                      EditProfileScreen().launch(context);
                    }),
                    settingItemWidget(Icons.lock_outline, language.changePassword, () {
                      ChangePasswordScreen().launch(context);
                    }),
                    settingItemWidget(Icons.location_on_outlined, language.changeLocation, () {
                      UserCitySelectScreen(isBack: true).launch(context);
                    }),
                    settingItemWidget(Icons.language, language.language, () {
                      LanguageScreen().launch(context);
                    }),
                    settingItemWidget(Icons.wb_sunny_outlined, language.theme, () {
                      ThemeScreen().launch(context);
                    }),
                    settingItemWidget(Icons.assignment_outlined,language.privacyPolicy, () {
                      launch(mPrivacyPolicy);
                    }),
                    settingItemWidget(Icons.help_outline, language.helpAndSupport, () {
                      launch(mHelpAndSupport);
                    }),
                    settingItemWidget(Icons.assignment_outlined, language.termAndCondition, () {
                      launch(mTermAndCondition);
                    }),
                    settingItemWidget(Icons.info_outline, language.aboutUs, () {
                      AboutUsScreen().launch(context);
                    }),
                    settingItemWidget(
                      Icons.logout,
                      language.logout,
                      () async {
                        await showConfirmDialogCustom(
                          context,
                          primaryColor: colorPrimary,
                          title: language.logoutConfirmationMsg,
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
        ),
      ),
    );
  }
}
