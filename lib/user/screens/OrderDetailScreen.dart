import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/CityListModel.dart';
import 'package:mighty_delivery/main/models/CountryListModel.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeline_tile/timeline_tile.dart';

import 'TrackOrderScreen.dart';

class OrderDetailScreen extends StatefulWidget {
  static String tag = '/OrderDetailScreen';

  final OrderData orderData;

  OrderDetailScreen({required this.orderData});

  @override
  OrderDetailScreenState createState() => OrderDetailScreenState();
}

class OrderDetailScreenState extends State<OrderDetailScreen> {
  CityModel? cityData;
  num weightCharge = 0;
  num distanceCharge = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    cityData = CityModel.fromJson(getJSONAsync(CITY_DATA));
    /// calculate weight Charge
    if (widget.orderData.totalWeight! > cityData!.minWeight!) {
      weightCharge = ((widget.orderData.totalWeight!.toDouble() - cityData!.minWeight!) * cityData!.perWeightCharges!).toStringAsFixed(2).toDouble();
    }

    /// calculate distance Charge
    if (widget.orderData.totalDistance! > cityData!.minDistance!) {
      distanceCharge = ((widget.orderData.totalDistance! - cityData!.minDistance!) * cityData!.perDistanceCharges!).toStringAsFixed(2).toDouble();
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('Order Details', color: colorPrimary, textColor: white, elevation: 0),
      body: BodyCornerWidget(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#${widget.orderData.id}', style: boldTextStyle()),
                  Text('${widget.orderData.status}', style: boldTextStyle(color: statusColor(widget.orderData.status ?? ""))),
                ],
              ),
              8.height,
              Text(printDate(widget.orderData.date!), style: secondaryTextStyle()),
              16.height,
              Text('Payment Method', style: secondaryTextStyle(size: 16)),
              8.height,
              Text('Cash on Delivery', style: boldTextStyle()),
              Row(
                children: [
                  Column(
                    children: [
                      TimelineTile(
                        alignment: TimelineAlign.start,
                        isFirst: true,
                        indicatorStyle: IndicatorStyle(width: 15, color: colorPrimary),
                        afterLineStyle: LineStyle(color: colorPrimary, thickness: 3),
                        endChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Picked at ${printDate(DateTime.now().toString())}', style: secondaryTextStyle(size: 16)),
                            8.height,
                            Text('${widget.orderData.pickupPoint!.address}', style: boldTextStyle()),
                          ],
                        ).paddingAll(16),
                      ),
                      TimelineTile(
                        alignment: TimelineAlign.start,
                        isLast: true,
                        indicatorStyle: IndicatorStyle(width: 15, color: colorPrimary),
                        beforeLineStyle: LineStyle(color: colorPrimary, thickness: 3),
                        endChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Delivered at ${printDate(DateTime.now().toString())}', style: secondaryTextStyle(size: 16)),
                            8.height,
                            Text('${widget.orderData.deliveryPoint!.address}', style: boldTextStyle()),
                          ],
                        ).paddingAll(16),
                      ),
                    ],
                  ).expand(),
                  Icon(
                    Icons.navigate_next,
                    color: Colors.grey,
                  ).onTap(() {
                    TrackOrderScreen().launch(context);
                  }),
                ],
              ),
              16.height,
              Text('Distance', style: secondaryTextStyle(size: 16)),
              8.height,
              Text('${widget.orderData.totalDistance} ${CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).distance_type}', style: boldTextStyle()),
              Divider(height: 30, thickness: 1),
              Text('Package details', style: boldTextStyle(size: 18)),
              16.height,
              Text('Parcel Type', style: secondaryTextStyle(size: 16)),
              8.height,
              Text('${widget.orderData.parcelType}', style: boldTextStyle()),
              16.height,
              Text('Total Weight', style: secondaryTextStyle(size: 16)),
              8.height,
              Text('${widget.orderData.totalWeight} ${CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).weight_type}', style: boldTextStyle()),
              Divider(height: 30, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Charge', style: primaryTextStyle()),
                  16.width,
                  Text('$currencySymbol ${widget.orderData.fixedCharges}', style: boldTextStyle()),
                ],
              ),
              Column(
                children: [
                  8.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Distance Charge', style: primaryTextStyle()),
                      16.width,
                      Text('$currencySymbol $distanceCharge', style: boldTextStyle()),
                    ],
                  )
                ],
              ).visible(distanceCharge != 0),
              Column(
                children: [
                  8.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Weight Charge', style: primaryTextStyle()),
                      16.width,
                      Text('$currencySymbol $weightCharge', style: boldTextStyle()),
                    ],
                  ),
                ],
              ).visible(weightCharge!=0),
              Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  children: [
                    8.height,
                    Text('$currencySymbol ${cityData!.fixedCharges! + distanceCharge + weightCharge}', style: boldTextStyle()),
                  ],
                ),
              ).visible(weightCharge!=0 || distanceCharge!=0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  Text('Extra Charges', style: boldTextStyle()),
                  8.height,
                  Column(
                      children: List.generate(widget.orderData.extraCharges.keys.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(widget.orderData.extraCharges.keys.elementAt(index).replaceAll("_", " "), style: primaryTextStyle()),
                              16.width,
                              Text('$currencySymbol ${widget.orderData.extraCharges.values.elementAt(index)}', style: boldTextStyle()),
                            ],
                          ),
                        );
                      }).toList()),
                ],
              ).visible(widget.orderData.extraCharges.keys.length != 0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: colorPrimary, borderRadius: BorderRadius.circular(defaultRadius)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: boldTextStyle(color: white)),
            Text('$currencySymbol ${widget.orderData.totalAmount}', style: boldTextStyle(color: white)),
          ],
        ),
      ).paddingAll(16),
    );
  }
}
