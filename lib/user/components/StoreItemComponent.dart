import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/extensions/extension_util/bool_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/num_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';

import '../../extensions/common.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/models/StoreListModel.dart';
import '../../main/models/WorkHoursListModel.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../screens/ProductListScreen.dart';

class StoreItemComponent extends StatefulWidget {
  final StoreData store;
  final Function()? onUpdate;

  StoreItemComponent({required this.store, this.onUpdate});

  @override
  StoreItemComponentState createState() => StoreItemComponentState();
}

class StoreItemComponentState extends State<StoreItemComponent> {
  String currentDay = DateFormat('EEEE').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {}

  saveFavourite() async {
    Map req = {"store_detail_id": widget.store.id};
    appStore.setLoading(true);
    await saveFavouriteStore(req).then((value) {
      appStore.setLoading(false);
      if (widget.store.isFavourite.validate() == 1) {
        widget.store.isFavourite = 0;
      } else {
        widget.store.isFavourite = 1;
      }
      setState(() {});
      widget.onUpdate?.call();
      toast(value.message);
    }).catchError((e) {
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget commonWidget(IconData? icon, String? title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14),
        8.width,
        Text(title.validate(), style: boldTextStyle(size: 13)).expand(),
      ],
    );
  }

  String getTime(second) {
    String time = '';
    time = (second / 60).toInt().toString();
    return time;
  }

  int convertToSeconds(int hours, int min, String period) {
    int hoursIn24Format = hours;
    if (period == 'pm' && hours != 12) {
      hoursIn24Format += 12;
    } else if (period == 'am' && hours == 12) {
      hoursIn24Format = 0;
    }
    int totalSeconds = hoursIn24Format * 3600 + min * 60;

    return totalSeconds;
  }

  @override
  Widget build(BuildContext context) {
    String start = widget.store.workHours!.firstWhere((element) => element.day == currentDay).startTime.validate();
    String end = widget.store.workHours!.firstWhere((element) => element.day == currentDay).endTime.validate();
    int isOpen = widget.store.workHours!.firstWhere((element) => element.day == currentDay).storeOpenClose.validate();

    List<String> hourMinute = start.split(' ')[0].split(':');
    int startHour = int.parse(hourMinute[0]);
    int startMin = int.parse(hourMinute[1]);
    String startPart = start.split(' ')[1];
    int startTimeSecond = convertToSeconds(startHour, startMin, startPart);

    int endHour = end.split(":").first.toInt();
    int endMin = (end.split(":")[1]).substring(0, 1).toInt();
    String endPart = end.split(":")[1].substring(3, 5);
    int endTimeSecond = convertToSeconds(endHour, endMin, endPart);
    int currentTimeSecond = (DateTime.now().hour * 60 + DateTime.now().minute) * 60;

    return InkWell(
      borderRadius: radius(16),
      hoverColor: Colors.white,
      onTap: () {
        if (getIntAsync(CITY_ID) == widget.store.cityId.validate()) {
          if (currentTimeSecond > startTimeSecond && currentTimeSecond < endTimeSecond && isOpen == 1) {
            ProductListScreen(store: widget.store).launch(context);
          }
        } else {
          toast(language.rightNowStoreNotAvailable);
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: appStore.isDarkMode
                ? boxDecorationWithRoundedCorners(
                    borderRadius: BorderRadius.circular(defaultRadius),
                  )
                : boxDecorationRoundedWithShadow(defaultRadius.toInt(), shadowColor: Colors.grey.withOpacity(0.19)),
            child: Row(
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        commonCachedNetworkImage(widget.store.storeImage.validate(),
                                height: 105, width: 90, fit: BoxFit.cover)
                            .cornerRadiusWithClipRRect(8),
                        Positioned(
                          right: 7,
                          top: 7,
                          child: InkWell(
                            onTap: () {
                              saveFavourite();
                            },
                            child: Container(
                              padding: EdgeInsets.all(3),
                              child: widget.store.isFavourite.validate() == 1
                                  ? Icon(Icons.favorite, size: 18, color: Colors.red)
                                  : Icon(
                                      Icons.favorite_border,
                                      size: 18,
                                      color: Colors.black,
                                    ),
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ratingWidget(widget.store),
                  ],
                ),
                10.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.store.storeName.validate(),
                      style: boldTextStyle(
                        size: 16,
                      ),
                    ),
                    8.height,
                    commonWidget(Icons.phone, widget.store.contactNumber.validate()),
                    8.height,
                    commonWidget(Icons.location_on_rounded, widget.store.address.validate()),
                    if (currentTimeSecond < startTimeSecond && isOpen == 1) ...[
                      8.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timelapse,
                            size: 15,
                            color: Colors.green.shade600,
                          ),
                          8.width,
                          Text("${language.openIn} ${getTime(startTimeSecond - currentTimeSecond)} ${language.min}",
                              style: boldTextStyle(
                                size: 13,
                                color: Colors.green.shade600,
                              )).expand(),
                        ],
                      )
                    ],
                  ],
                ).expand(),
              ],
            ).paddingAll(10),
          ).paddingOnly(left: 8, right: 8, top: 18),
          if ((currentTimeSecond > endTimeSecond && !(currentTimeSecond < startTimeSecond)) || isOpen == 0)
            Positioned(
              top: 8,
              right: isRTL ? null : 20,
              left: isRTL ? 20 : null,
              child: Container(
                decoration: boxDecorationWithShadow(
                  borderRadius: BorderRadius.circular(30),
                  spreadRadius: 1,
                  blurRadius: 1,
                  backgroundColor: Colors.red,
                ),
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timelapse, color: Colors.white, size: 14),
                    4.width,
                    Text(language.closed, style: secondaryTextStyle(color: Colors.white, size: 14)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget ratingWidget(StoreData store) {
    return Wrap(
      spacing: 2,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        RatingBarIndicator(
          rating: store.averageRating.validate().toDouble(),
          itemBuilder: (context, index) => Icon(
            Icons.star,
            color: Colors.orange,
          ),
          itemCount: 5,
          itemSize: 12.0,
          direction: Axis.horizontal,
        ),
        Text(
          "${store.averageRating.validate()}",
          style: boldTextStyle(color: Colors.orangeAccent, size: 12),
        ),
        /*Text(
          '(${store.rating.validate().length})',
          style: secondaryTextStyle(size: 12),
        ),*/
      ],
    ).paddingTop(6);
  }
}
