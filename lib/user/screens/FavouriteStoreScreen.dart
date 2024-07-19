import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/extensions/common.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/list_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main/components/CommonScaffoldComponent.dart';
import 'package:mighty_delivery/main/models/StoreListModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';

import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/models/WorkHoursListModel.dart';
import '../../main/utils/Common.dart';
import '../components/StoreItemComponent.dart';

class FavouriteStoreScreen extends StatefulWidget {
  @override
  FavouriteStoreScreenState createState() => FavouriteStoreScreenState();
}

class FavouriteStoreScreenState extends State<FavouriteStoreScreen> {
  TextEditingController searchController = TextEditingController();

  List<StoreData> storeList = [];
  ScrollController scrollController = ScrollController();
  int page = 1;
  int totalPage = 1;
  int totalItem = 0;
  bool isLastPage = false;
  String currentDay = DateFormat('EEEE').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !appStore.isLoading) {
        if (page < totalPage) {
          page++;
          init();
        }
      }
    });
  }

  void init() async {
    appStore.setLoading(true);
    await getFavouriteStore().then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages.validate(value: 1);
      page = value.pagination!.currentPage.validate(value: 1);
      totalItem = value.pagination!.totalItems.validate();
      isLastPage = false;
      if (page == 1) {
        storeList.clear();
      }

      storeList.addAll(value.data!);

      setState(() {});
    }).catchError((e) {
      isLastPage = true;
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
      appBarTitle: language.favouriteStore,
      body: Observer(builder: (context) {
        return Stack(
          children: [
            ListView.builder(
              itemCount: storeList.length,
              shrinkWrap: true,
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              itemBuilder: (context, index) {
                StoreData item = storeList[index];
                return StoreItemComponent(
                    store: item,
                    onUpdate: () {
                      page = 1;
                      init();
                    });
              },
            ),
            loaderWidget().center().visible(appStore.isLoading),
          ],
        );
      }),
    );
  }
}
