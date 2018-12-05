
class LocationLog {
  int id;
  double latitude;
  double longitude;
  int time;

  static final columns = ["id", "latitude", "longitude", "created"];

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      "latitude": latitude == null ? 0.0 : latitude,
      "longitude": longitude == null ? 0.0 : longitude
    };
    if (id != null) {
      map["id"] = id;
    }
    return map;
  }

  LocationLog();

  static LocationLog fromMap(Map<String, dynamic> map) {
    LocationLog locationLog = LocationLog();
    locationLog.id = map["id"];
    locationLog.longitude = map["longitude"];
    locationLog.latitude = map["latitude"];
    locationLog.time = map["created"];
    return locationLog;
  }
}