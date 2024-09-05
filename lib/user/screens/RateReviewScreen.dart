import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/extensions/shared_pref.dart';
import 'package:mighty_delivery/extensions/system_utils.dart';
import 'package:mighty_delivery/main/models/StoreListModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';

import '../../extensions/app_text_field.dart';
import '../../extensions/common.dart';
import '../../extensions/decorations.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Widgets.dart';
import '../../main/utils/dynamic_theme.dart';

class RateReviewScreen extends StatefulWidget {
  static String tag = '/RateReviewscreen';
  final int storId;
  final int orderId;
  int? ratingId;

  RateReviewScreen({required this.storId, required this.orderId, this.ratingId});

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  double _rating = 0;
  TextEditingController reviewController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  StoreData? store;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setLoading(true);
    await getStoreDetail(widget.storId).then((value) {
      setState(() {
        store = value;
      });
      appStore.setLoading(false);
    }).catchError((error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: language.rateUs,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  commonCachedNetworkImage(store?.storeImage.validate(), height: 95, width: 90, fit: BoxFit.cover)
                      .cornerRadiusWithClipRRect(8),
                  20.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (store?.storeName).validate(),
                        style: boldTextStyle(
                          size: 21,
                        ),
                      ),
                      8.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.phone, size: 14),
                          8.width,
                          Text((store?.contactNumber).validate(), style: boldTextStyle(size: 14)).expand(),
                        ],
                      ),
                    ],
                  ).expand(),
                ],
              ).paddingAll(10),
              Divider(
                height: 10,
                color: ColorUtils.dividerColor,
              ),
              10.height,
              Text(
                language.yourExperience,
                style: boldTextStyle(size: 18),
              ),
              18.height,
              RatingBar.builder(
                initialRating: _rating,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              40.height,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.addReview, style: boldTextStyle(size: 16)),
                  14.height,
                  AppTextField(
                      controller: reviewController,
                      textInputAction: TextInputAction.next,
                      textFieldType: TextFieldType.MULTILINE,
                      decoration: commonInputDecoration(hintText: language.excellent),
                      validator: (value) {
                        if (value!.isEmpty) return language.fieldRequiredMsg;
                      },
                      onTap: () {}),
                ],
              ),
              Spacer(),
              Row(
                children: [
                  outlineButton(language.skip, () {
                    finish(context);
                  }, color: ColorUtils.colorPrimary)
                      .paddingRight(isRTL ? 4 : 16)
                      .paddingLeft(isRTL ? 16 : 0)
                      .expand(),
                  commonButton(language.submit, () async {
                    if (_formKey.currentState!.validate()) {
                      await saveRateReviewApi(
                        widget.storId,
                        widget.orderId,
                        widget.ratingId != null ? widget.ratingId : null,
                      );
                      reviewController.clear();
                      _rating = 0;
                      finish(context);
                    }
                  }).expand()
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveRateReviewApi(int storeID, int orderId, int? id) async {
    Map req = {
      if (id != null) "id": id,
      "store_detail_id": storeID,
      "user_id": getIntAsync(USER_ID),
      "order_id": orderId,
      "rating": _rating,
      "review": reviewController.text.toString(),
    };
    appStore.setLoading(true);

    await saveRateReview(req).then((value) {
      toast(value.message.toString());
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }
}
