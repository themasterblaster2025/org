import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/list_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';

import '../../extensions/common.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/models/PlaceAddressModel.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Constants.dart';
import '../../user/screens/GoogleMapScreen.dart';
import '../../user/screens/MyAddressListScreen.dart';
import '../models/AddressListModel.dart';
import '../network/RestApis.dart';
import '../utils/Common.dart';
import '../utils/dynamic_theme.dart';

class PickAddressBottomSheet extends StatefulWidget {
  final Function(AddressData) onPick;
  final bool isPickup;

  PickAddressBottomSheet({
    required this.onPick,
    this.isPickup = true,
  });

  @override
  PickAddressBottomSheetState createState() => PickAddressBottomSheetState();
}

class PickAddressBottomSheetState extends State<PickAddressBottomSheet> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
  }

  deleteUserAddressApiCall(int id) async {
    appStore.setLoading(true);
    await deleteUserAddress(id).then((value) {
      appStore.setLoading(false);
      List<String> list = getStringListAsync(RECENT_ADDRESS_LIST) ?? [];
      list.removeWhere((element) => AddressData.fromJson(jsonDecode(element)).id == id);
      setValue(RECENT_ADDRESS_LIST, list);
      setState(() {});
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: ColorUtils.colorPrimary.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.isPickup ? language.choosePickupAddress : language.chooseDeliveryAddress,
                    style: boldTextStyle()),
                8.height,
                Text(language.showingAllAddress, style: secondaryTextStyle()),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.add_circle_outline, color: ColorUtils.colorPrimary),
              10.width,
              Text(language.addNewAddress, style: boldTextStyle(color: ColorUtils.colorPrimary)),
            ],
          ).onTap(() async {
            /* if (!await Geolocator.isLocationServiceEnabled()) {
              await Geolocator.openLocationSettings().then((value) => false).catchError((e) => false);
            } else {
              PlaceAddressModel? res = await GoogleMapScreen(isPick: widget.isPickup).launch(context);
              if (res != null) {
                widget.onPick.call(res);
                finish(context);
              }
            }*/
            MyAddressListScreen().launch(context).then((value) => setState(() {}));
          }).paddingAll(16),
          Divider(color: context.dividerColor),
          Stack(
            children: [
              ListView.separated(
                itemCount: (getStringListAsync(RECENT_ADDRESS_LIST) ?? []).length,
                // itemCount: addressList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  int len = (getStringListAsync(RECENT_ADDRESS_LIST) ?? []).length;
                  AddressData mData =
                      AddressData.fromJson(jsonDecode(getStringListAsync(RECENT_ADDRESS_LIST)![len - index - 1]));
                  // AddressData mData = addressList[index];
                  return Row(
                    children: [
                      Icon(Icons.location_on_outlined),
                      10.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${mData.addressType}', style: secondaryTextStyle(size: 12), maxLines: 1),
                          Container(
                              width: context.width() * 0.82,
                              child: Text('${mData.address}', style: primaryTextStyle(), maxLines: 2)),
                        ],
                      ),
                      /* 10.width,
                     // comment this because when there is one address in list and delete it at time of deliveryAddressSelection then go back then there is issue
                      Icon(Icons.highlight_remove_outlined, color: Colors.red).onTap(() {
                        deleteUserAddressApiCall(mData.id.validate());
                      })*/
                    ],
                  ).onTap(() async {
                    widget.onPick.call(mData);
                    finish(context);
                  }).paddingSymmetric(vertical: 8, horizontal: 16);
                },
                separatorBuilder: (context, index) {
                  return Divider(color: context.dividerColor);
                },
              ),
              Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
            ],
          ).expand(),
        ],
      ),
    );
  }
}
