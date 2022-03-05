import 'package:flutter/material.dart';

class DepartedTabScreen extends StatefulWidget {
  @override
  DepartedTabScreenState createState() => DepartedTabScreenState();
}

class DepartedTabScreenState extends State<DepartedTabScreen> {
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
