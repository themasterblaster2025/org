import 'package:flutter/material.dart';
import 'package:mighty_delivery/delivery/components/OrderBottomSheetWidget.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

class NewOrderWidget extends StatefulWidget {
  final String? name;
  final Function()? onTap;

  NewOrderWidget({this.name, this.onTap});

  @override
  NewOrderWidgetState createState() => NewOrderWidgetState();
}

class NewOrderWidgetState extends State<NewOrderWidget> {
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
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: boxDecorationDefault(),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#1457894578', style: boldTextStyle(size: 14)),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius),color: colorPrimary),
                    child: Text('Order Assign',style: boldTextStyle(size: 14,color: white)),
                  ),
                ],
              ),
              16.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      commonCachedNetworkImage(
                        'https://images.squarespace-cdn.com/content/v1/5b7e685d8ab722146afd7529/1564600902218-403CMIW9V4G2UC13A25W/PP_01.jpg',
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ).cornerRadiusWithClipRRect(30),
                      16.height,
                      Text('Imran Khan', style: secondaryTextStyle(color: colorPrimary), maxLines: 2, textAlign: TextAlign.center),
                      16.height,
                      Text('$currencySymbol 150', style: boldTextStyle(), maxLines: 2),
                      16.height,
                      Icon(Icons.credit_card, color: colorPrimary)
                    ],
                  ).expand(),
                  8.width,
                  Container(height: 230, width: 1, color: grey),
                  8.width,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Box with clothes', style: boldTextStyle(), maxLines: 2),
                      8.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_outlined, color: colorPrimary, size: 18),
                          8.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('-: Picked :-', style: secondaryTextStyle(color: colorPrimary)),
                              8.height,
                              Text('Amit data near raj Cinema, navsari, 3960014 ,Gujarat, india', style: primaryTextStyle(size: 15), maxLines: 3),
                            ],
                          ).expand()
                        ],
                      ),
                      16.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_outlined, color: colorPrimary, size: 18),
                          8.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('-: Delivered :-', style: secondaryTextStyle(color: colorPrimary)),
                              8.height,
                              Text('Raj Cinema,near road, navsari, 3960014 ,Gujarat, india', style: primaryTextStyle(size: 15), maxLines: 3),
                            ],
                          ).expand()
                        ],
                      ),
                      8.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.schedule_outlined, color: colorPrimary, size: 18),
                          8.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('-: Date Time :-', style: secondaryTextStyle(color: colorPrimary)),
                              8.height,
                              Text('19.01.19 AM', style: primaryTextStyle(size: 14)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ).expand(flex: 3)
                ],
              ),
              8.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppButton(
                    padding: EdgeInsets.zero,
                    text: widget.name!,
                    color: colorPrimary,
                    textStyle: primaryTextStyle(color: white),
                    width: 150,
                    onTap: widget.onTap,
                  ),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                        ),
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
        ),
      ],
    ).paddingOnly(top: 8, bottom: 8);
  }
}
