import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  int selectedIndex = 0;
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
      body: Stack(
        children: [
          customAppBarWidget(context, 'Create Order', isShowBack: true),
          containerWidget(
            context,
            SingleChildScrollView(
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
                      ).onTap(() {
                        selectedIndex = index;
                        setState(() {});
                      });
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
                              backgroundColor: selectedWeightIndex == index ? colorPrimary.withOpacity(0.1) : Colors.white,
                              label: Text(item),
                              elevation: 0,
                              labelStyle: primaryTextStyle(color: selectedWeightIndex == index ? colorPrimary : Colors.grey),
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
                              title: Text('From'),
                              children: [
                                Text('Name', style: boldTextStyle()),
                                8.height,
                                AppTextField(
                                  textFieldType: TextFieldType.NAME,
                                  decoration: commonInputDecoration(suffixIcon: Icons.person_outline),
                                ),
                                16.height,
                                Text('Address', style: boldTextStyle()),
                                8.height,
                                AppTextField(
                                  textFieldType: TextFieldType.ADDRESS,
                                  decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
                                ),
                                16.height,
                                Text('Phone Number', style: boldTextStyle()),
                                8.height,
                                AppTextField(
                                  textFieldType: TextFieldType.PHONE,
                                  decoration: commonInputDecoration(suffixIcon: Icons.phone),
                                ),
                                Column(
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
                                ).visible(!isDeliverNow),
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
                              title: Text('To'),
                              children: [
                                Text('Name', style: boldTextStyle()),
                                8.height,
                                AppTextField(
                                  textFieldType: TextFieldType.NAME,
                                  decoration: commonInputDecoration(suffixIcon: Icons.person_outline),
                                ),
                                16.height,
                                Text('Address', style: boldTextStyle()),
                                8.height,
                                AppTextField(
                                  textFieldType: TextFieldType.ADDRESS,
                                  decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
                                ),
                                16.height,
                                Text('Phone Number', style: boldTextStyle()),
                                8.height,
                                AppTextField(
                                  textFieldType: TextFieldType.PHONE,
                                  decoration: commonInputDecoration(suffixIcon: Icons.phone),
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
                  if(selectedIndex == 3)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Type',style: boldTextStyle()),
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
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: commonButton(selectedIndex != 3 ? 'Next' : 'Create Order', () {
        if (selectedIndex != 3) {
          selectedIndex++;
          setState(() {});
        } else {
          finish(context);
        }
      }).paddingAll(16),
    );
  }
}
