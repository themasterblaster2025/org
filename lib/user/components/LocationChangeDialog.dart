import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class LocationChangeDialog extends StatefulWidget {
  static String tag = '/LocationChangeDialog';

  @override
  LocationChangeDialogState createState() => LocationChangeDialogState();
}

class LocationChangeDialogState extends State<LocationChangeDialog> {
  List<String> countryList = ['India', 'Brazil', 'Turkiye'];
  List<String> cityList = ['Navsari', 'Mumbai', 'Surat'];
  String? selectedCountry;
  String? selectedCity;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    selectedCountry = countryList[0];
    selectedCity= cityList[0];
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select Region', style: boldTextStyle(size: 20)),
              Icon(Icons.close, color: Colors.grey).onTap(() {
                Navigator.pop(context);
              }),
            ],
          ),
          Divider(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('country', style: boldTextStyle()),
              DropdownButton<String>(
                value: selectedCountry,
                items: countryList.map<DropdownMenuItem<String>>((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCountry = value;
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
                value: selectedCity,
                items: cityList.map<DropdownMenuItem<String>>((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCity = value;
                  setState(() {});
                },
              ),
            ],
          ),
          30.height,
          commonButton("Change",(){
            finish(context);
          },width: context.width() * 0.5).center(),
        ],
      ),
    );
  }
}
