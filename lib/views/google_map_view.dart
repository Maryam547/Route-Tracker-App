import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:route_tracker_app/models/places_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker_app/utils/google_map_place_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker_app/utils/location_service.dart';
import 'package:route_tracker_app/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';
//import 'package:location/location.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late CameraPosition initalCameraPosition;

  late GoogleMapsPlacesService googleMapsPlacesService;
  late LocationService locationService;
  late TextEditingController textEditingController;
  late GoogleMapController googleMapController;
  String? sesstionToken;
  late Uuid uuid;
  Set<Marker> markers = {};
  List<PlaceModel> places = [];

  @override
  void initState() {
    uuid = const Uuid();
    googleMapsPlacesService = GoogleMapsPlacesService();
    textEditingController = TextEditingController();
    initalCameraPosition = const CameraPosition(target: LatLng(0, 0));
    locationService = LocationService();
    fetchPredictions();

    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      sesstionToken ??= uuid.v4();
      if (textEditingController.text.isNotEmpty) {
        var result = await googleMapsPlacesService.getPredictions(
            sesstionToken: sesstionToken!, input: textEditingController.text);
        places.clear();
        sesstionToken = null;
        places.addAll(result);
        setState(() {});
      } else {
        places.clear();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(uuid.v4());
    return Stack(
      children: [
        GoogleMap(
          zoomControlsEnabled: false,
          initialCameraPosition: initalCameraPosition,
          markers: markers,
          onMapCreated: (controller) {
            googleMapController = controller;
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  CustomTextField(
                    textEditingController: textEditingController,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  CustomListView(
                    onPlaceSelect: (placeDetailsModel) async {
                      textEditingController.clear();
                      places.clear();
                      setState(() {});
                      //print(placeDetailsModel.geometry!.location.lat);
                    },
                    places: places,
                    googleMapsPlacesService: googleMapsPlacesService,
                  )
                ],
              ),
            );
            //updateCurrentLocation();
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
