import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/DataProviders.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class DProfileFragment extends StatefulWidget {
  @override
  DProfileFragmentState createState() => DProfileFragmentState();
}

class DProfileFragmentState extends State<DProfileFragment> {
  List<SettingItemModel> settingItems = getDeliverySettingItems();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
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
            Text(appStore.userEmail, style: secondaryTextStyle(size: 16)),
            16.height,
            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: settingItems.length,
              itemBuilder: (context, index) {
                SettingItemModel mData = settingItems[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(mData.icon, size: 30, color: colorPrimary),
                  title: Text(mData.title!),
                  trailing: Icon(Icons.navigate_next, color: Colors.grey),
                  onTap: () async {
                    if (index == 4 || index == 5) {
                      launch('https://www.google.com/');
                    }
                    if (index == 7) {
                      await showConfirmDialogCustom(
                        context,
                        primaryColor: colorPrimary,
                        title: 'Are you sure you want to logout ?',
                        positiveText: 'Yes',
                        negativeText: 'Cancel',
                        onAccept: (c) {
                          logout(context);
                        },
                      );
                    }
                    if (mData.widget != null) {
                      mData.widget.launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
                    }
                  },
                );
              },
              separatorBuilder: (context, index) {
                return Divider(indent: 50);
              },
            )
          ],
        ),
      ),
    );
  }
}
