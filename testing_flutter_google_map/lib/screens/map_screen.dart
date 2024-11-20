import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng pGooglePlex = const LatLng(37.4223, -122.0848);
  LatLng pApplePark = const LatLng(37.3346, -122.0090);
  Location location = Location();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: pGooglePlex,
          zoom: 13,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('currentLocation'),
            icon: BitmapDescriptor.defaultMarker,
            position: pGooglePlex,
          ),
          Marker(
            markerId: const MarkerId('sourceLocation'),
            icon: BitmapDescriptor.defaultMarker,
            position: pApplePark,
          )
        },
      ),
    );
  }

  Future<void> getLocationUpdates() async {
    bool serviceEnable;
    PermissionStatus permissionStatus;
    serviceEnable = await location.serviceEnabled();
    if(serviceEnable){
      await location.requestPermission();
    }else{
      return;
    }
  }
}
