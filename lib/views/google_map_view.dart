import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:route_tracker_app/models/location_info/lat_lng.dart';
import 'package:route_tracker_app/models/location_info/location.dart';
import 'package:route_tracker_app/models/location_info/location_info.dart';
import 'package:route_tracker_app/models/places_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker_app/models/routes_model/route.dart';
import 'package:route_tracker_app/models/routes_model/routes_model.dart';
import 'package:route_tracker_app/utils/map_services.dart';
import 'package:route_tracker_app/utils/google_map_place_service.dart';
import 'package:route_tracker_app/utils/location_service.dart';
import 'package:route_tracker_app/utils/routes_service.dart';
import 'package:route_tracker_app/widgets/custom_list_view.dart';
import 'package:uuid/uuid.dart';
import 'package:route_tracker_app/widgets/custom_text_field.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late CameraPosition initalCameraPosition;
  late MapServices mapServices;
  late TextEditingController textEditingController;
  late GoogleMapController googleMapController;
  String? sesstionToken;
  late Uuid uuid;
  Set<Marker> markers = {};
  List<PlaceModel> places = [];
  Set<Polyline> polyLines = {};
  late LatLng destination;
  Timer? debounce;

  @override
  void initState() {
    mapServices = MapServices();
    uuid = const Uuid();
    textEditingController = TextEditingController();
    initalCameraPosition = const CameraPosition(target: LatLng(0, 0));
    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() {
      if (debounce?.isActive ?? false) {
        debounce?.cancel();
      }
      debounce = Timer(const Duration(milliseconds: 100), () async {
        sesstionToken ??= uuid.v4();
        await mapServices.getPredictions(
            input: textEditingController.text,
            sesstionToken: sesstionToken!,
            places: places);
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    textEditingController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          polylines: polyLines,
          markers: markers,
          onMapCreated: (controller) {
            googleMapController = controller;
            updateCurrentLocation();
          },
          zoomControlsEnabled: false,
          initialCameraPosition: initalCameraPosition,
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            children: [
              CustomTextField(
                textEditingController: textEditingController,
              ),
              const SizedBox(
                height: 16,
              ),
              CustomListView(
                onPlaceSelect: (placeDetailsModel) async {
                  textEditingController.clear();
                  places.clear();
                  sesstionToken = null;
                  setState(() {});
                  destination = LatLng(
                      placeDetailsModel.geometry!.location!.lat!,
                      placeDetailsModel.geometry!.location!.lng!);
                  var points =
                      await mapServices.getRouteData(desintation: destination);
                  mapServices.displayRoute(points,
                      polyLines: polyLines,
                      googleMapController: googleMapController);
                  setState(() {});
                },
                places: places,
                mapServices: mapServices,
              )
            ],
          ),
        ),
      ],
    );
  }

  void updateCurrentLocation() {
    try {
      mapServices.updateCurrentLocation(
        onUpdatecurrentLocation: () {
          setState(() {});
        },
        googleMapController: googleMapController,
        markers: markers,
      );
    } on LocationServiceException catch (e) {
      // TODO
    } on LocationPermissionException catch (e) {
      // TODO
    } catch (e) {
      // TODO
    }
  }
}
