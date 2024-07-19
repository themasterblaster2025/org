import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/list_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/num_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main/models/StoreListModel.dart';
import 'package:mighty_delivery/main/models/WorkHoursListModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';

import '../../extensions/common.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Widgets.dart';

class StoreDetailScreen extends StatefulWidget {
  final StoreData store;

  StoreDetailScreen({required this.store});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  List<WorkHoursData> workingHoursList = [];

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    workingHoursList = widget.store.workHours!;
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: widget.store.storeName.validate(),
      body: Observer(
        builder: (context) {
          return Column(
            children: [
              ListView(
                children: [
                  10.height,
                  Container(
                    width: double.infinity,
                    child: commonCachedNetworkImage(
                      widget.store.storeImage.validate(),
                      height: (context.height() * 0.3),
                      fit: BoxFit.fitWidth,
                    ).cornerRadiusWithClipRRect(4).paddingSymmetric(horizontal: 6),
                  ),
                  10.height,
                  Row(
                    children: [
                      8.width,
                      Text(
                        widget.store.storeName.validate(),
                        style: boldTextStyle(
                          size: 20,
                        ),
                      ),
                      Spacer(),
                      /* InkWell(
                            onTap: () {
                              setState(() {
                                saveFavourite(widget.store);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(4),
                              child: widget.store.isFavourite.validate() == 1
                                  ? Icon(Icons.favorite, size: 20, color: Colors.red)
                                  : Icon(Icons.favorite_border, size: 20),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                            ),
                          ),*/
                      8.width,
                    ],
                  ),
                  Divider(
                    height: 10,
                    color: dividerColor,
                  ),
                  8.height,
                  commonWidget(Icons.phone, widget.store.contactNumber.validate()),
                  8.height,
                  Divider(
                    height: 10,
                    color: dividerColor,
                  ),
                  8.height,
                  commonWidget(Icons.location_on_rounded, widget.store.address.validate()),
                  10.height,
                  Divider(
                    height: 10,
                    color: dividerColor,
                  ),
                  10.height,
                  commonWidget(Icons.location_city,
                      "${widget.store.cityName.validate()}, ${widget.store.countryName.validate()}"),
                  10.height,
                  Divider(height: 0, color: dividerColor),
                  10.height,
                  Row(
                    children: [
                      Icon(Icons.access_time_filled_outlined, size: 16),
                      8.width,
                      Expanded(
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: workingHoursList.length,
                          itemBuilder: (context, index) {
                            return WorkHours(workingHoursList[index]);
                          },
                        ),
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 10),
                  10.height,
                  /*  Row(
                        children: [
                          Icon(Icons.rate_review,size: 16,),
                          8.width,
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${widget.store.averageRating.validate()}",
                                    style:
                                        primaryTextStyle(size: 36, color: Colors.orange),
                                  ),
                                  Text(
                                    '/5',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                              8.height,
                              RatingBarIndicator(
                                rating: widget.store.averageRating.validate().toDouble(),
                                itemBuilder: (context, index) => Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                ),
                                itemCount: 5,
                                itemSize: 25.0,
                                direction: Axis.horizontal,
                              ),
                            ],
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 10),
                      10.height,
                      Divider(
                        height: 10,
                        color: dividerColor,
                      ),*/
                  10.height,
                ],
              ).expand(),
            ],
          );
        },
      ),
    );
  }

  Widget commonWidget(IconData? icon, String? title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16),
        8.width,
        Text(title.validate(), style: boldTextStyle(size: 15)).expand(),
      ],
    ).paddingSymmetric(horizontal: 10);
  }

  Widget WorkHours(WorkHoursData day) {
    // String dayStart = DateFormat('hh:mm a').format(DateTime.parse(day.startTime.validate()).toLocal());
    return Row(
      children: [
        Text(
          day.day.validate(),
          style: boldTextStyle(size: 15),
        ),
        Spacer(),
        Text(
          day.startTime.validate() + " - " + day.endTime.validate(),
          style: boldTextStyle(size: 15),
        ).visible(day.storeOpenClose.validate() == 1),
        Text(
          language.closed,
          style: boldTextStyle(size: 15),
        ).visible(day.storeOpenClose.validate() == 0),
      ],
    ).paddingSymmetric(horizontal: 10);
  }

  Widget RateView() {
    return Row(
      children: [
        Text('i', style: TextStyle(fontSize: 16)),
        4.width,
        Icon(Icons.star, color: Colors.orange, size: 20),
        5.width,
        Container(
          width: context.width() * 0.4,
          child: LinearProgressIndicator(
            value: 0.7,
            backgroundColor: Colors.grey[500],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
        9.width
      ],
    );
  }
}

saveFavourite(StoreData store) async {
  Map req = {"store_detail_id": store.id};
  await saveFavouriteStore(req).then((value) {
    if (store.isFavourite.validate() == 1) {
      store.isFavourite = 0;
    } else {
      store.isFavourite = 1;
    }
  }).catchError((e) {
    toast(e.toString());
  });
}
