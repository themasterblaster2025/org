import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/extensions/common.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/list_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/user/screens/RateReviewScreen.dart';
import '../../extensions/decorations.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/StoreListModel.dart';
import '../../main/models/WorkHoursListModel.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Images.dart';
import '../components/StoreItemComponent.dart';

class StoreListScreen extends StatefulWidget {
  static String tag = '/StoreListScreen';
  final int? type;

  StoreListScreen({this.type});

  @override
  StoreListScreenState createState() => StoreListScreenState();
}

class StoreListScreenState extends State<StoreListScreen> {
  TextEditingController searchController = TextEditingController();

  List<StoreData> storeList = [];
  ScrollController scrollController = ScrollController();
  int page = 1;
  int totalPage = 1;
  int totalItem = 0;
  bool isLastPage = false;

  bool isNearest = false;
  String currentDay = DateFormat('EEEE').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent &&
          !appStore.isLoading) {
        if (page < totalPage) {
          page++;
          init();
        }
      }
    });
  }

  void init() async {
    appStore.setLoading(true);
    await getStoreList(
            page: page,
            title: searchController.text.isNotEmpty ? searchController.text : null,
            isNearby: isNearest)
        .then((value) {
      totalPage = value.pagination!.totalPages.validate(value: 1);
      page = value.pagination!.currentPage.validate(value: 1);
      totalItem = value.pagination!.totalItems.validate();
      isLastPage = false;
      if (page == 1) {
        storeList.clear();
      }

      for (StoreData data in value.data!) {
        if (data.workingHours == null) {
          data.workingHours =
              WorkingHours(start: "12:00 am", end: "12:00 pm", isOpen: false, day: "");
        }
        if (widget.type.validate() != 0) {
          data.storeType.validate().forEach((element) {
            if (element.id.validate() == widget.type) {
              storeList.add(data);
            }
          });
          /* if (data.storeType!.id.validate() == widget.type) {
            storeList.add(data);
          }*/
        } else {
          storeList.add(data);
        }
      }
      appStore.setLoading(false);

      // storeList.addAll(value.data!);
      storeList.forEach((element) async {
        await getWorkingHours(element);
      });
      setState(() {});
    }).catchError((e) {
      isLastPage = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> getWorkingHours(StoreData store) async {
    appStore.setLoading(true);

    await getWorkingHoursList(storeDetailId: store.id.validate()).then((value) {
      value.data.validate().forEach((element) {
        if (element.day == currentDay && element.storeDetailId == store.id) {
          store.workingHours = WorkingHours(
            start: element.startTime,
            end: element.endTime,
            isOpen: (element.storeOpenClose.validate() == 1 ? true : false),
            day: element.day,
          );
        }
        appStore.setLoading(false);
        setState(() {});
      });
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: "Stores", //todo
      body: Observer(builder: (context) {
        return Stack(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    TextFormField(
                      controller: searchController,
                      decoration: commonInputDecoration(
                        // hintText: language.searchStores,
                        hintText: "search stores", // todo
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: searchController.text.isNotEmpty ? Icons.clear : null,
                        suffixOnTap: () {
                          searchController.clear();
                          FocusScope.of(context).requestFocus(FocusNode());
                          init();
                        },
                      ),
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (value) {
                        page = 1;
                        init();
                      },
                    ).expand(),
                    8.width,
                    FilterChip(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: radius(defaultRadius)),
                      // label: Text(language.nearest,
                      label: Text("nearest", // todo
                          style: primaryTextStyle(color: isNearest ? Colors.white : null)),
                      checkmarkColor: isNearest ? Colors.white : null,
                      selected: isNearest,
                      selectedColor: colorPrimary,
                      onSelected: (v) {
                        getCurrentLocationData(onUpdate: () {
                          isNearest = v;
                          setState(() {});
                          page = 1;
                          init();
                        });
                      },
                    ),
                  ],
                ).paddingAll(16).visible(widget.type.validate() == 0),
                storeList.isNotEmpty
                    ? ListView.builder(
                        itemBuilder: (context, index) {
                          StoreData item = storeList[index];
                          return StoreItemComponent(
                            store: item,
                          );
                        },
                        controller: scrollController,
                        itemCount: storeList.length,
                      ).expand()
                    : !appStore.isLoading
                        ? emptyWidget()
                        : SizedBox(),
              ],
            ),
            loaderWidget().center().visible(appStore.isLoading),
          ],
        );
      }),
    );
  }
}
