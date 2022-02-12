import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

class SearchAddressScreen extends StatefulWidget {
  @override
  SearchAddressScreenState createState() => SearchAddressScreenState();
}

class SearchAddressScreenState extends State<SearchAddressScreen> {
  TextEditingController controller = TextEditingController();

  Mode _mode = Mode.overlay;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  Future<void> handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: googleMapAPIKey,
      onError: onError,
      mode: _mode,
      language: "en",
      types: [],
      strictbounds: false,
      region: 'India',
      decoration: InputDecoration(
        hintText: 'Search',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
      ),
      components: [
        Component(Component.country, "IN"),
      ],
    );

    displayPrediction(p!);
    toast(p.description.toString());
  }

  Future<void> displayPrediction(Prediction p) async {
    if (p != null) {
      log(p);
      // get detail (lat/lng)
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: googleMapAPIKey,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      toast("${p.description} - $lat/$lng");
      /*scaffold.showSnackBar(
        SnackBar(content: Text("${p.description} - $lat/$lng")),
      );*/
    }
  }

  Widget _buildDropdownMenu() => DropdownButton(
        value: _mode,
        items: <DropdownMenuItem<Mode>>[
          DropdownMenuItem<Mode>(
            child: Text("Overlay"),
            value: Mode.overlay,
          ),
          DropdownMenuItem<Mode>(
            child: Text("Fullscreen"),
            value: Mode.fullscreen,
          ),
        ],
        onChanged: (Mode? m) {
          setState(() {
            _mode = m!;
          });
        },
      );

  void onError(PlacesAutocompleteResponse response) {
    toast(response.errorMessage);
    toast(response.status);
    toast(response.predictions.first.description);
    log(response.errorMessage);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search address'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildDropdownMenu(),
            ElevatedButton(
              onPressed: handlePressButton,
              child: Text("Search places"),
            ),
            ElevatedButton(
              child: Text("Custom"),
              onPressed: () {
                //
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSearchScaffold extends PlacesAutocompleteWidget {
  CustomSearchScaffold({Key? key})
      : super(
          key: key,
          apiKey: googleMapAPIKey,
          sessionToken: Uuid().generateV4(),
          language: "en",
          components: [Component(Component.country, "uk")],
        );

  @override
  _CustomSearchScaffoldState createState() => _CustomSearchScaffoldState();
}

class _CustomSearchScaffoldState extends PlacesAutocompleteState {
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final searchScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: AppBarPlacesAutoCompleteTextField());
    final body = PlacesAutocompleteResult(
      onTap: (p) {
        displayPrediction(p, context);
      },
      logo: Row(
        children: const [FlutterLogo()],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
    return Scaffold(key: searchScaffoldKey, appBar: appBar, body: body);
  }

  Future<void> displayPrediction(Prediction p, BuildContext context) async {
    if (p != null) {
      log(p);
      // get detail (lat/lng)
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: googleMapAPIKey,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      toast("${p.description} - $lat/$lng");
      /*scaffold.showSnackBar(
        SnackBar(content: Text("${p.description} - $lat/$lng")),
      );*/
    }
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.errorMessage!)),
    );
  }

  @override
  void onResponse(PlacesAutocompleteResponse? response) {
    super.onResponse(response);
    if (response != null && response.predictions.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Got answer")),
      );
    }
  }
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
    final int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) => _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) => value.toRadixString(16).padLeft(count, '0');
}
