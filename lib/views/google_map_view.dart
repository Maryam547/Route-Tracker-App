import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker_app/utils/location_service.dart';
//import 'package:location/location.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late CameraPosition initalCameraPosition;
  late LocationService locationService;

  @override
  void initState() {
    initalCameraPosition = const CameraPosition(target: LatLng(0, 0));
    locationService = LocationService();
    void updateCurrentLocation()async{
      try {
  var locationData = await locationService.getLocation();
} on LocationServiceException catch (e) {
  // TODO
} on LocationPermissionException catch (e) {
  // TODO
} catch (e) {
  // TODO
}
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      zoomControlsEnabled: false,
      initialCameraPosition: initalCameraPosition,
    );
  }
}
