import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:lottie/lottie.dart';
import 'package:mighty_delivery/delivery/screens/DeliveryDashBoard.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/CityListModel.dart';
import 'package:mighty_delivery/main/models/CountryListModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/user/screens/DashboardScreen.dart';
import 'package:nb_utils/nb_utils.dart';

class UserCitySelectScreen extends StatefulWidget {
  static String tag = '/UserCitySelectScreen';
  final bool isBack;
  final Function()? onUpdate;

  UserCitySelectScreen({this.isBack = false, this.onUpdate});

  @override
  UserCitySelectScreenState createState() => UserCitySelectScreenState();
}

class UserCitySelectScreenState extends State<UserCitySelectScreen> {
  TextEditingController searchCityController = TextEditingController();

  int? selectedCountry;
  int? selectedCity;

  List<CountryModel> countryData = [];
  List<CityModel> cityData = [];

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  Future<void> init() async {
    getCountryApiCall();
  }

  getCountryApiCall() async {
    appStore.setLoading(true);
    await getCountryList().then((value) {
      appStore.setLoading(false);
      countryData = value.data!;
      selectedCountry = countryData[0].id!;
      countryData.forEach((element) {
        if (element.id! == getIntAsync(COUNTRY_ID)) {
          selectedCountry = getIntAsync(COUNTRY_ID);
        }
      });
      setValue(COUNTRY_ID, selectedCountry);
      getCountryDetailApiCall();
      getCityApiCall();
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  getCityApiCall({String? name}) async {
    appStore.setLoading(true);
    await getCityList(CountryId: selectedCountry!, name: name).then((value) {
      appStore.setLoading(false);
      cityData.clear();
      cityData.addAll(value.data!);
      cityData.forEach((element) {
        if (element.id! == getIntAsync(CITY_ID)) {
          selectedCity = getIntAsync(CITY_ID);
        }
      });
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  getCountryDetailApiCall() async {
    await getCountryDetail(selectedCountry!).then((value) {
      setValue(COUNTRY_DATA, value.data!.toJson());
    }).catchError((error) {});
  }

  Future<void> updateCountryCityApiCall() async {
    appStore.setLoading(true);
    await updateCountryCity(countryId: selectedCountry, cityId: selectedCity).then((value) {
      appStore.setLoading(false);
      if (widget.isBack) {
        finish(context);
        widget.onUpdate!.call();
      } else {
        if(getStringAsync(USER_TYPE) == CLIENT) {
          DashboardScreen().launch(context);
        }else{
          DeliveryDashBoard().launch(context);
        }
      }
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedCity != null) {
          return true;
        } else {
          toast('Please select City');
          return false;
        }
      },
      child: Scaffold(
        appBar: appBarWidget('Select Region', color: colorPrimary, textColor: white, elevation: 0, showBack: widget.isBack),
        body: BodyCornerWidget(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Lottie.asset('assets/delivery.json', height: 200, fit: BoxFit.contain, width: context.width()),
                16.height,
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: containerDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('Country', style: boldTextStyle())),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: selectedCountry,
                              decoration: commonInputDecoration(),
                              items: countryData.map<DropdownMenuItem<int>>((item) {
                                return DropdownMenuItem(
                                  value: item.id,
                                  child: Text(item.name ?? ''),
                                );
                              }).toList(),
                              onChanged: (value) {
                                selectedCountry = value!;
                                setValue(COUNTRY_ID, selectedCountry);
                                getCountryDetailApiCall();
                                selectedCity = null;
                                getCityApiCall();
                                setState(() {});
                              },
                              validator: (value) {
                                if (selectedCountry == null) return errorThisFieldRequired;
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      16.height,
                      Text('City', style: boldTextStyle()),
                      16.height,
                      cityData.isNotEmpty
                          ? Column(
                              children: [
                                AppTextField(
                                  controller: searchCityController,
                                  textFieldType: TextFieldType.OTHER,
                                  decoration: commonInputDecoration(hintText: 'Search City', suffixIcon: Icons.search),
                                  onChanged: (value) {
                                    getCityApiCall(name: value);
                                  },
                                ),
                                ListView.builder(
                                  itemCount: cityData.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    CityModel mData = cityData[index];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(mData.name!, style: TextStyle(color: selectedCity == mData.id ? colorPrimary : Colors.black)),
                                      trailing: selectedCity == mData.id ? Icon(Icons.check_circle,color: colorPrimary) : SizedBox(),
                                      onTap: () {
                                        selectedCity = mData.id!;
                                        setValue(CITY_ID, selectedCity);
                                        setValue(CITY_DATA, mData.toJson());
                                        updateCountryCityApiCall();
                                      },
                                    );
                                  },
                                ),
                              ],
                            )
                          : appStore.isLoading
                              ? loaderWidget()
                              : Text('No City Found', style: primaryTextStyle()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
