import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/user/screens/CreateOrderScreen.dart';
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
    return Center(
      child: AppButton(
        child: Text('Create Order',style: TextStyle(color: Colors.white)),
        color: colorPrimary,
        onTap: () {
          CreateOrderScreen().launch(context);
        },
      ),
    );
  }
}
