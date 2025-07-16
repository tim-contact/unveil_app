import 'package:json_annotation/json_annotation.dart';
part 'event_model.g.dart';

DateTime? _dateTimeFromJson(String? date) {
  if (date == null || date.isEmpty) {
    return null;
  }
  return DateTime.parse(date);
}

String? _dateTimeToJson(DateTime? date) {
  if (date == null) {
    return null;
  }
  return date.toIso8601String();
}

@JsonSerializable()
class EventModel {
  String? id;
  String? eventType;
  String? eventName;
  String? eventVenue;
  String? eventVenueAddress;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? startDateTime;
  DateTime? endDateTime;
  String? is_free;
  String? entranceFee;
  String? contactNumber;
  String? description;
  String? specialGuests;
  String? image_url;
  List<String>? allMediaUrls;

  @JsonKey(defaultValue: false, includeFromJson: false, includeToJson: false)
  bool isFavorite;

  EventModel({
    this.id,
    this.eventType,
    this.eventName,
    this.eventVenue,
    this.eventVenueAddress,
    this.startDateTime,
    this.endDateTime,
    this.is_free,
    this.entranceFee,
    this.contactNumber,
    this.description,
    this.specialGuests,
    this.image_url,
    this.allMediaUrls,
    this.isFavorite = false,
  });

  EventModel copyWith({
    String? id,
    String? eventType,
    String? eventName,
    String? eventVenue,
    String? eventVenueAddress,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? is_free,
    String? entranceFee,
    String? contactNumber,
    String? description,
    String? specialGuests,
    String? image_url,
    List<String>? allMediaUrls,
    bool? isFavorite,
  }) {
    return EventModel(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      eventName: eventName ?? this.eventName,
      eventVenue: eventVenue ?? this.eventVenue,
      eventVenueAddress: eventVenueAddress ?? this.eventVenueAddress,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      is_free: is_free ?? this.is_free,
      entranceFee: entranceFee ?? this.entranceFee,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      specialGuests: specialGuests ?? this.specialGuests,
      image_url: image_url ?? this.image_url,
      allMediaUrls: allMediaUrls ?? this.allMediaUrls,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] is int ? json['id'].toString() : json['id'] as String?,
      eventType:
          json['eventType'] is int
              ? json['eventType'].toString()
              : json['eventType'] as String?,
      eventName:
          json['eventName'] is int
              ? json['eventName'].toString()
              : json['eventName'] as String?,
      eventVenue:
          json['eventVenue'] is int
              ? json['eventVenue'].toString()
              : json['eventVenue'] as String?,
      eventVenueAddress:
          json['eventVenueAddress'] is int
              ? json['eventVenueAddress'].toString()
              : json['eventVenueAddress'] as String?,
      startDateTime: _dateTimeFromJson(json['startDateTime'] as String?),
      endDateTime: _dateTimeFromJson(json['endDateTime'] as String?),
      is_free:
          json['is_free'] is bool
              ? json['is_free'].toString()
              : json['is_free'] as String?,
      entranceFee:
          json['entranceFee'] is int
              ? json['entranceFee'].toString()
              : json['entranceFee'] as String?,
      contactNumber:
          json['contactNumber'] is int
              ? json['contactNumber'].toString()
              : json['contactNumber'] as String?,
      description:
          json['description'] is int
              ? json['description'].toString()
              : json['description'] as String?,
      specialGuests:
          json['specialGuests'] is int
              ? json['specialGuests'].toString()
              : json['specialGuests'] as String?,
      image_url:
          json['image_url'] is int
              ? json['image_url'].toString()
              : json['image_url'] as String?,
      allMediaUrls:
          (json['all_media_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => _$EventModelToJson(this);

  String get displayStartDate {
    if (startDateTime == null) {
      return 'Date not available';
    }

    final localTime = startDateTime!.toLocal();
    return "${localTime.day.toString().padLeft(2, '0')}/${localTime.month.toString().padLeft(2, '0')}/${localTime.year}";
  }

  String get displayStartTime {
    if (endDateTime == null) {
      return 'Date not available';
    }

    final localTime = endDateTime!.toLocal();
    return "${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}";
  }

  String get displayFullStartTime {
    if (startDateTime == null) {
      return 'Date not available';
    }
    return "$displayStartDate at $displayStartTime";
  }
}
