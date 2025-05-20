import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;

class LocationService {
  final Location _location = Location();

  /// Fetches the current user location.
  ///
  /// This method will:
  /// 1. Check if location services are enabled on the device.
  /// 2. Request to enable services if they are not.
  /// 3. Check for location permissions.
  /// 4. Request permissions if they are denied.
  /// 5. Fetch the current location data.
  ///
  /// Returns [LocationData?] - the location data if successful, or null if
  /// services are not enabled, permissions are denied, or an error occurs.
  Future<LocationData?> getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData? locationData;

    // Check if location service is enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      print("Location service is not enabled. Requesting service...");
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        print("Location service was not enabled by the user.");
        return null; // Service not enabled by user
      }
    }
    print("Location service is enabled.");

    // Check for location permission
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      print("Location permission is denied. Requesting permission...");
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print("Location permission was not granted by the user.");
        return null; // Permission not granted by user
      }
    }
    if (permissionGranted == PermissionStatus.deniedForever) {
      print(
        "Location permission is permanently denied. User needs to go to settings.",
      );
      // Optionally, you can guide the user to app settings here
      return null; // Permission permanently denied
    }
    print("Location permission is granted.");

    try {
      print("Fetching location data...");
      // Set accuracy for better results, if needed, though default is usually fine for one-off.
      // await _location.changeSettings(accuracy: LocationAccuracy.high);
      locationData = await _location.getLocation();
      print(
        "Location data received: Lat: ${locationData.latitude}, Lon: ${locationData.longitude}",
      );
      return locationData;
    } catch (e) {
      print("Error getting location: $e");
      return null; // Error occurred
    }
  }

  /// Listens for continuous location updates.
  ///
  /// Remember to cancel the subscription when it's no longer needed
  /// to avoid memory leaks and unnecessary battery drain.
  Stream<LocationData> get onLocationChanged => _location.onLocationChanged;

  /// Enables or disables background location updates.
  ///
  /// **Warning:** Using background location significantly impacts battery life
  /// and requires clear justification for app store reviews.
  Future<void> enableBackgroundMode({required bool enable}) async {
    try {
      await _location.enableBackgroundMode(enable: enable);
      print("Background location mode ${enable ? 'enabled' : 'disabled'}.");
    } catch (e) {
      print("Error enabling/disabling background mode: $e");
    }
  }

  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        geo.Placemark place = placemarks.first;
        // You can build the address string as detailed or simple as you like:
        String address = "";
        if (place.street != null && place.street!.isNotEmpty) {
          address += "${place.street}, ";
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          // Neighborhood/Sub-district
          address += "${place.subLocality}, ";
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          // City
          address += "${place.locality}, ";
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          // State/Province
          address += "${place.administrativeArea}, ";
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          address += "${place.postalCode}, ";
        }
        if (place.country != null && place.country!.isNotEmpty) {
          address += "${place.country}";
        }
        // Remove trailing comma and space if any
        if (address.endsWith(", ")) {
          address = address.substring(0, address.length - 2);
        }
        return address.isEmpty ? "Unknown location" : address;
      } else {
        return "No address found for coordinates.";
      }
    } catch (e) {
      print("Error getting address from coordinates: $e");
      if (e is geo.NoResultFoundException) {
        return "No address results found.";
      }
      return "Could not fetch address.";
    }
  }
}
