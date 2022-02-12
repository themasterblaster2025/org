import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TrackOrderScreen extends StatefulWidget {
  static String tag = '/TrackOrderScreen';

  @override
  TrackOrderScreenState createState() => TrackOrderScreenState();
}

class TrackOrderScreenState extends State<TrackOrderScreen> {
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
      appBar: appBarWidget('Track Order', color: colorPrimary, textColor: white, elevation: 0),
      body: BodyCornerWidget(
        child: ListView(
          padding: EdgeInsets.all(16),
          shrinkWrap: true,
          children: List.generate(5, (index) {
            return TimelineTile(
              alignment: TimelineAlign.start,
              isFirst: index == 0 ? true : false,
              isLast: index == 4 ? true : false,
              indicatorStyle: IndicatorStyle(
                width: 20,
                color: colorPrimary,
              ),
              afterLineStyle: LineStyle(
                color: colorPrimary,
                thickness: 5,
              ),
              beforeLineStyle: LineStyle(
                color: colorPrimary,
                thickness: 5,
              ),
              endChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Placed', style: boldTextStyle()),
                  8.height,
                  Text('12 may 2020, 08:00 AM', style: secondaryTextStyle()),
                ],
              ).paddingAll(24),
            );
          }).toList(),
        ),
      ),
    );
  }
}
