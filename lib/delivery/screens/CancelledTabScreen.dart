import 'package:flutter/material.dart';

class CancelledTabScreen extends StatefulWidget {
  @override
  CancelledTabScreenState createState() => CancelledTabScreenState();
}

class CancelledTabScreenState extends State<CancelledTabScreen> {
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
