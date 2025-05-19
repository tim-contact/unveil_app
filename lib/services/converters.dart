import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:location/location.dart';

class TimestampConverter implements JsonConverter<Timestamp?, Object?> {
  const TimestampConverter();

  @override
  Timestamp? fromJson(Object? json) {
    if (json is Timestamp) return json;
    if (json is String) return Timestamp.fromDate(DateTime.parse(json));
    return null;
  }

  @override
  Object? toJson(Timestamp? timestamp) => timestamp;
}

class PositionConverter implements JsonConverter<LocationData?, dynamic> {
  const PositionConverter();

  @override
  LocationData? fromJson(dynamic json) {
    if (json is GeoPoint) {
      // Create a LocationData object. Some fields might not be available from GeoPoint.
      return LocationData.fromMap({
        'latitude': json.latitude,
        'longitude': json.longitude,
        // GeoPoint doesn't store accuracy, speed, altitude, etc.
        // You can set them to default values or null if your app doesn't strictly need them
        // when reading back from Firestore.
        'accuracy': 0.0,
        'altitude': 0.0,
        'speed': 0.0,
        'speed_accuracy': 0.0,
        'heading': 0.0,
        'time':
            DateTime.now().millisecondsSinceEpoch
                .toDouble(), // GeoPoint has no timestamp
        'is_mock': false, // Default value
        'vertical_accuracy': 0.0, // New fields in location ^5.0.0
        'heading_accuracy': 0.0,
        'elapsed_realtime_nanos': 0.0,
        'elapsed_realtime_uncertainty_nanos': 0.0,
        'satellite_number': 0,
        'provider': '',
      });
    } else if (json is Map<String, dynamic>) {
      // If already stored as a map (e.g. by json_serializable itself if not for Firestore)
      try {
        return LocationData.fromMap(
          json.cast<String, double>(),
        ); // Ensure correct types
      } catch (e) {
        print("Error converting map to LocationData: $e, map: $json");
        return null;
      }
    }
    return null;
  }

  @override
  dynamic toJson(LocationData? object) {
    if (object != null && object.latitude != null && object.longitude != null) {
      return GeoPoint(object.latitude!, object.longitude!);
    }
    return null; // Or FieldValue.delete() if you want to remove it
  }
}
