import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Images.dart';
import '../screens/OrderDetailScreen.dart';
import '../screens/OrderTrackingScreen.dart';
import 'GenerateInvoice.dart';

class OrderCardComponent extends StatefulWidget {
  final OrderData item;

  OrderCardComponent({required this.item});

  @override
  _OrderCardComponentState createState() => _OrderCardComponentState();
}

class _OrderCardComponentState extends State<OrderCardComponent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        OrderDetailScreen(orderId: widget.item.id.validate()).launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop, duration: 400.milliseconds);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: appStore.isDarkMode
            ? boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(defaultRadius), backgroundColor: context.cardColor)
            : boxDecorationRoundedWithShadow(defaultRadius.toInt()),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${language.order}# ${widget.item.id}', style: secondaryTextStyle(size: 16)).expand(),
                Container(
                  decoration: BoxDecoration(color: statusColor(widget.item.status.validate()).withOpacity(0.15), borderRadius: BorderRadius.circular(defaultRadius)),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(orderStatus(widget.item.status!), style: boldTextStyle(color: statusColor(widget.item.status.validate()))),
                ),
              ],
            ),
            8.height,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: boxDecorationWithRoundedCorners(
                      borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor, width: appStore.isDarkMode ? 0.2 : 1), backgroundColor: Colors.transparent),
                  padding: EdgeInsets.all(8),
                  child: Image.asset(parcelTypeIcon(widget.item.parcelType.validate()), height: 24, width: 24, color: Colors.grey),
                ),
                8.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.parcelType.validate(), style: boldTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                    4.height,
                    Row(
                      children: [
                        widget.item.date != null ? Text(printDate(widget.item.date!), style: secondaryTextStyle()).expand() : SizedBox(),
                        if (widget.item.status != ORDER_CANCELLED) Text(printAmount(widget.item.totalAmount ?? 0), style: boldTextStyle()),
                      ],
                    ),
                  ],
                ).expand(),
              ],
            ),
            Divider(height: 30, thickness: 1),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.item.pickupDatetime != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(language.picked, style: boldTextStyle(size: 18)),
                      4.height,
                      Text('${language.at} ${printDate(widget.item.pickupDatetime!)}', style: secondaryTextStyle()),
                      16.height,
                    ],
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageIcon(AssetImage(ic_from), size: 24, color: colorPrimary),
                    12.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${widget.item.pickupPoint!.address}', style: primaryTextStyle()),
                        if (widget.item.pickupDatetime == null && widget.item.pickupPoint!.endTime != null && widget.item.pickupPoint!.startTime != null)
                          Text('${language.note} ${language.courierWillPickupAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(widget.item.pickupPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(widget.item.pickupPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(widget.item.pickupPoint!.endTime!).toLocal())}',
                                  style: secondaryTextStyle())
                              .paddingOnly(top: 8),
                      ],
                    ).expand(),
                    12.width,
                    if (widget.item.pickupPoint!.contactNumber != null)
                      Image.asset('assets/icons/ic_call.png', width: 24, height: 24).onTap(() {
                        commonLaunchUrl('tel:${widget.item.pickupPoint!.contactNumber}');
                      }),
                  ],
                ),
              ],
            ),
            DottedLine(dashColor: borderColor).paddingSymmetric(vertical: 16, horizontal: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.item.deliveryDatetime != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(language.delivered, style: boldTextStyle(size: 18)),
                      4.height,
                      Text('${language.at} ${printDate(widget.item.deliveryDatetime!)}', style: secondaryTextStyle()),
                      16.height,
                    ],
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageIcon(AssetImage(ic_to), size: 24, color: colorPrimary),
                    12.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${widget.item.deliveryPoint!.address}', style: primaryTextStyle()),
                        if (widget.item.deliveryDatetime == null && widget.item.deliveryPoint!.endTime != null && widget.item.deliveryPoint!.startTime != null)
                          Text('${language.note} ${language.courierWillDeliverAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(widget.item.deliveryPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(widget.item.deliveryPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(widget.item.deliveryPoint!.endTime!).toLocal())}',
                                  style: secondaryTextStyle())
                              .paddingOnly(top: 8),
                      ],
                    ).expand(),
                    12.width,
                    if (widget.item.deliveryPoint!.contactNumber != null)
                      Image.asset('assets/icons/ic_call.png', width: 24, height: 24).onTap(() {
                        commonLaunchUrl('tel:${widget.item.deliveryPoint!.contactNumber}');
                      }),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.item.status != ORDER_CANCELLED)
                  Row(
                    children: [
                      Text(language.invoice, style: primaryTextStyle(color: colorPrimary)),
                      4.width,
                      Icon(Icons.download_rounded, color: colorPrimary),
                    ],
                  ).onTap(() {
                    generateInvoiceCall(widget.item);
                  }),
                AppButton(
                  elevation: 0,
                  height: 35,
                  color: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultRadius),
                    side: BorderSide(color: colorPrimary),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(language.trackOrder, style: primaryTextStyle(color: colorPrimary)),
                      Icon(Icons.arrow_right, color: colorPrimary),
                    ],
                  ),
                  onTap: () {
                    OrderTrackingScreen(orderData: widget.item).launch(context);
                  },
                ).visible(widget.item.status == ORDER_DEPARTED || widget.item.status == ORDER_ACCEPTED),
              ],
            ).paddingOnly(top: 16),
          ],
        ),
      ),
    );
  }
}
