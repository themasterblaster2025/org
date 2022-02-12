import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

class DeliveryDetailScreen extends StatefulWidget {
  @override
  DeliveryDetailScreenState createState() => DeliveryDetailScreenState();
}

class DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
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
    return Scaffold(
      appBar: appBarWidget('Delivery Detail', color: colorPrimary, textColor: white, elevation: 0),
      body: BodyCornerWidget(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#561465465578', style: boldTextStyle()),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(color: colorPrimary.withOpacity(0.2), borderRadius: BorderRadius.circular(defaultRadius)),
                    child: Text('Delivered', style: boldTextStyle(color: colorPrimary)),
                  ),
                ],
              ),
              4.height,
              Text('27 May, 2020', style: primaryTextStyle(size: 15)),
              16.height,
              Container(
                padding: EdgeInsets.all(16),
                decoration: containerDecoration(),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 4, right: 8),
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(color: colorPrimary, shape: BoxShape.circle),
                            ),
                            Text('Form', style: boldTextStyle()),
                          ],
                        ),
                        8.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.home_outlined, color: colorPrimary, size: 20),
                            3.width,
                            Text('1633 Hamptom Meadows, Lexington, mumbai, near vasi road.', style: secondaryTextStyle()).expand(),
                          ],
                        ),
                      ],
                    ),
                    20.height,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 4, right: 8),
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(color: colorPrimary, shape: BoxShape.circle),
                            ),
                            Text('To', style: boldTextStyle()),
                          ],
                        ),
                        8.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.home_outlined, color: colorPrimary, size: 20),
                            3.width,
                            Text('Near bus station road, near park road, mumbai, near vasi road.', style: secondaryTextStyle()).expand(),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              16.height,
              Text('Payment Method', style: boldTextStyle()),
              8.height,
              Text('Apple pay', style: primaryTextStyle(size: 15)),
              16.height,
              Text('Parcel type', style: boldTextStyle()),
              8.height,
              Text('Document', style: primaryTextStyle(size: 15)),
              16.height,
              Divider(color: Colors.grey),
              16.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total weight', style: primaryTextStyle(size: 15)),
                  Text('5.00', style: boldTextStyle()),
                ],
              ),
              16.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total distance', style: primaryTextStyle(size: 15)),
                  Text('$currencySymbol 100.00', style: boldTextStyle()),
                ],
              ),
              16.height,
              Divider(color: Colors.grey),
              16.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Item Total', style: primaryTextStyle(size: 15)),
                  Text('$currencySymbol 5.00', style: boldTextStyle()),
                ],
              ),
              16.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Items', style: primaryTextStyle(size: 15)),
                  Text('$currencySymbol 8.00', style: boldTextStyle()),
                ],
              ),
              16.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Fixes charges', style: primaryTextStyle(size: 15)),
                  Text('$currencySymbol 100.00', style: boldTextStyle()),
                ],
              ),
              16.height,
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colorPrimary,
                ),
                child: Row(
                  children: [
                    Text('Total', style: boldTextStyle(color: white)).expand(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$currencySymbol 500', style: primaryTextStyle(color: white)),
                        4.height,
                        Text('All charge Include', style: secondaryTextStyle(color: white)),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
