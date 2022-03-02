import 'package:flutter/material.dart';
import 'package:mighty_delivery/delivery/components/NewOrderWidget.dart';
import 'package:mighty_delivery/delivery/screens/ReceivedScreenOrderScreen.dart';
import 'package:nb_utils/nb_utils.dart';

class DOrderFragment extends StatefulWidget {
  @override
  DOrderFragmentState createState() => DOrderFragmentState();
}

class DOrderFragmentState extends State<DOrderFragment> {
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
    return ListView.builder(
      padding: EdgeInsets.all(16),
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder: (_, index) {
        return NewOrderWidget(
          name: 'Take Parcel',
          onTap: () {
            ReceivedScreenOrderScreen().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
          },
        );;
      },
    );
  }
}
