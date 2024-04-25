import 'package:route_tracker_app/models/location_info/location_info.dart';

//import 'location.dart';

class LocationInfoModel {
  LocationInfoModel? location;

  LocationInfoModel({this.location});

  factory LocationInfoModel.fromJson(Map<String, dynamic> json) =>
      LocationInfoModel(
        location: json['location'] == null
            ? null
            : LocationInfoModel.fromJson(json['location'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'location': location?.toJson(),
      };
}