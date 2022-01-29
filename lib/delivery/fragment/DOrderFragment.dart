import 'package:flutter/material.dart';
import 'package:mighty_delivery/delivery/components/OrderWidgetsScreen.dart';
import 'package:mighty_delivery/delivery/screens/DeliveryDetailScreen.dart';
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
    return Scaffold(
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (_, index) {
          return OrderWidgetsScreen(
            name: 'Track',
            onTap: () {
              DeliveryDetailScreen().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
            },
          );
        },
      ),
    );
  }
}
