import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart' as loc;
import 'package:unveilapp/models/user_model.dart';
import 'package:unveilapp/services/auth_service.dart';
import 'package:unveilapp/services/firestore.dart';
import 'package:unveilapp/services/get_location.dart';
import 'package:geocoding/geocoding.dart' as geo;

class ProfilePage extends StatelessWidget {
  // Changed from ForYouPage to ProfilePage
  const ProfilePage({Key? key}) : super(key: key);

  // Method to update user location
  Future<void> _updateUserLocation(BuildContext context) async {
    try {
      final locationService = Provider.of<LocationService>(
        context,
        listen: false,
      );
      final firestoreService = Provider.of<FirestoreService>(
        context,
        listen: false,
      );
      final authService = Provider.of<AuthService>(context, listen: false);

      final User? currentUser = authService.user;
      if (currentUser == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user is currently signed in.')),
          );
        }
        return;
      }

      print("ProfilePage: Updating location for user: ${currentUser.uid}");

      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Updating location...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final locationData = await locationService.getCurrentLocation();

      if (locationData != null && context.mounted) {
        print(
          "ProfilePage: Got location - Lat: ${locationData.latitude}, Lon: ${locationData.longitude}",
        );

        // Only update the location field
        await firestoreService.updateUserLocation(
          currentUser.uid,
          locationData,
        );

        print("ProfilePage: Location updated successfully");

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print("ProfilePage: Failed to get location data");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to get location. Please check permissions.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print("ProfilePage: Error updating location: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating location: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      print(
        "LocationService: Converting coordinates to address: $latitude, $longitude",
      );

      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];

        // Build a readable address from available components
        List<String> addressComponents = [];

        if (place.street?.isNotEmpty == true) {
          addressComponents.add(place.street!);
        }
        if (place.subLocality?.isNotEmpty == true) {
          addressComponents.add(place.subLocality!);
        }
        if (place.locality?.isNotEmpty == true) {
          addressComponents.add(place.locality!);
        }
        if (place.administrativeArea?.isNotEmpty == true) {
          addressComponents.add(place.administrativeArea!);
        }
        if (place.country?.isNotEmpty == true) {
          addressComponents.add(place.country!);
        }

        String address = addressComponents.join(', ');
        print("LocationService: Address resolved: $address");
        return address.isNotEmpty ? address : null;
      } else {
        print("LocationService: No placemarks found for coordinates");
        return null;
      }
    } catch (e) {
      print("LocationService: Error converting coordinates to address: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );
    final User? firebaseUser = authService.user;

    if (firebaseUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your profile.')),
      );
    }

    // Trigger location update when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUserLocation(context);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: StreamBuilder<UserModel?>(
        stream: firestoreService.getUserStream(firebaseUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("ProfilePage StreamBuilder error: ${snapshot.error}");
            return Center(
              child: Text('Error loading profile: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_outlined, size: 60),
                  SizedBox(height: 16),
                  Text(
                    'User profile not found.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try signing out and signing back in.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final UserModel user = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () => _updateUserLocation(context),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                _buildProfileHeader(context, user),
                const SizedBox(height: 20),
                _buildInfoSection(context, user),
                const SizedBox(height: 20),
                _buildActionsSection(context, authService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Text(
                user.name?.isNotEmpty == true
                    ? user.name![0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name ?? 'No Name',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user.email ?? 'No Email',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, UserModel user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.calendar_today_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Joined On'),
            subtitle: Text(
              user.signedInAt != null
                  ? "${user.signedInAt!.toDate().day}/${user.signedInAt!.toDate().month}/${user.signedInAt!.toDate().year}"
                  : 'Date not available',
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildLocationInfo(context, user.location),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(
    BuildContext context,
    loc.LocationData? locationData,
  ) {
    if (locationData == null ||
        locationData.latitude == null ||
        locationData.longitude == null) {
      return ListTile(
        leading: Icon(
          Icons.location_off_outlined,
          color: Theme.of(context).colorScheme.error,
        ),
        title: const Text('Location'),
        subtitle: const Text('Not available or not shared'),
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _updateUserLocation(context),
          tooltip: 'Update location',
        ),
      );
    }

    final locationService = Provider.of<LocationService>(
      context,
      listen: false,
    );

    return FutureBuilder<String?>(
      future: locationService.getAddressFromCoordinates(
        locationData.latitude!,
        locationData.longitude!,
      ),
      builder: (context, snapshot) {
        String displayAddress = 'Resolving address...';
        IconData locationIcon = Icons.location_searching;

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            displayAddress = 'Could not determine address';
            locationIcon = Icons.wrong_location_outlined;
            print("Error or no data for address: ${snapshot.error}");
          } else {
            displayAddress = snapshot.data!;
            locationIcon = Icons.location_on_outlined;
          }
        }

        return ListTile(
          leading: Icon(
            locationIcon,
            size: 28,
            color: Theme.of(context).colorScheme.secondary,
          ),
          title: const Text('Current Approximate Location'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayAddress,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Lat: ${locationData.latitude!.toStringAsFixed(4)}, Lon: ${locationData.longitude!.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _updateUserLocation(context),
            tooltip: 'Update location',
          ),
        );
      },
    );
  }

  Widget _buildActionsSection(BuildContext context, AuthService authService) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: const Text('Sign Out'),
            onTap: () => _showSignOutConfirmation(context, authService),
          ),
        ],
      ),
    );
  }

  void _showSignOutConfirmation(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Sign Out'),
              onPressed: () async {
                Navigator.of(context).pop();
                await authService.signOut();
              },
            ),
          ],
        );
      },
    );
  }
}
