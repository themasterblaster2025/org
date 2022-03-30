import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/LoginResponse.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

class OrderTrackingScreen extends StatefulWidget {
  static String tag = '/OrderTrackingScreen';

  final OrderData orderData;

  OrderTrackingScreen({required this.orderData});

  @override
  OrderTrackingScreenState createState() => OrderTrackingScreenState();
}

class OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Timer? timer;

  List<Marker> markers = [];
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];

  late PolylinePoints polylinePoints;

  LatLng? SOURCE_LOCATION;

  double CAMERA_ZOOM = 13;

  double CAMERA_TILT = 0;
  double CAMERA_BEARING = 30;

  UserData? deliveryBoyData;

  @override
  void initState() {
    super.initState();
     init();
  }

  Future<void> init() async {
    polylinePoints = PolylinePoints();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => getDeliveryBoyDetails());
  }

  getDeliveryBoyDetails() {
    appStore.setLoading(true);
    getUserDetail(widget.orderData.deliveryManId.validate()).then((value) {
      appStore.setLoading(false);
      deliveryBoyData = value;
      SOURCE_LOCATION = LatLng(deliveryBoyData!.latitude.toDouble(), deliveryBoyData!.longitude.toDouble());
      markers = [
        Marker(
          markerId: MarkerId(deliveryBoyData!.city_name.validate()),
          position: LatLng(deliveryBoyData!.latitude.toDouble(), deliveryBoyData!.longitude.toDouble()),
          infoWindow: InfoWindow(title: '${deliveryBoyData!.name.validate()}',snippet: 'Last update at ${dateParse(deliveryBoyData!.updated_at!)}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
        Marker(
          markerId: MarkerId(widget.orderData.cityName.validate()),
          position: LatLng(widget.orderData.deliveryPoint!.latitude.toDouble(), widget.orderData.deliveryPoint!.longitude.toDouble()),
          infoWindow: InfoWindow(title: widget.orderData.deliveryPoint!.address.validate()),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      ];
      setPolyLines(deliveryLatLng: LatLng(deliveryBoyData!.latitude.toDouble(), deliveryBoyData!.longitude.toDouble()));
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
    });
  }

  Future<void> setPolyLines({required LatLng deliveryLatLng}) async {
    _polylines.clear();
    polylineCoordinates.clear();
    var result = await polylinePoints.getRouteBetweenCoordinates(
      googleMapAPIKey,
      PointLatLng(deliveryLatLng.latitude, deliveryLatLng.longitude),
      PointLatLng(widget.orderData.deliveryPoint!.latitude.toDouble(), widget.orderData.deliveryPoint!.longitude.toDouble()),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((element) {
        polylineCoordinates.add(LatLng(element.latitude, element.longitude));
      });
      _polylines.add(Polyline(
        visible: true,
        width: 5,
        polylineId: PolylineId('poly'),
        color: Color.fromARGB(255, 40, 122, 198),
        points: polylineCoordinates,
      ));
      setState(() {});
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language.track_order)),
      body: BodyCornerWidget(
        child: SOURCE_LOCATION != null ? GoogleMap(
          markers: markers.map((e) => e).toSet(),
          polylines: _polylines,
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: SOURCE_LOCATION!,
            zoom: CAMERA_ZOOM,
            tilt: CAMERA_TILT,
            bearing: CAMERA_BEARING,
          ),
        ) : loaderWidget(),
      ),
    );
  }
}
