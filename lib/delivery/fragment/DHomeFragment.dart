import 'package:flutter/material.dart';
import 'package:mighty_delivery/delivery/components/OrderWidgetsScreen.dart';

class DHomeFragment extends StatefulWidget {
  @override
  DHomeFragmentState createState() => DHomeFragmentState();
}

class DHomeFragmentState extends State<DHomeFragment> {
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
        return OrderWidgetsScreen(
          name: 'Accept',
          onTap: () {
            //
          },
        );
      },
    );
  }
}
