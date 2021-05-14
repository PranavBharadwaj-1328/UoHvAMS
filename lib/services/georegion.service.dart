import 'package:flutter_geofence/geofence.dart';

class GeoRegionInitialize {
  static final GeoRegionInitialize _geoRegionInitializeService =
      GeoRegionInitialize._internal();

  factory GeoRegionInitialize() {
    return _geoRegionInitializeService;
  }
  // singleton boilerplate
  GeoRegionInitialize._internal();

  var geoRegions = [
    Geolocation(
        latitude: 17.4301783,
        longitude: 78.5421611,
        radius: 10,
        id: "NKS home"),
    Geolocation(
        latitude: 17.397909,
        longitude: 78.5199671,
        radius: 10.0,
        id: "PB Home"),
    Geolocation(
        latitude: 17.503565,
        longitude: 78.356778,
        radius: 20.0,
        id: "Rohan Home"),
    Geolocation(
        latitude: 17.504054,
        longitude: 78.357531,
        radius: 20.0,
        id: "Rohan Home")
  ];

  addGeoRegions() {
    for (Geolocation geoRegion in geoRegions) {
      Geofence.addGeolocation(geoRegion, GeolocationEvent.entry).then((onValue) {
        print("great success");
        print(geoRegion.id + " added");
        // scheduleNotification(
        //   "Georegion added",
        //   "Your geofence has been added!",
        // );
      }).catchError((onError) {
        print("great failure");
      });
    }
  }
}
