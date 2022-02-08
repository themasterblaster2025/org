import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/DataProviders.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class CreateOrderScreen extends StatefulWidget {
  static String tag = '/CreateOrderScreen';

  @override
  CreateOrderScreenState createState() => CreateOrderScreenState();
}

class CreateOrderScreenState extends State<CreateOrderScreen> {
  TextEditingController packageController = TextEditingController();

  TextEditingController pickAddressCont = TextEditingController();
  TextEditingController pickPhoneCont = TextEditingController();
  TextEditingController pickDateTimeCont = TextEditingController();
  TextEditingController pickDesCont = TextEditingController();
  TextEditingController deliverAddressCont = TextEditingController();
  TextEditingController deliverPhoneCont = TextEditingController();
  TextEditingController deliverDateTimeCont = TextEditingController();
  TextEditingController deliverDesCont = TextEditingController();

  FocusNode pickAddressFocus = FocusNode();
  FocusNode pickPhoneFocus = FocusNode();
  FocusNode pickDateTimeFocus = FocusNode();
  FocusNode pickDesFocus = FocusNode();
  FocusNode deliverAddressFocus = FocusNode();
  FocusNode deliverPhoneFocus = FocusNode();
  FocusNode deliverDateTimeFocus = FocusNode();
  FocusNode deliverDesFocus = FocusNode();

  int selectedIndex = 0;
  int? selectedPaymentIndex;
  bool isDeliverNow = true;
  bool isCashPayment = true;
  int selectedWeightIndex = 0;
  List<DateTime> daysList = getDaysList();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    selectedDate = daysList[0];
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('Create Order',color: colorPrimary,textColor: white,elevation: 0),
      body: BodyCornerWidget(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 16, top: 30, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(4, (index) {
                  return Container(
                    color: selectedIndex >= index ? colorPrimary : borderColor,
                    height: 5,
                    width: context.width() * 0.15,
                  );
                }).toList(),
              ),
              30.height,
              if (selectedIndex == 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        scheduleOptionWidget(isDeliverNow, 'assets/icons/ic_clock.png', 'Deliver Now').onTap(() {
                          isDeliverNow = true;
                          setState(() {});
                        }).expand(),
                        16.width,
                        scheduleOptionWidget(!isDeliverNow, 'assets/icons/ic_schedule.png', 'Schedule').onTap(() {
                          isDeliverNow = false;
                          setState(() {});
                        }).expand(),
                      ],
                    ),
                    16.height,
                    Text('Weight', style: boldTextStyle()),
                    8.height,
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: weightList.map((item) {
                        int index = weightList.indexOf(item);
                        return Chip(
                          backgroundColor: selectedWeightIndex == index ? colorPrimary : Colors.white,
                          label: Text(item),
                          elevation: 0,
                          labelStyle: primaryTextStyle(color: selectedWeightIndex == index ? white : Colors.grey),
                          padding: EdgeInsets.zero,
                          labelPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(defaultRadius),
                            side: BorderSide(color: selectedWeightIndex == index ? colorPrimary : borderColor),
                          ),
                        ).onTap(() {
                          selectedWeightIndex = index;
                          setState(() {});
                        });
                      }).toList(),
                    ),
                  ],
                ),
              if (selectedIndex == 1)
                Column(
                  children: [
                    Container(
                      decoration: boxDecorationWithRoundedCorners(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        border: Border.all(color: borderColor),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          childrenPadding: EdgeInsets.all(16),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          title: Text('Pick up Information'),
                          children: [
                            Text('Address', style: boldTextStyle()),
                            8.height,
                            AppTextField(
                              controller: pickAddressCont,
                              textInputAction: TextInputAction.next,
                              focus: pickAddressFocus,
                              nextFocus: pickPhoneFocus,
                              textFieldType: TextFieldType.ADDRESS,
                              decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
                            ),
                            16.height,
                            Text('Contact Number', style: boldTextStyle()),
                            8.height,
                            AppTextField(
                              controller: pickPhoneCont,
                              focus: pickPhoneFocus,
                              nextFocus: !isDeliverNow ? pickDateTimeFocus : pickDesFocus,
                              textFieldType: TextFieldType.PHONE,
                              decoration: commonInputDecoration(suffixIcon: Icons.phone),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                16.height,
                                Text('Date & Time', style: boldTextStyle()),
                                8.height,
                                DateTimePicker(
                                  controller: pickDateTimeCont,
                                  focusNode: pickDateTimeFocus,
                                  type: DateTimePickerType.dateTime,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  decoration: commonInputDecoration(suffixIcon: Icons.date_range),
                                  dateLabelText: 'Date',
                                  onChanged: (val) => print(val),
                                  validator: (val) {
                                    print(val);
                                    return null;
                                  },
                                  onSaved: (val) => print(val),
                                ),
                              ],
                            ).visible(!isDeliverNow),
                            /* Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  16.height,
                                  Text('Depart Time', style: boldTextStyle()),
                                  8.height,
                                  DropdownButtonFormField<DateTime>(
                                    value: selectedDate,
                                    items: daysList.map(
                                          (DateTime? item) {
                                        int index = daysList.indexOf(item!);
                                        return DropdownMenuItem<DateTime>(
                                          value: item,
                                          child: Text(index == 0
                                              ? 'today'
                                              : index == 1
                                              ? 'tomorrow'
                                              : DateFormat('d MMM').format(item)),
                                        );
                                      },
                                    ).toList(),
                                    onChanged: (value) {
                                      selectedDate = value;
                                      setState(() {});
                                    },
                                    decoration: commonInputDecoration(),
                                  ).withWidth(150),
                                  16.height,
                                  Row(
                                    children: [
                                      Text('From', style: primaryTextStyle()),
                                      8.width,
                                      AppTextField(
                                        textFieldType: TextFieldType.ADDRESS,
                                        decoration: commonInputDecoration(),
                                      ).expand(),
                                      16.width,
                                      Text('To', style: primaryTextStyle()),
                                      8.width,
                                      AppTextField(
                                        textFieldType: TextFieldType.ADDRESS,
                                        decoration: commonInputDecoration(),
                                      ).expand(),
                                    ],
                                  ),
                                ],
                              ).visible(!isDeliverNow),*/
                            16.height,
                            Text('Description', style: boldTextStyle()),
                            8.height,
                            AppTextField(
                              controller: pickDesCont,
                              focus: pickDesFocus,
                              textFieldType: TextFieldType.OTHER,
                              decoration: commonInputDecoration(suffixIcon: Icons.notes),
                              maxLines: 2,
                              minLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    16.height,
                    Container(
                      decoration: boxDecorationWithRoundedCorners(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        border: Border.all(color: borderColor),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          childrenPadding: EdgeInsets.all(16),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          title: Text('Delivery Information'),
                          children: [
                            Text('Address', style: boldTextStyle()),
                            8.height,
                            AppTextField(
                              controller: deliverAddressCont,
                              focus: deliverAddressFocus,
                              nextFocus: deliverPhoneFocus,
                              textInputAction: TextInputAction.next,
                              textFieldType: TextFieldType.ADDRESS,
                              decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
                            ),
                            16.height,
                            Text('Contact Number', style: boldTextStyle()),
                            8.height,
                            AppTextField(
                              controller: deliverPhoneCont,
                              focus: deliverPhoneFocus,
                              nextFocus: !isDeliverNow ? deliverDateTimeFocus : deliverDesFocus,
                              textFieldType: TextFieldType.PHONE,
                              decoration: commonInputDecoration(suffixIcon: Icons.phone),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                16.height,
                                Text('Date & Time', style: boldTextStyle()),
                                8.height,
                                DateTimePicker(
                                  controller: deliverDateTimeCont,
                                  focusNode: deliverDateTimeFocus,
                                  type: DateTimePickerType.dateTime,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  decoration: commonInputDecoration(suffixIcon: Icons.date_range),
                                  dateLabelText: 'Date',
                                  onChanged: (val) => print(val),
                                  validator: (val) {
                                    print(val);
                                    return null;
                                  },
                                  onSaved: (val) => print(val),
                                ),
                              ],
                            ).visible(!isDeliverNow),
                            16.height,
                            Text('Description', style: boldTextStyle()),
                            8.height,
                            AppTextField(
                              controller: deliverDesCont,
                              focus: deliverDesFocus,
                              textFieldType: TextFieldType.OTHER,
                              decoration: commonInputDecoration(suffixIcon: Icons.notes),
                              maxLines: 2,
                              minLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              if (selectedIndex == 2)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What you are Sending?', style: boldTextStyle()),
                    8.height,
                    AppTextField(
                      controller: packageController,
                      textFieldType: TextFieldType.OTHER,
                      decoration: commonInputDecoration(),
                    ),
                    16.height,
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: packageList.map((item) {
                        int index = packageList.indexOf(item);
                        return Chip(
                          backgroundColor: Colors.white,
                          label: Text(item),
                          elevation: 0,
                          labelStyle: primaryTextStyle(color: Colors.grey),
                          padding: EdgeInsets.zero,
                          labelPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(defaultRadius),
                            side: BorderSide(color: borderColor),
                          ),
                        ).onTap(() {
                          packageController.text = item;
                          setState(() {});
                        });
                      }).toList(),
                    ),
                  ],
                ),
              if (selectedIndex == 3)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment Type', style: boldTextStyle()),
                    16.height,
                    Row(
                      children: [
                        scheduleOptionWidget(isCashPayment, 'assets/icons/ic_cash.png', 'Cash').onTap(() {
                          isCashPayment = true;
                          setState(() {});
                        }).expand(),
                        16.width,
                        scheduleOptionWidget(!isCashPayment, 'assets/icons/ic_credit_card.png', 'Credit Card').onTap(() {
                          isCashPayment = false;
                          setState(() {});
                        }).expand(),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        16.height,
                        Text('Payment Methods', style: boldTextStyle()),
                        16.height,
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: paymentGatewayList.length,
                          itemBuilder: (context, index) {
                            String mData = paymentGatewayList[index];
                            return Container(
                              padding: EdgeInsets.all(16),
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: boxDecorationWithRoundedCorners(
                                borderRadius: BorderRadius.circular(defaultRadius),
                                border: Border.all(color: borderColor),
                              ),
                              child: Text(mData,style: boldTextStyle(size: 18)),
                            );
                          },
                        ),
                      ],
                    ).visible(!isCashPayment),
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          if (selectedIndex != 0)
            outlineButton(
              'Previous',
              () {
                selectedIndex--;
                setState(() {});
              },
            ).paddingRight(16).expand(),
          commonButton(selectedIndex != 3 ? 'Next' : 'Create Order', () {
            if (selectedIndex != 3) {
              selectedIndex++;
              setState(() {});
            } else {
              finish(context);
            }
          }).expand()
        ],
      ).paddingAll(16),
    );
  }
}
