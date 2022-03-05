import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';

class ActiveTabScreen extends StatefulWidget {
  @override
  ActiveTabScreenState createState() => ActiveTabScreenState();
}

class ActiveTabScreenState extends State<ActiveTabScreen> {
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
    return ListView(
      shrinkWrap: true,
      //controller: scrollController,
      padding: EdgeInsets.all(16),
      children: [
        GestureDetector(
          child: Container(
            //height: 300,
            margin: EdgeInsets.only(bottom: 16),
            decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt()),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('# 2', style: secondaryTextStyle(size: 16)).expand(),
                    Container(
                      decoration: BoxDecoration(color: statusColor('draft'), borderRadius: BorderRadius.circular(defaultRadius)),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('draft'.validate(value: "draft"), style: primaryTextStyle(color: white)),
                    ),
                  ],
                ),
                4.height,
                Row(
                  children: [
                    Image.network(
                      'https://www.diethelmtravel.com/wp-content/uploads/2016/04/bill-gates-wealthiest-person.jpg',
                      height: 30,
                      width: 30,
                      color: Colors.grey,
                      fit: BoxFit.cover,
                    ).cornerRadiusWithClipRRect(4),
                    8.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jay Patel', style: boldTextStyle()),
                        4.height,
                        Row(
                          children: [
                            Text('05 Mar 2022 at 12:48 Pm', style: secondaryTextStyle())
                            /*item.date != null ? Text(printDate(item.date!), style: secondaryTextStyle()).expand() : SizedBox(),
                            Text('\u{20B9}${item.totalAmount}', style: boldTextStyle()),*/
                          ],
                        ),
                      ],
                    ).expand(),
                  ],
                ),
                Divider(height: 30, thickness: 1),
                Row(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(Icons.location_on, color: colorPrimary),
                        Text('...', style: boldTextStyle(size: 20, color: colorPrimary)),
                      ],
                    ),
                    8.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Picked at 4:45', style: secondaryTextStyle()),
                        4.height,
                        Text('jhfgjkagsfjknbkhdlkhkjhjklhljkhknk', style: primaryTextStyle()),
                        4.height,
                        Row(
                          children: [
                            Icon(Icons.call, color: Colors.green, size: 18),
                            8.width,
                            Text('498796454649', style: primaryTextStyle()),
                          ],
                        ),
                      ],
                    ).expand(),
                  ],
                ),
                16.height,
                Row(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('...', style: boldTextStyle(size: 20, color: colorPrimary)),
                        Icon(Icons.location_on, color: colorPrimary),
                      ],
                    ),
                    8.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Delivered at 4:53', style: secondaryTextStyle()),
                        4.height,
                        Text('hkjhdadfljj;.jlkj;.n', style: primaryTextStyle()),
                        4.height,
                        Row(
                          children: [
                            Icon(Icons.call, color: Colors.green, size: 18),
                            8.width,
                            Text('496465498346646', style: primaryTextStyle()),
                          ],
                        ),
                      ],
                    ).expand(),
                  ],
                ),
                Divider(height: 30, thickness: 1),
                Row(
                  children: [
                    Container(
                      decoration: boxDecorationWithRoundedCorners(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      padding: EdgeInsets.all(8),
                      child: Image.network(parcelTypeIcon('document'), height: 24, width: 24, color: Colors.grey),
                    ),
                    8.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /*Text(parcelType.validate(), style: boldTextStyle()),
                        4.height,
                        Row(
                          children: [
                            item.date != null ? Text(printDate(item.date!), style: secondaryTextStyle()).expand() : SizedBox(),
                            Text('\u{20B9}${item.totalAmount}', style: boldTextStyle()),
                          ],
                        ),*/
                      ],
                    ).expand(),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {
            //
          },
        )
      ],
    );
  }
}
