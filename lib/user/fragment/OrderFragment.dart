import 'package:flutter/material.dart';
import 'package:mighty_delivery/user/components/OrderComponent.dart';
import 'package:mighty_delivery/user/screens/OrderDetailScreen.dart';
import 'package:nb_utils/nb_utils.dart';

class OrderFragment extends StatefulWidget {
  static String tag = '/OrderFragment';

  @override
  OrderFragmentState createState() => OrderFragmentState();
}

class OrderFragmentState extends State<OrderFragment> {
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
    return ListView(
      padding: EdgeInsets.all(16),
      children: List.generate(5, (index) {
        return GestureDetector(
          child: OrderComponent(),
          onTap: (){
            OrderDetailScreen().launch(context,pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
          },
        );
      }).toList(),
    );
  }
}
