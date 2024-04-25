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

  late MapServices googleMapsPlacesService;
  late LocationService locationService;
  late TextEditingController textEditingController;
  late GoogleMapController googleMapController;
  String? sesstionToken;
  late Uuid uuid;
  Set<Marker> markers = {};
  late RoutesService routesService;
  Set<Polyline> polyLines = {};
  late LatLng currentLocation;
  late LatLng destination;
  List<PlaceModel> places = [];

  @override
  void initState() {
    uuid = const Uuid();
    googleMapsPlacesService = MapServices();
    textEditingController = TextEditingController();
    initalCameraPosition = const CameraPosition(target: LatLng(0, 0));
    locationService = LocationService();
    routesService = RoutesService();
    fetchPredictions();

    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() {
      sesstionToken ??= uuid.v4();
      if (textEditingController.text.isNotEmpty) {
        await MapServices.getPredictions(
            sesstionToken: sesstionToken!, input: textEditingController.text,places: places);
        //places.clear();
        //sesstionToken = null;
        //places.addAll(result);
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
          polylines: polyLines,
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
                      sesstionToken = null;
                      setState(() {});
                      destination = LatLng(placeDetailsModel.geometry!.location!.lat!, placeDetailsModel.geometry!.location!.lng!);
                      //print(placeDetailsModel.geometry!.location.lat);
                      var points = await getRouteData();
                      displayRoute(points);
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
      currentLocation =
          LatLng(locationData.latitude!, locationData.longitude!);
      Marker currentLocationMarker = Marker(
        markerId: MarkerId('my location'),
        position: currentLocation,
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
  
  Future<List<LatLng>> getRouteData() async{
    LocationInfoModel origin = LocationInfoModel(
      location:LocationModel(LatLng:LatLngModel(
      latitude: currentLocation.latitude,
      longitude: currentLocation.longitude,
    )),
    );
    LocationInfoModel destination = LocationInfoModel(
      location:LocationModel(LatLng:LatLngModel(
      latitude: destination.latitude,
      longitude: destination.longitude,
    )),
    );
    RoutesModel routes = await routesService.fetchRoutes(origin: origin, destination: destination);
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> points = getDecodedRoute(polylinePoints, routes);
    return points;
  }

  List<LatLng> getDecodedRoute(PolylinePoints polylinePoints, RoutesModel routes) {
    List<PointLatLng> result = polylinePoints.decodePolyline(routes.routes!.first.polyline!.encodedPolyline!);
    
    List<LatLng> points = result.map((e) => LatLng(e.latitude, e.longitude)).toList();
    return points;
  }
  
  void displayRoute(List<LatLng> points) {
    Polyline route = Polyline(
      color: Colors.blue,
      width: 5,
      polylineId: PolylineId('route'),
    points: points,

    );
    polyLines.add(route);
    setState(() {});
  }
}
