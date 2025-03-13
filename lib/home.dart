// ignore_for_file: must_be_immutable, avoid_print, use_key_in_widget_constructors, unused_element, unused_field, constant_identifier_names, unused_local_variable, deprecated_member_use, non_constant_identifier_names, avoid_init_to_null

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Set<Marker> markers = {};
  int counter = 0;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  static const CameraPosition MiniaUniversityHospital = CameraPosition(
    target: LatLng(28.089890, 30.765652),
    zoom: 16.8446,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            GoogleMap(
              onTap: (latlong) {
                Marker marker = Marker(
                  markerId: MarkerId('marker$counter'),
                  position: latlong,
                );
                markers.add(marker);
                setState(() {
                  counter++;
                });
              },
              mapType: MapType.hybrid,
              initialCameraPosition:
                  MyCurrentLocation ?? MiniaUniversityHospital,
              markers: markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
            Align(
              alignment: Alignment.topCenter, // يجعل النص في المنتصف دائمًا
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    0,
                    0,
                    0,
                  ).withOpacity(0.4), // خلفية شفافة
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Easy GPS',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        floatingActionButton: Transform.translate(
          offset: Offset(-40, 0), // إزاحة 40 بكسل لليسار
          child: FloatingActionButton.extended(
            onPressed: _goToTheLake,
            label: const Text('To the lake!'),
            icon: const Icon(Icons.directions_boat),
          ),
        ),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(MyCurrentLocation!),
    );
  }

  Location location = Location();
  PermissionStatus? permissionStatus;
  bool serviceEnabled = false;
  CameraPosition? MyCurrentLocation;
  LocationData? locationData = null;
  StreamSubscription<LocationData>? streamSubscription;

  // AIzaSyBVPpbQRz0foGia10Er40QAaLPX6gLU2k4
  void getCurrentLocation() async {
    var permission = await isPermissionGranted();
    if (permission == false) return;
    var service = await isServiceEnabled();
    if (service == false) return;

    locationData = await location.getLocation();
    location.changeSettings(accuracy: LocationAccuracy.low);
    streamSubscription = location.onLocationChanged.listen((event) {
      locationData = event;
      print("My Location : lat : ${locationData?.latitude}");
      print("My Location : long : ${locationData?.longitude}");
      updateUserLocation();
    });

    Marker userMarker = Marker(
      markerId: MarkerId('userLocation'),
      position: LatLng(locationData!.latitude!, locationData!.longitude!),
    );
    markers.add(userMarker);
    MyCurrentLocation = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(locationData!.latitude!, locationData!.longitude!),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414,
    );
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(MyCurrentLocation!),
    );
    setState(() {});
  }

  void updateUserLocation() async {
    MyCurrentLocation = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(locationData!.latitude!, locationData!.longitude!),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414,
    );
    Marker userMarker = Marker(
      markerId: MarkerId('userLocation'),
      position: LatLng(locationData!.latitude!, locationData!.longitude!),
    );
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(MyCurrentLocation!),
    );
    setState(() {});
  }

  Future<bool> isServiceEnabled() async {
    serviceEnabled = await location.serviceEnabled();
    if (serviceEnabled == false) {
      serviceEnabled = await location.requestService();
      return serviceEnabled;
    }
    return serviceEnabled;
  }

  Future<bool> isPermissionGranted() async {
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      return permissionStatus == PermissionStatus.granted;
    }
    return permissionStatus == PermissionStatus.granted;
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription!.cancel();
  }
}
