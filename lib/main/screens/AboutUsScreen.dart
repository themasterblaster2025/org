import 'package:flutter/material.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../components/BodyCornerWidget.dart';

class AboutUsScreen extends StatefulWidget {
  static String tag = '/AboutUsScreen';

  @override
  AboutUsScreenState createState() => AboutUsScreenState();
}

class AboutUsScreenState extends State<AboutUsScreen> {
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
      appBar: AppBar(title: Text(language.aboutUs)),
      body: BodyCornerWidget(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(mAppName, style: primaryTextStyle(size: 24)),
              16.height,
              Container(
                decoration: BoxDecoration(color: colorPrimary, borderRadius: radius(4)),
                height: 4,
                width: 100,
              ),
              16.height,
              Text(language.version, style: secondaryTextStyle()),
              4.height,
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (_, snap) {
                  if (snap.hasData) {
                    return Text('${snap.data!.version.validate()}', style: secondaryTextStyle());
                  }
                  return SizedBox();
                },
              ),
              16.height,
              Text(
                mAppDes,
                style: primaryTextStyle(size: 14),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: AppButton(
              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
              color: colorPrimary,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.contact_support_outlined, color: Colors.white),
                  8.width,
                  Text(language.contactUs, style: boldTextStyle(color: white)),
                ],
              ),
              onTap: () {
                launch('mailto:$mContactPref');
              },
            ),
          ),
          16.height,
          Align(
            alignment: Alignment.topRight,
            child: AppButton(
              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
              color: colorPrimary,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/icons/ic_purchase.png', height: 24, color: white),
                  8.width,
                  Text(language.purchase, style: boldTextStyle(color: white)),
                ],
              ),
              onTap: () {
                launch(mCodeCanyonURL);
              },
            ),
          ),
        ],
      ).paddingAll(16),
    );
  }
}
