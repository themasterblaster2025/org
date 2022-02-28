import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_for_flutter/google_places_for_flutter.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

class AddressSearchScreen extends StatefulWidget {
  @override
  AddressSearchScreenState createState() => AddressSearchScreenState();
}

class AddressSearchScreenState extends State<AddressSearchScreen> {
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  double calculateDistance({lat1, lon1, lat2, lon2}) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  getAddressData() async {
    double distanceInMeters = Geolocator.distanceBetween(20.9469, 72.9140, 20.6081, 72.9339);
    return distanceInMeters;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Address'),
      ),
      body: Column(
        children: [
          SearchGooglePlacesWidget(
            hasClearButton: true,
            language: 'en',
            apiKey: googleMapAPIKey,
            placeType: PlaceType.address,
            placeholder: 'Enter the address',
            location: LatLng(72.9520, 20.9467),
            radius: 10000,
            onSelected: (Place place) async {
              final geolocation = await place.geolocation;
              final GoogleMapController controller = await _controller.future;
              controller.animateCamera(CameraUpdate.newLatLng(geolocation!.coordinates));
              controller.animateCamera(CameraUpdate.newLatLngBounds(geolocation.bounds, 0));
            },
            onSearch: (Place place) {},
          ),
          16.height,
          AppButton(
            text: 'Total Distance',
            onTap: () async {
              double distanceInMeters = Geolocator.distanceBetween(20.9469, 72.9140, 20.6081, 72.9339);
              toast(distanceInMeters.toInt().toString());
            },
          )
        ],
      ),
    );
  }
}
