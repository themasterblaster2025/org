import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';

class TrackingScreen extends StatefulWidget {
  final List<OrderData> order;
  final LatLng? latLng;

  TrackingScreen({required this.order, required this.latLng});

  @override
  TrackingScreenState createState() => TrackingScreenState();
}

class TrackingScreenState extends State<TrackingScreen> {
  late GoogleMapController _controller;

  late PolylinePoints polylinePoints;

  List<Marker> markers = [];

  late CameraPosition initialLocation;

  LatLng? SOURCE_LOCATION;

  double CAMERA_ZOOM = 13;

  double CAMERA_TILT = 0;
  double CAMERA_BEARING = 30;

  late LatLng orderLatLong;

  final Set<Polyline> polyline = {};
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];

  late StreamSubscription<Position> positionStream;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    polylinePoints = PolylinePoints();

    positionStream = Geolocator.getPositionStream().listen((event) async {
      SOURCE_LOCATION = LatLng(event.latitude, event.longitude);
      await updateLocation(latitude: event.latitude.toString(), longitude: event.longitude.toString()).then((value) {
        markers.add(
          Marker(
            markerId: MarkerId('valsad'),
            position: LatLng(SOURCE_LOCATION!.latitude, SOURCE_LOCATION!.longitude),
            infoWindow: InfoWindow(title: 'Delivery Boy'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
        widget.order.map((e) {
          markers.add(
            Marker(
              markerId: MarkerId('valsad'),
              position: LatLng(e.deliveryPoint!.latitude.toDouble(), e.deliveryPoint!.longitude.toDouble()),
              infoWindow: InfoWindow(title: e.deliveryPoint!.address),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            ),
          );
        }).toList();

        setPolyLines(orderLat: orderLatLong);
      }).catchError((error) {
        log(event);
      });
      setState(() {});
    });

    //setState(() {});

    orderLatLong = await LatLng(widget.latLng!.latitude, widget.latLng!.longitude);
  }

  Future<void> setPolyLines({required LatLng orderLat}) async {
    _polylines.clear();
    polylineCoordinates.clear();
    var result = await polylinePoints.getRouteBetweenCoordinates(
      googleMapAPIKey,
      PointLatLng(SOURCE_LOCATION!.latitude, SOURCE_LOCATION!.longitude),
      PointLatLng(orderLat.latitude, orderLat.longitude),
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
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.tracking_order),
      ),
      body: BodyCornerWidget(
        child: SOURCE_LOCATION != null
            ? Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  GoogleMap(
                    markers: markers.map((e) => e).toSet(),
                    polylines: _polylines,
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: SOURCE_LOCATION!,
                      zoom: CAMERA_ZOOM,
                      tilt: CAMERA_TILT,
                      bearing: CAMERA_BEARING,
                    ),
                  ),
                  Container(
                    height: 200,
                    color: context.scaffoldBackgroundColor,
                    child: ListView.separated(
                      padding: EdgeInsets.all(16),
                      shrinkWrap: true,
                      itemCount: widget.order.length,
                      itemBuilder: (_, index) {
                        OrderData data = widget.order[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Id #${data.id}', style: boldTextStyle()),
                                AppButton(
                                  padding: EdgeInsets.zero,
                                  color: colorPrimary,
                                  text: language.track,
                                  textStyle: primaryTextStyle(color: Colors.white),
                                  onTap: () async {
                                    orderLatLong = LatLng(data.pickupPoint!.latitude.toDouble(), data.pickupPoint!.longitude.toDouble());
                                    await setPolyLines(orderLat: orderLatLong);
                                    setState(() {});
                                  },
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.location_on, color: colorPrimary),
                                Text(data.pickupPoint!.address.validate(), style: primaryTextStyle()).expand(),
                              ],
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (_,index){
                        return Divider();
                      }
                    ),
                  ),
                ],
              )
            : loaderWidget(),
      ),
    );
  }
}
