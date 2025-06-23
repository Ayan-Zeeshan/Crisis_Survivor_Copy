// ignore_for_file: non_constant_identifier_names, avoid_print

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String locationName = '...';
  GeoPoint? userGeoPoint;
  double width = 360; // default fallback

  final MapController controller = MapController(
    initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
    areaLimit: BoundingBox(
      east: 10.4922941,
      north: 47.8084648,
      south: 45.817995,
      west: 5.9559113,
    ),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () async {
      await _Permissions();
      await _getLocationName();
    });
  }

  Future<void> _Permissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationWhenInUse,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);
    if (!allGranted) {
      print('Permissions not granted');
      bool isPermanentlyDenied = statuses.values.any(
        (status) => status.isPermanentlyDenied,
      );
      if (isPermanentlyDenied) {
        print('Permissions permanently denied');
        openAppSettings();
      }
    } else {
      print('Permissions granted!');
    }
  }

  Future<void> _getLocationName() async {
    try {
      Position position;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          !serviceEnabled) {
        position = (await Geolocator.getLastKnownPosition())!;
      } else {
        position = await Geolocator.getCurrentPosition(
          locationSettings: AndroidSettings(accuracy: LocationAccuracy.high),
        );
      }

      userGeoPoint = GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        userGeoPoint!.latitude,
        userGeoPoint!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          locationName =
              (place.subLocality ??
                      place.subAdministrativeArea ??
                      place.locality ??
                      "your area")
                  .toString();
        });
      } else {
        setState(() {
          locationName = "map center";
        });
      }

      await controller.moveTo(userGeoPoint!);

      final zoomLevel = (position.accuracy < 100) ? 15.0 : 11.0;
      await controller.setZoom(zoomLevel: zoomLevel);

      await controller.addMarker(
        userGeoPoint!,
        markerIcon: MarkerIcon(
          icon: Icon(Icons.circle, color: Colors.blueAccent, size: width / 18),
        ),
      );

      await _addNearbyShelters(userGeoPoint!);
    } catch (e) {
      setState(() {
        locationName = "Error";
      });
    }
  }

  Future<void> _addNearbyShelters(GeoPoint userLocation) async {
    const int numberOfMarkers = 26;
    const double maxDistanceKm = 10;
    const double earthRadius = 6371.0;
    final Random random = Random();

    for (int i = 0; i < numberOfMarkers; i++) {
      final double distanceKm = random.nextDouble() * maxDistanceKm;
      final double bearing = random.nextDouble() * 2 * pi;

      final double lat1 = userLocation.latitude * pi / 180;
      final double lon1 = userLocation.longitude * pi / 180;

      final double lat2 = asin(
        sin(lat1) * cos(distanceKm / earthRadius) +
            cos(lat1) * sin(distanceKm / earthRadius) * cos(bearing),
      );

      final double lon2 =
          lon1 +
          atan2(
            sin(bearing) * sin(distanceKm / earthRadius) * cos(lat1),
            cos(distanceKm / earthRadius) - sin(lat1) * sin(lat2),
          );

      final double finalLat = lat2 * 180 / pi;
      final double finalLon = lon2 * 180 / pi;

      final GeoPoint shelterLocation = GeoPoint(
        latitude: finalLat,
        longitude: finalLon,
      );

      await controller.addMarker(
        shelterLocation,
        markerIcon: MarkerIcon(
          iconWidget: GestureDetector(
            onTap: () => _onShelterTapped(shelterLocation),
            child: Icon(
              Icons.location_on_sharp,
              color: const Color.fromARGB(194, 86, 61, 61),
              size: width / 4,
            ),
          ),
        ),
      );
    }
  }

  void _onShelterTapped(GeoPoint shelterLocation) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Shelter"),
          content: const Text(
            "Would you like to see directions to this shelter?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDirectionToShelter(shelterLocation);
              },
              child: const Text("Show Directions"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showDirectionToShelter(GeoPoint shelterLocation) async {
    if (userGeoPoint == null) return;

    await controller.drawRoad(
      userGeoPoint!,
      shelterLocation,
      roadType: RoadType.car,
      roadOption: const RoadOption(roadColor: Colors.deepOrange, roadWidth: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Shelter Locations near $locationName",
          style: GoogleFonts.poppins(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: OSMFlutter(
        controller: controller,
        osmOption: OSMOption(
          userTrackingOption: const UserTrackingOption(
            enableTracking: false,
            unFollowUser: false,
          ),
          zoomOption: const ZoomOption(
            initZoom: 8,
            minZoomLevel: 3,
            maxZoomLevel: 19,
            stepZoom: 1.0,
          ),
          userLocationMarker: UserLocationMaker(
            personMarker: MarkerIcon(
              icon: Icon(
                Icons.my_location_rounded,
                color: Colors.blue,
                size: width * 2,
              ),
            ),
            directionArrowMarker:MarkerIcon(
              icon: Icon(Icons.double_arrow, size: width / 2),
            ),
          ),
          roadConfiguration: const RoadOption(roadColor: Colors.yellowAccent),
        ),
      ),
    );
  }
}
