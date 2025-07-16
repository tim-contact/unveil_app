import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:unveilapp/services/converters.dart';
import 'package:location/location.dart';
part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  String? uid;
  String? name;
  String? email;

  @TimestampConverter()
  Timestamp? signedInAt;

  @PositionConverter()
  LocationData? location;

  List<int> favoriteEventIds = [];

  UserModel({
    this.uid = '',
    this.name = '',
    this.email = '',
    List<int>? favoriteEventIds,
    Timestamp? signedInAt,
    LocationData? location,
  }) : signedInAt = signedInAt ?? Timestamp.now(),
       favoriteEventIds = favoriteEventIds ?? <int>[],
       location =
           location ??
           LocationData.fromMap({
             'latitude': 0.0,
             'longitude': 0.0,
             'accuracy': 0.0,
             'altitude': 0.0,
             'speed': 0.0,
             'speed_accuracy': 0.0,
             'heading': 0.0,
             'time': DateTime.now().millisecondsSinceEpoch.toDouble(),
             'is_mock': false,
             'vertical_accuracy': 0.0,
             'heading_accuracy': 0.0,
             'elapsed_realtime_nanos': 0.0,
             'elapsed_realtime_uncertainty_nanos': 0.0,
             'satellite_number': 0,
             'provider': '',
           });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    // Use the generated _$UserModelFromJson, but ensure uid is handled correctly
    // If uid is NOT a field in Firestore, then we add it from snapshot.id
    final userFromJson = _$UserModelFromJson(data ?? {});
    return UserModel(
      uid: snapshot.id,
      name: userFromJson.name,
      email: userFromJson.email,
      signedInAt: userFromJson.signedInAt,
      location: userFromJson.location,
      favoriteEventIds: userFromJson.favoriteEventIds,
    );
  }

  Map<String, dynamic> toFirestore() {
    final json = _$UserModelToJson(this);
    json.remove('uid'); // Remove uid if it exists in the model
    return json;
  }
}
