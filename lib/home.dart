// ignore_for_file: must_be_immutable, avoid_print, use_key_in_widget_constructors, unused_element, unused_field, constant_identifier_names, unused_local_variable, deprecated_member_use, non_constant_identifier_names, avoid_init_to_null, depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
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
  double? compassHeading; // اتجاه البوصلة

bool isLoading = true; // حالة التحميل في البداية

@override
void initState() {
  super.initState();
  startCompass();
  requestLocationPermission(); // طلب الإذن عند بدء التطبيق
}

  static const CameraPosition MiniaNationalUniversity = CameraPosition(
    target: LatLng(28.076800, 30.836215),
    zoom: 17.000,
  );

double tiltAngle = 0.0; // زاوية الإمالة الافتراضية
double currentZoom = 19.151926040649414; // الاحتفاظ بمستوى التكبير الحالي
LatLng currentCameraPosition = LatLng(28.076800, 30.836215); // موقع الكاميرا الحالي

@override
Widget build(BuildContext context) {
  return SafeArea(
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GoogleMap(
            onCameraMove: (position) {
              setState(() {
                currentZoom = position.zoom; // تحديث مستوى التكبير عند تحريك الكاميرا
                currentCameraPosition = position.target; // حفظ موقع الكاميرا الحالي
              });
            },
            mapType: MapType.hybrid,
            initialCameraPosition: myCurrentLocation ?? MiniaNationalUniversity,
            markers: markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),

          // شريط التحكم في الإمالة
          Positioned(
            bottom: 100, // تحديد موقعه فوق الزر
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  "Tilt: ${tiltAngle.toStringAsFixed(1)}°",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Slider(
                  value: tiltAngle,
                  min: 0.0,
                  max: 90.0,
                  divisions: 9,
                  label: "${tiltAngle.toStringAsFixed(0)}°",
                  onChanged: (value) {
                    setState(() {
                      tiltAngle = value;
                    });
                    updateCameraTilt(); // تحديث الإمالة فقط
                  },
                ),
              ],
            ),
          ),

          // زر الذهاب إلى موقعي الحالي
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20, bottom: 20),
              child: FloatingActionButton.extended(
                onPressed: _goToMyLocation,
                label: const Text('To the my location!'),
                icon: const Icon(Icons.my_location),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// 🔹 تحديث الكاميرا عند تغيير `tilt` فقط بدون تحريك الموقع
Future<void> updateCameraTilt() async {
  final GoogleMapController controller = await _controller.future;
  await controller.animateCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(
        target: currentCameraPosition, // لا تغير الموقع
        zoom: currentZoom, // استخدام مستوى التكبير الحالي
        tilt: tiltAngle, // تحديث زاوية الإمالة فقط
      ),
    ),
  );
}

// 🔹 الانتقال إلى موقعي عند الضغط على الزر فقط
Future<void> _goToMyLocation() async {
  if (locationData == null) return;

  final GoogleMapController controller = await _controller.future;
  setState(() {
    currentCameraPosition = LatLng(locationData!.latitude!, locationData!.longitude!);
  });

  await controller.animateCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(
        target: currentCameraPosition,
        zoom: 19.151926040649414,
        tilt: tiltAngle, // الحفاظ على نفس زاوية الإمالة
      ),
    ),
  );
}

  Location location = Location();
  PermissionStatus? permissionStatus;
  bool serviceEnabled = false;
  CameraPosition? myCurrentLocation;
  LocationData? locationData;
  StreamSubscription<LocationData>? streamSubscription;


LatLng? lastLocation;
double? lastHeading;

void updateUserLocation() async {
  if (locationData == null) return;

  LatLng newLocation = LatLng(locationData!.latitude!, locationData!.longitude!);
  double newHeading = compassHeading ?? 0;

  // التحقق إذا كان الموقع أو الاتجاه لم يتغير، لتجنب التحديثات غير الضرورية
  if (newLocation == lastLocation && newHeading == lastHeading) return;

  setState(() {
    markers.removeWhere((marker) => marker.markerId.value == 'userLocation');
    markers.add(
      Marker(
        markerId: MarkerId('userLocation'),
        position: newLocation,
        rotation: newHeading, // تحديث زاوية العلامة مع دوران الجهاز
      ),
    );

    // تحديث آخر موقع وزاوية معروفة
    lastLocation = newLocation;
    lastHeading = newHeading;
  });
}

void requestLocationPermission() async {
  PermissionStatus permission = await location.hasPermission();
  
  if (permission == PermissionStatus.denied) {
    permission = await location.requestPermission();
  }

  if (permission == PermissionStatus.granted) {
    print("✅ إذن الموقع مُنح بنجاح!");
    getCurrentLocation(); // يتم استدعاؤها هنا بعد منح الإذن
  } else if (permission == PermissionStatus.deniedForever) {
    print("🚫 تم رفض الإذن نهائيًا! اطلبه يدويًا من الإعدادات.");
  }
}

void getCurrentLocation() async {
  streamSubscription?.cancel(); // تأكد من إلغاء الاشتراك السابق
  if (!await isServiceEnabled() || !await isPermissionGranted()) return;

  locationData = await location.getLocation();
  location.changeSettings(accuracy: LocationAccuracy.high);

  streamSubscription = location.onLocationChanged.listen((event) {
    locationData = event;
    updateUserLocation();
  });

  updateUserLocation();
}

  Future<bool> isServiceEnabled() async {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }
    return serviceEnabled;
  }

  Future<bool> isPermissionGranted() async {
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
    }
    return permissionStatus == PermissionStatus.granted;
  }

void startCompass() {
  FlutterCompass.events?.listen((event) {
    if (event.heading != null) {
      setState(() {
        compassHeading = event.heading; // تحديث زاوية الاتجاه
      });
      updateUserLocation();
    }
  });
}

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }
}
