import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class CreateOrderScreen extends StatefulWidget {
  static String tag = '/CreateOrderScreen';

  @override
  CreateOrderScreenState createState() => CreateOrderScreenState();
}

class CreateOrderScreenState extends State<CreateOrderScreen> {
  int selectedIndex = 0;
  bool isDeliverNow = true;

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
    return Scaffold(
      body: Stack(
        children: [
          customAppBarWidget(context, 'Create Order', isShowBack: true),
          containerWidget(
            context,
            SingleChildScrollView(
              padding: EdgeInsets.only(left: 16, top: 30, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Container(
                        margin: EdgeInsets.only(left: 8, right: 8),
                        color: selectedIndex == index ? colorPrimary : borderColor,
                        height: 5,
                      ).onTap(() {
                        selectedIndex = index;
                        setState(() {});
                      }).expand();
                    }).toList(),
                  ),
                  30.height,
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: boxDecorationWithRoundedCorners(border: Border.all(color: borderColor)),
                        child: Column(
                          children: [
                            ImageIcon(AssetImage('assets/icons/ic_clock.png'),size: 30),
                            Text('Deliver Now',style: boldTextStyle()),
                            ImageIcon(AssetImage('assets/icons/ic_schedule.png'),size: 30),
                          ],
                        ),
                      ).expand(),
                      Container().expand(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: commonButton('Create Order', () {}).paddingAll(16),
    );
  }
}
