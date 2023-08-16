import 'package:flutter/material.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../utils/Widgets.dart';

class LanguageScreen extends StatefulWidget {
  static String tag = '/LanguageScreen';

  @override
  LanguageScreenState createState() => LanguageScreenState();
}

class LanguageScreenState extends State<LanguageScreen> {
  int? currentIndex = 0;

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
    return Scaffold(
      appBar: commonAppBarWidget(language.language),
      body: ListView(
        padding: EdgeInsets.only(bottom: 16),
        shrinkWrap: true,
        children: List.generate(localeLanguageList.length, (index) {
          LanguageDataModel data = localeLanguageList[index];
          return Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 16),
            decoration: boxDecorationWithRoundedCorners(border: Border.all(color: getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: defaultLanguage) == data.languageCode ? colorPrimary : dividerColor)),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: defaultLanguage) == data.languageCode
                        ? Icon(Icons.check_box_sharp, size: 20, color: colorPrimary)
                        : Icon(Icons.check_box_outline_blank_sharp, size: 20, color: dividerColor),
                    8.width,
                    Text('${data.name.validate()}', style: primaryTextStyle()),
                  ],
                ),
                Image.asset(data.flag.validate(), width: 34,height: 34).cornerRadiusWithClipRRect(4),
              ],
            ),
          ).onTap(
            () async {
              await setValue(SELECTED_LANGUAGE_CODE, data.languageCode);
              selectedLanguageDataModel = data;
              appStore.setLanguage(data.languageCode!, context: context);
              setState(() {});
              LiveStream().emit('UpdateLanguage');
              finish(context);
            },splashColor: Colors.transparent,highlightColor: Colors.transparent
          );
        }),
      ),
    );
  }
}
