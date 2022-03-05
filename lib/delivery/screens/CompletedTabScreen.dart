import 'package:flutter/material.dart';

class CompletedTabScreen extends StatefulWidget {
  @override
  CompletedTabScreenState createState() => CompletedTabScreenState();
}

class CompletedTabScreenState extends State<CompletedTabScreen> {
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
