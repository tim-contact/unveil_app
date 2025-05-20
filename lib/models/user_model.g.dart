// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  uid: json['uid'] as String? ?? '',
  name: json['name'] as String? ?? '',
  email: json['email'] as String? ?? '',
  signedInAt: const TimestampConverter().fromJson(json['signedInAt']),
  location: const PositionConverter().fromJson(json['location']),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'uid': instance.uid,
  'name': instance.name,
  'email': instance.email,
  'signedInAt': const TimestampConverter().toJson(instance.signedInAt),
  'location': const PositionConverter().toJson(instance.location),
};
