import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker_app/models/place_details_model/place_details_model.dart';

import '../models/places_autocomplete_model/place_autocomplete_model.dart';

class CustomListView extends StatelessWidget {
  const CustomListView({
    super.key,
    required this.places,
    this.googleMapsPlacesService,
    required this.onPlaceSelect,
  });
  final List<PlaceModel> places;
  final void Function(PlaceDetailsModel) onPlaceSelect;
  final GoogleMapsPlacesService googleMapsPlacesService;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(FontAwesomeIcons.mapPin),
            title: Text(
              places[index].description!,
            ),
            trailing: IconButton(
              onPressed: () async {
                var placeDetails = await googleMapsPlacesService
                    .getPlaceDetails(placeId: places[index].placeId.toString());
                onPlaceSelect(placeDetails);
              },
              icon: Icon(Icons.arrow_circle_right_outlined),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 0,
          );
        },
        itemCount: places.length,
      ),
    );
  }
}
