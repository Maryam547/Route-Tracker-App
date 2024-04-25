import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker_app/models/place_details_model/place_details_model.dart';
import 'package:route_tracker_app/models/places_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker_app/utils/google_map_place_service.dart';
import 'package:route_tracker_app/utils/location_service.dart';
import 'package:route_tracker_app/utils/routes_service.dart';

class MapServices {
  PlacesService placesService = PlacesService();
  LocationService locationService = LocationService();
  RoutesService routesService = RoutesService();
  LatLng? currentLocation;
  Future<void> getPredictions(
      {required String input,
      required String sesstionToken,
      required List<PlaceModel> places}) async {
    if (input.isNotEmpty) {
      var result = await placesService.getPredictions(
          sesstionToken: sesstionToken, input: input);

      places.clear();
      places.addAll(result);
    } else {
      places.clear();
    }
  }
  
Future<PlaceDetailsModel> getPlaceDetails({required String placeId}) async {
    return await placesService.getPlaceDetails(placeId: placeId);
  }
}
