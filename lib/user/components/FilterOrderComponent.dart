import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class FilterOrderComponent extends StatefulWidget {
  static String tag = '/FilterOrderComponent';

  @override
  FilterOrderComponentState createState() => FilterOrderComponentState();
}

class FilterOrderComponentState extends State<FilterOrderComponent> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  DateTime? fromDate, toDate;
  List<String> statusList = [
    ORDER_CREATE,
    ORDER_ACTIVE,
    ORDER_CANCELLED,
    ORDER_DELAYED,
    ORDER_ASSIGNED,
    ORDER_ARRIVED,
    ORDER_PICKED_UP,
    ORDER_COMPLETED,
    ORDER_DEPARTED,
  ];
  int? selectedStatusIndex;

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
    return Padding(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.clear).onTap(() {
                      finish(context);
                    }),
                    16.width,
                    Text('Filters', style: boldTextStyle(size: 18)),
                  ],
                ),
                Text('Reset', style: primaryTextStyle()).onTap(() {
                  selectedStatusIndex = null;
                  fromDate = null;
                  toDate = null;
                  fromDateController.clear();
                  toDateController.clear();
                  FocusScope.of(context).unfocus();
                  setState(() {});
                }),
              ],
            ),
            30.height,
            Text('Status', style: boldTextStyle()),
            16.height,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: statusList.map((item) {
                int index = statusList.indexOf(item);
                return Chip(
                  backgroundColor: selectedStatusIndex == index ? colorPrimary : Colors.white,
                  label: Text(item),
                  elevation: 0,
                  labelStyle: primaryTextStyle(color: selectedStatusIndex == index ? white : Colors.grey),
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultRadius),
                    side: BorderSide(color: selectedStatusIndex == index ? colorPrimary : borderColor),
                  ),
                ).onTap(() {
                  selectedStatusIndex = index;
                  setState(() {});
                });
              }).toList(),
            ),
            16.height,
            Text('Date', style: boldTextStyle()),
            16.height,
            Row(
              children: [
                Text('From', style: primaryTextStyle()).withWidth(50),
                16.width,
                DateTimePicker(
                  controller: fromDateController,
                  type: DateTimePickerType.date,
                  lastDate: DateTime.now(),
                  firstDate: DateTime(2010),
                  onChanged: (value) {
                    fromDate = DateTime.parse(value);
                    setState(() {});
                  },
                  decoration: commonInputDecoration(suffixIcon: Icons.calendar_today),
                ).expand(),
              ],
            ),
            16.height,
            Row(
              children: [
                Text('To', style: primaryTextStyle()).withWidth(50),
                16.width,
                DateTimePicker(
                  controller: toDateController,
                  type: DateTimePickerType.date,
                  lastDate: DateTime.now(),
                  firstDate: DateTime(2010),
                  onChanged: (value) {
                    toDate = DateTime.parse(value);
                    setState(() {});
                  },
                  validator: (value) {
                    if(fromDate!=null && toDate!=null) {
                      Duration difference = fromDate!.difference(toDate!);
                      if (difference.inDays >= 0) {
                        return 'To Date must after From Date';
                      }
                    }
                  },
                  decoration: commonInputDecoration(suffixIcon: Icons.calendar_today),
                ).expand(),
              ],
            ),
            16.height,
            commonButton('Apply Filters', () {
              if(_formKey.currentState!.validate()){
                finish(context);
                String? status;
                if(selectedStatusIndex!=null){
                  status = statusList[selectedStatusIndex!];
                }
                LiveStream().emit("UpdateOrderData", FilterAttributeModel(orderStatus: status, fromDate: fromDate.toString(), toDate: toDate.toString()).toJson());
              }
            }, width: context.width()),
          ],
        ),
      ),
    );
  }
}
