import 'lat_lng.dart';

class LocationInfoModel {
  LatLngModel? latLng;

  LocationInfoModel({this.latLng});

  factory LocationInfoModel.fromJson(Map<String, dynamic> json) => LocationInfoModel(
        latLng: json['latLng'] == null
            ? null
            : LatLngModel.fromJson(json['latLng'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'latLng': latLng?.toJson(),
      };
}