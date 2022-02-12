import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mighty_delivery/delivery/screens/DDashboardScreen.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class CitySelectScreen extends StatefulWidget {
  final bool isBack;

  CitySelectScreen({this.isBack = false});

  @override
  CitySelectScreenState createState() => CitySelectScreenState();
}

class CitySelectScreenState extends State<CitySelectScreen> {
  List<String> countryList = ['India', 'Brazil', 'Turkiye'];
  List<String> cityList = ['Navsari', 'Mumbai', 'Surat'];
  String selectedCountry = '';
  String selectedCity = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    selectedCountry = countryList[0];
    selectedCity = cityList[0];
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('Select Region', color: colorPrimary, textColor: white, elevation: 0, showBack: widget.isBack),
      body: BodyCornerWidget(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 16),
          child: Column(
            children: [
              Lottie.asset('assets/delivery.json', height: 250, fit: BoxFit.cover, width: context.width()),
              16.height,
              Container(
                padding: EdgeInsets.all(16),
                decoration: containerDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Region', style: boldTextStyle(size: 20)),
                    30.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Country', style: boldTextStyle()),
                        DropdownButton<String>(
                          value: selectedCountry,
                          items: countryList.map<DropdownMenuItem<String>>((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (value) {
                            selectedCountry = value!;
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    16.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('City', style: boldTextStyle()),
                        DropdownButton<String>(
                          value: selectedCity.isNotEmpty ? selectedCity : null,
                          items: cityList.map<DropdownMenuItem<String>>((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (value) {
                            selectedCity = value!;
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    30.height,
                    commonButton("Change", () {
                      if (widget.isBack) {
                        finish(context);
                      } else {
                        DDashboardScreen().launch(context);
                      }
                    }, width: context.width()),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
