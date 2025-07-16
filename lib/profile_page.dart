import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unveilapp/models/user_model.dart';
import 'package:unveilapp/services/auth_service.dart';
import 'package:unveilapp/services/firestore.dart'; // Your Firestore service
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase User class
import 'package:unveilapp/services/get_location.dart'; // Your LocationService
import 'package:location/location.dart'
    as loc; // For LocationData type, aliased

// Placeholder for EditProfilePage
// class EditProfilePage extends StatelessWidget {
//   final UserModel user;
//   const EditProfilePage({super.key, required this.user});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(appBar: AppBar(title: const Text("Edit Profile")), body: Center(child: Text("Edit ${user.name}'s Profile")));
//   }
// }

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Helper to build the location information with reverse geocoding
  Widget _buildLocationInfo(
    BuildContext context,
    loc.LocationData? locationData,
  ) {
    if (locationData == null ||
        locationData.latitude == null ||
        locationData.longitude == null) {
      return const ListTile(
        leading: Icon(Icons.location_off_outlined, size: 28),
        title: Text('Location'),
        subtitle: Text('Not available or not shared'),
      );
    }

    // Access LocationService via Provider
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
            displayAddress = snapshot.data ?? 'Could not determine address';
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
          subtitle: Text(
            displayAddress,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Future<void> _showSignOutConfirmation(
    BuildContext context,
    AuthService authService,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Confirm Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: Text(
                'Sign Out',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await authService.signOut();
        // Clear the entire navigation stack and go back to '/'
        if (context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/sign_up', (route) => false);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access providers
    final authService = Provider.of<AuthService>(context, listen: false);
    // Using context.watch for Firestore to rebuild ProfilePage if user data stream emits new value
    // This assumes your Firestore service's getUserStream/getCurrentUserStream correctly emits.
    // If you're passing the UID from authService.currentUser, ensure currentUser itself doesn't cause rebuild loops
    // if it's also from a stream that changes frequently without actual UID change.
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    ); // Get instance
    final User firebaseUser = authService.user!; // Get current user

    return Scaffold(
      // AppBar is handled by BottomNavScreen
      body: StreamBuilder<UserModel?>(
        // Use the stream from your Firestore service for the current user
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
            onRefresh: () async {
              // Optionally, you could re-fetch or simply rely on the stream to update
              // For a manual refresh, you might need to trigger something in your Firestore service
              // or just wait a bit for the stream to naturally refresh if data changes.
              // This example is simple; a real refresh might involve more.
              await Future.delayed(
                const Duration(seconds: 1),
              ); // Simulate network call
            },
            child: ListView(
              padding: const EdgeInsets.all(
                0,
              ), // No padding for ListView if using custom sections
              children: <Widget>[
                _buildProfileHeader(context, user),
                const SizedBox(height: 20),
                _buildInfoSection(context, user),
                const SizedBox(height: 10),
                _buildActionsSection(context, authService, user),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(
          0.5,
        ), // Slightly different background
        // borderRadius: const BorderRadius.only(
        //   bottomLeft: Radius.circular(30),
        //   bottomRight: Radius.circular(30),
        // ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            // backgroundImage: user.photoURL != null && user.photoURL!.isNotEmpty
            //     ? NetworkImage(user.photoURL!) // Assuming UserModel has photoURL
            //     : null,
            child: /* user.photoURL == null || user.photoURL!.isEmpty ? */ Text(
              user.name != null && user.name!.isNotEmpty
                  ? user.name![0].toUpperCase()
                  : "U",
              style: TextStyle(
                fontSize: 40,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ) /* : null, */,
          ),
          const SizedBox(height: 16),
          Text(
            user.name ?? 'Anonymous User',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            user.email ?? 'No email provided',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
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
                    // A simple date format, consider using the `intl` package for better formatting
                    ? "${user.signedInAt!.toDate().day}/${user.signedInAt!.toDate().month}/${user.signedInAt!.toDate().year}"
                    : 'Date not available',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildLocationInfo(context, user.location), // Using the helper
            // Add more user info ListTiles here if needed (e.g., Bio, Favorite Event Count)
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    AuthService authService,
    UserModel currentUser,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.edit_note_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Edit Profile'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to an EditProfilePage
                // You would pass the current 'user' object to pre-fill fields
                // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(user: currentUser)));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit Profile page not yet implemented.'),
                  ),
                );
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Sign Out',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () => _showSignOutConfirmation(context, authService),
            ),
          ],
        ),
      ),
    );
  }
}
