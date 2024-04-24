import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker_app/utils/location_service.dart';
import 'package:route_tracker_app/widgets/custom_text_field.dart';
//import 'package:location/location.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late CameraPosition initalCameraPosition;
  late LocationService locationService;
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    initalCameraPosition = const CameraPosition(target: LatLng(0, 0));
    locationService = LocationService();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          zoomControlsEnabled: false,
          initialCameraPosition: initalCameraPosition,
          markers: markers,
          onMapCreated: (controller) {
            googleMapController = controller;
            Positioned(
                top: 16, left: 16, right: 16, child: const CustomTextField());
            updateCurrentLocation();
          },
        ),
      ],
    );
  }

  void updateCurrentLocation() async {
    try {
      var locationData = await locationService.getLocation();
      LatLng currentPosition =
          LatLng(locationData.latitude!, locationData.longitude!);
      Marker currentLocationMarker = Marker(
        markerId: MarkerId('my location'),
        position: currentPosition,
      );
      markers.add(currentLocationMarker);
      setState(() {});
      CameraPosition myCurrentCameraPosition = CameraPosition(
        target: LatLng(locationData.latitude!, locationData.longitude!),
        zoom: 16,
      );
      googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(myCurrentCameraPosition));
    } on LocationServiceException catch (e) {
      // TODO
    } on LocationPermissionException catch (e) {
      // TODO
    } catch (e) {
      // TODO
    }
  }
}

