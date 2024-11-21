import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:testing_flutter_google_map/constants/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng pGooglePlex = const LatLng(23.8041, 90.4152);
  LatLng pApplePark = const LatLng(23.8298, 90.3636);
  Location location = Location();
  LatLng? currentPosition;
  final Completer<GoogleMapController> mapController = Completer<GoogleMapController>();
  Map<PolylineId,Polyline> polyLines = {};

  @override
  void initState() {
    getLocationUpdates().then((_)=> {
      getPolyLinePoints().then((coordinates)=>{
        generatePolyLineFromPoints(coordinates)
      })
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPosition == null
          ? const Center(
              child: Text("Loading..."),
            )
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) =>
                  mapController.complete(controller),
              initialCameraPosition: CameraPosition(
                target: pGooglePlex,
                zoom: 13,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: currentPosition!,
                ),
                Marker(
                  markerId: const MarkerId('sourceLocation'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: pGooglePlex,
                ),
                Marker(
                  markerId: const MarkerId('destinationLocation'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: pApplePark,
                )
              },
            ),
    );
  }

  Future<List<LatLng>> getPolyLinePoints() async {
    List<LatLng> polyLineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult polylineResult =
        await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: GOOGLE_MAPS_API_KEY,
      request: PolylineRequest(
        origin: PointLatLng(pGooglePlex.latitude, pGooglePlex.longitude),
        destination: PointLatLng(pApplePark.latitude, pApplePark.longitude),
        mode: TravelMode.driving,
      ),
    );
    log("Polyline result ${polylineResult.points}");
    if (polylineResult.points.isNotEmpty) {
      polylineResult.points.forEach((PointLatLng point) {
        polyLineCoordinates.add(LatLng(point.latitude, point.longitude),);
      });
    } else {
      log("Error is ${polylineResult.errorMessage}");
    }
    return polyLineCoordinates;
  }

  Future<void> cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await mapController.future;
    CameraPosition newCameraPosition = CameraPosition(target: pos, zoom: 13);
    await controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  Future<void> getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionStatus;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }
    location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          currentPosition =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          cameraToPosition(currentPosition!);
          log("Current position is $currentPosition");
        });
      }
    });
  }

  void generatePolyLineFromPoints(List<LatLng> polyLineCoordinates) async {
    PolylineId id = const PolylineId("poly");
    Polyline polyLine = Polyline(polylineId: id,color: Colors.black,points: polyLineCoordinates,width: 8);
    setState(() {
      polyLines[id] = polyLine;
    });
  }
}
