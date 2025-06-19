// import 'package:flutter/material.dart';
// import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:google_fonts/google_fonts.dart';

// class MapPage extends StatefulWidget {
//   const MapPage({super.key});

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   String locationName = '...';

//   final MapController controller = MapController(
//     initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
//     areaLimit: BoundingBox(
//       east: 10.4922941,
//       north: 47.8084648,
//       south: 45.817995,
//       west: 5.9559113,
//     ),
//   );

//   @override
//   void initState() {
//     super.initState();
//     _getLocationName();
//   }

//   Future<void> _getLocationName() async {
//     try {
//       // Try to get current position
//       Position position;
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       LocationPermission permission = await Geolocator.checkPermission();

//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever ||
//           !serviceEnabled) {
//         position = (await Geolocator.getLastKnownPosition())!;
//       } else {
//         position = await Geolocator.getCurrentPosition(
//           locationSettings: AndroidSettings(accuracy: LocationAccuracy.high),
//         );
//       }

//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );

//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks.first;
//         setState(() {
//           locationName =
//               (place.subLocality ??
//                       place.subAdministrativeArea ??
//                       place.locality ??
//                       "your area")
//                   .toString();
//         });
//       } else {
//         setState(() {
//           locationName = "Unknown";
//         });
//       }

//       final userGeoPoint = GeoPoint(
//         latitude: position.latitude,
//         longitude: position.longitude,
//       );

//       // Move to location
//       await controller.moveTo(userGeoPoint);

//       // Zoom based on accuracy
//       final zoomLevel = (position.accuracy < 100) ? 15.0 : 11.0;
//       await controller.setZoom(zoomLevel: zoomLevel);

//       // Add marker
//       await controller.addMarker(
//         userGeoPoint,
//         markerIcon: MarkerIcon(
//           icon: Icon(Icons.circle, color: Colors.blueAccent, size: 16),
//         ),
//       );
//     } catch (e) {
//       setState(() {
//         locationName = "Error";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Shelter Locations near $locationName",
//           style: GoogleFonts.poppins(color: Colors.black),
//         ),
//         centerTitle: true,
//       ),
//       body: OSMFlutter(
//         controller: controller,
//         osmOption: OSMOption(
//           userTrackingOption: const UserTrackingOption(
//             enableTracking: false,
//             unFollowUser: false,
//           ),
//           zoomOption: const ZoomOption(
//             initZoom: 8,
//             minZoomLevel: 3,
//             maxZoomLevel: 19,
//             stepZoom: 1.0,
//           ),
//           userLocationMarker: UserLocationMaker(
//             personMarker: const MarkerIcon(
//               icon: Icon(
//                 Icons.location_history_rounded,
//                 color: Colors.red,
//                 size: 48,
//               ),
//             ),
//             directionArrowMarker: const MarkerIcon(
//               icon: Icon(Icons.double_arrow, size: 48),
//             ),
//           ),
//           roadConfiguration: const RoadOption(roadColor: Colors.yellowAccent),
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: non_constant_identifier_names, avoid_print

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
    _getLocationName();
    _Permissions();
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

      final userGeoPoint = GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        userGeoPoint.latitude,
        userGeoPoint.longitude,
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
        // Fallback to center of the map
        GeoPoint center = await controller.centerMap;
        List<Placemark> centerPlacemarks = await placemarkFromCoordinates(
          center.latitude,
          center.longitude,
        );

        if (centerPlacemarks.isNotEmpty) {
          Placemark place = centerPlacemarks.first;
          setState(() {
            locationName =
                (place.subLocality ??
                        place.subAdministrativeArea ??
                        place.locality ??
                        "map center")
                    .toString();
          });
        } else {
          setState(() {
            locationName = "map center";
          });
        }
      }

      // Move to location
      await controller.moveTo(userGeoPoint);

      // Zoom based on accuracy
      final zoomLevel = (position.accuracy < 100) ? 15.0 : 11.0;
      await controller.setZoom(zoomLevel: zoomLevel);

      // Add marker
      await controller.addMarker(
        userGeoPoint,
        markerIcon: MarkerIcon(
          icon: Icon(Icons.circle, color: Colors.blueAccent, size: 16),
        ),
      );
    } catch (e) {
      setState(() {
        locationName = "Error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            personMarker: const MarkerIcon(
              icon: Icon(
                Icons.location_history_rounded,
                color: Colors.red,
                size: 48,
              ),
            ),
            directionArrowMarker: const MarkerIcon(
              icon: Icon(Icons.double_arrow, size: 48),
            ),
          ),
          roadConfiguration: const RoadOption(roadColor: Colors.yellowAccent),
        ),
      ),
    );
  }
}
