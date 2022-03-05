import 'package:flutter/material.dart';

class ArrivedTabScreen extends StatefulWidget {

  @override
  ArrivedTabScreenState createState() => ArrivedTabScreenState();
}
class ArrivedTabScreenState extends State<ArrivedTabScreen> {

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