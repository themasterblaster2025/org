import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/list_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/num_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/double_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';

import '../../extensions/common.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/models/StoreListModel.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Images.dart';
import '../screens/ProductListScreen.dart';

class StoreItemComponent extends StatefulWidget {
  final StoreData store;
  final Function()? onUpdate;

  StoreItemComponent({required this.store, this.onUpdate});

  @override
  StoreItemComponentState createState() => StoreItemComponentState();
}

class StoreItemComponentState extends State<StoreItemComponent> {
  String currentDay = DateFormat('EEEE').format(DateTime.now()).substring(0, 3).toLowerCase();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

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

  @override
  Widget build(BuildContext context) {
    // String start = widget.store.workingHours.validate().firstWhere((element) => element.day == currentDay).start.validate();
    // String end = widget.store.workingHours.validate().firstWhere((element) => element.day == currentDay).end.validate();
    // TimeOfDay startTime = TimeOfDay(hour: start.split(":").first.toInt(), minute: start.split(":").last.toInt());
    // TimeOfDay endTime = TimeOfDay(hour: end.split(":").first.toInt(), minute: end.split(":").last.toInt());
    // int startTimeSecond = (startTime.hour * 60 + startTime.minute) * 60;
    // int endTimeSecond = (endTime.hour * 60 + endTime.minute) * 60;
    // int currentTimeSecond = (DateTime.now().hour * 60 + DateTime.now().minute) * 60;
    return InkWell(
      borderRadius: radius(16),
      hoverColor: Colors.white,
      onTap: () {
        if (getIntAsync(CITY_ID) == widget.store.cityId.validate()) {
          // if (currentTimeSecond > startTimeSecond && currentTimeSecond < endTimeSecond) { // todo
          ProductListScreen(store: widget.store).launch(context);
          // }
        } else {
          toast("rightNowStoreNotAvailable"); // todo
          // toast(language.rightNowStoreNotAvailable);
        }
      },
      child: Container(
        // margin: EdgeInsets.only(bottom: 16),
        decoration: appStore.isDarkMode
            ? boxDecorationWithRoundedCorners(
                borderRadius: BorderRadius.circular(defaultRadius),
                backgroundColor: context.cardColor)
            : boxDecorationRoundedWithShadow(defaultRadius.toInt(),
                shadowColor: Colors.grey.withOpacity(0.19)),
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
                              : Icon(Icons.favorite_border, size: 18),
                          decoration:
                              BoxDecoration(shape: BoxShape.circle, color: Colors.white),
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
              ],
            ).expand(),
          ],
        ).paddingAll(10),
        /* Column(
          children: [
            Center(
                child: Text(widget.store.storeName.validate(),
                    style: boldTextStyle(size: 15,),)),
            8.height,
            Stack(
              children: [
                commonCachedNetworkImage(ic_logo,
                        height: 120, width: context.width(), fit: BoxFit.cover)
                    .cornerRadiusWithClipRRectOnly(topLeft: 8, topRight: 8),
                Positioned(
                  right: 8,
                  top: 8,
                  child: InkWell(
                    onTap: () {
                      // saveFavourite();
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.favorite_border, size: 22),
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            8.height,
            commonWidget(Icons.phone, widget.store.contactNumber.validate()),
            8.height,
            commonWidget(Icons.location_on_rounded, widget.store.address.validate())
          ],
        ).paddingAll(10),*/
      ).paddingOnly(left: 8, right: 8),
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
        Text(
          '(${store.rating.validate().length})',
          style: secondaryTextStyle(size: 12),
        ),
      ],
    ).paddingTop(6);
  }
}
