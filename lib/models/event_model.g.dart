// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
  id: json['id'] as String?,
  eventType: json['eventType'] as String?,
  eventName: json['eventName'] as String?,
  eventVenue: json['eventVenue'] as String?,
  eventVenueAddress: json['eventVenueAddress'] as String?,
  startDateTime: _dateTimeFromJson(json['startDateTime'] as String?),
  endDateTime:
      json['endDateTime'] == null
          ? null
          : DateTime.parse(json['endDateTime'] as String),
  is_free: json['is_free'] as String?,
  entranceFee: json['entranceFee'] as String?,
  contactNumber: json['contactNumber'] as String?,
  description: json['description'] as String?,
  specialGuests: json['specialGuests'] as String?,
  image_url: json['image_url'] as String?,
  allMediaUrls:
      (json['allMediaUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventType': instance.eventType,
      'eventName': instance.eventName,
      'eventVenue': instance.eventVenue,
      'eventVenueAddress': instance.eventVenueAddress,
      'startDateTime': _dateTimeToJson(instance.startDateTime),
      'endDateTime': instance.endDateTime?.toIso8601String(),
      'is_free': instance.is_free,
      'entranceFee': instance.entranceFee,
      'contactNumber': instance.contactNumber,
      'description': instance.description,
      'specialGuests': instance.specialGuests,
      'image_url': instance.image_url,
      'allMediaUrls': instance.allMediaUrls,
    };
