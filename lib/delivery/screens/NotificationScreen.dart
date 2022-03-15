import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {

  @override
  NotificationScreenState createState() => NotificationScreenState();
}
class NotificationScreenState extends State<NotificationScreen> {

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