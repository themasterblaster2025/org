import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mighty_delivery/delivery/screens/DDashboardScreen.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/CityListModel.dart';
import 'package:mighty_delivery/main/models/CountryListModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
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
  int? selectedCountry;
  int? selectedCity;

  List<CountryModel> countryData = [];
  List<CityModel> cityData = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    getCountryList().then((value) {
      countryData = value.data!;
      //selectedCountry = value.data![0].id!;
      setState(() {});
    }).catchError((error) {
      log(error);
    });
  }

  getCityApiCall(int Id) async {
   await getCityList(CountryId: Id).then((value) {
      cityData = value.data!;
      setState(() {});
    }).catchError((error) {
      log(error);
    });
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
                        DropdownButton<int>(
                          value: selectedCountry,
                          items: countryData.map<DropdownMenuItem<int>>((item) {
                            return DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name ?? ''),
                            );
                          }).toList(),
                          onChanged: (value) {
                            selectedCountry = value!;
                            getCityApiCall(selectedCountry!);
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
                        DropdownButton<int>(
                          value: selectedCity,
                          items: cityData.map<DropdownMenuItem<int>>((item) {
                            return DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name ?? ''),
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
