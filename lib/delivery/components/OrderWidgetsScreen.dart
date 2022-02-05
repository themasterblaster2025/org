import 'package:flutter/material.dart';
import 'package:mighty_delivery/delivery/components/OrderBottomSheetWidget.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderWidgetsScreen extends StatefulWidget {
  final Function()? onTap;
  final String? name;

  OrderWidgetsScreen({this.onTap, this.name});

  @override
  OrderWidgetsScreenState createState() => OrderWidgetsScreenState();
}

class OrderWidgetsScreenState extends State<OrderWidgetsScreen> {
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
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8),
      padding: EdgeInsets.all(16),
      width: context.width(),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black, blurRadius: 0.1),
          ],
          borderRadius: BorderRadius.circular(defaultRadius)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('OrderId#', style: boldTextStyle()),
              Text('784965464654634', style: secondaryTextStyle()),
            ],
          ),
          8.height,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Name', style: primaryTextStyle()),
              Text('jay patel', style: secondaryTextStyle()),
            ],
          ),
          8.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.schedule_outlined, color: colorPrimary, size: 20),
              Text('11/01/2022', style: secondaryTextStyle()),
            ],
          ),
          8.height,
          Row(
            children: [
              Icon(Icons.call_outlined, color: colorPrimary, size: 20).onTap(() {
                launch('tel://8320951437');
              }),
              16.width,
              Text('8320941437', style: secondaryTextStyle()),
            ],
          ),
          8.height,
          Row(
            children: [
              Icon(Icons.home_outlined, color: colorPrimary, size: 20),
              16.width,
              Text('Amit data near raj Cinema, navsari, 3960014 ,Gujarat, india', style: secondaryTextStyle()).expand(),
            ],
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppButton(
                padding: EdgeInsets.all(8),
                text: widget.name,
                color: colorPrimary,
                textStyle: boldTextStyle(color: white, size: 14),
                onTap: widget.onTap,
              ),
              Text('$currencySymbol 800', style: boldTextStyle()),
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
                    context: context,
                    builder: (_) {
                      return OrderBottomSheetWidget();
                    },
                  );
                },
                icon: Icon(Icons.arrow_circle_down_outlined, color: colorPrimary),
              )
            ],
          )
        ],
      ),
    );
  }
}
