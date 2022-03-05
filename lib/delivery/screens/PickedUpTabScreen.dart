import 'package:flutter/material.dart';

class PickedUpTabScreen extends StatefulWidget {
  @override
  PickedUpTabScreenState createState() => PickedUpTabScreenState();
}

class PickedUpTabScreenState extends State<PickedUpTabScreen> {
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
    return Scaffold();
  }
}
