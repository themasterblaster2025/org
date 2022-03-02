import 'package:flutter/material.dart';
import 'package:mighty_delivery/delivery/components/NewOrderWidget.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/DataProviders.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class ShortingListScreen extends StatefulWidget {
  @override
  ShortingListScreenState createState() => ShortingListScreenState();
}

class ShortingListScreenState extends State<ShortingListScreen> {
  List<AppModel> list = getSearchList();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  Future<void> showSearchData() {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: list.map((e) {
                  return CheckboxListTile(
                      title: Text(getOrderStatus(e.name!)!),
                      value: e.isCheck,
                      onChanged: (v) {
                        e.isCheck = !e.isCheck;
                        setState(() {});
                      });
                }).toList(),
              );
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.grey.withOpacity(0.2)),
                  onPressed: () {
                    finish(context);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.close, color: black),
                      8.width,
                      Text('Cancel', style: boldTextStyle()),
                    ],
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: colorPrimary),
                  onPressed: () {
                    finish(context);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.check_outlined, color: white),
                      8.width,
                      Text('Short', style: boldTextStyle(color: white)),
                    ],
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Stack(
            children: [
              customAppBarWidget(context, 'Confirm Delivery', isShowBack: true),
              Positioned(
                top: 32,
                right: 15,
                child: IconButton(
                  onPressed: () {
                    showSearchData();
                  },
                  icon: Icon(Icons.sort, color: white),
                ),
              )
            ],
          ),
          containerWidget(
            context,
            SingleChildScrollView(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: ListView.builder(
                itemCount: 10,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  return NewOrderWidget();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
