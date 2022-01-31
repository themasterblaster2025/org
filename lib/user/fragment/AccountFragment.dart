import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/DataProviders.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountFragment extends StatefulWidget {
  static String tag = '/AccountFragment';

  @override
  AccountFragmentState createState() => AccountFragmentState();
}

class AccountFragmentState extends State<AccountFragment> {
  List<SettingItemModel> settingItems = getSettingItems();

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
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 30),
      child: Column(
        children: [
          Image.asset('assets/profile.png', height: 90, width: 90).cornerRadiusWithClipRRect(50),
          12.height,
          Text('Name', style: boldTextStyle(size: 20)),
          6.height,
          Text('name@test.com', style: secondaryTextStyle(size: 16)),
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
                  if(index==6) {
                    await showConfirmDialogCustom(
                      context,
                      primaryColor: colorPrimary,
                      title:'Are you sure you want to logout ?',
                      positiveText: 'Yes',
                      negativeText: 'Cancel',
                      onAccept: (c) {
                        logout(context);
                      },
                    );
                  }
                  if (mData.widget != null) {
                    mData.widget.launch(context);
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
    );
  }
}
