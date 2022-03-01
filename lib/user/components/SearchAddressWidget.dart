import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

class SearchAddressWidget extends PlacesAutocompleteWidget {
  SearchAddressWidget({Key? key})
      : super(
          key: key,
          apiKey: googleMapAPIKey,
          language: "en",
          types: [],
          strictbounds: false,
          region: 'Navsari',
          components: [Component(Component.country, "IN")],
        );

  @override
  _CustomSearchScaffoldState createState() => _CustomSearchScaffoldState();
}

class _CustomSearchScaffoldState extends PlacesAutocompleteState {
  final searchScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: AppBarPlacesAutoCompleteTextField(
        textDecoration: commonInputDecoration(suffixIcon: Icons.search),
        textStyle: primaryTextStyle(color: Colors.white),
      ),
      backgroundColor: colorPrimary,
      elevation: 0,
    );
    final body = BodyCornerWidget(child: PlacesAutocompleteResult(
      onTap: (p) {
        displayPrediction(p, context);
      },
    ));
    return WillPopScope(
      onWillPop: () async {
        finish(context);
        return true;
      },
      child: Scaffold(key: searchScaffoldKey, appBar: appBar, body: body),
    );
  }

  Future<void> displayPrediction(Prediction? p, BuildContext context) async {
    if (p != null) {
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: googleMapAPIKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;
      finish(context, [
        {'address': p.description, 'late': lat.toString(), 'long': lng.toString()}
      ]);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${p.description} - $lat/$lng")),
      );
    }
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.errorMessage!)),
    );
  }
}
