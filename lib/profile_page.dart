import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart' as loc;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unveilapp/models/user_model.dart';
import 'package:unveilapp/services/auth_service.dart';
import 'package:unveilapp/services/firestore.dart';
import 'package:unveilapp/services/get_location.dart';
import 'package:geocoding/geocoding.dart' as geo;

class ProfilePage extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final User? firebaseUser = authService.user;

    // If user is not logged in, show login options
    if (firebaseUser == null) {
      return _buildLoginPrompt(context, authService);
    }

    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );

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

  // New method to show login options when user is not authenticated
  Widget _buildLoginPrompt(BuildContext context, AuthService authService) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),

                // Logo and Welcome Section
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/Logo.png',
                        height: 100,
                        width: 100,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome Back!',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please sign in to view your profile and manage your favorite events',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const Spacer(flex: 2),

                // Login Buttons Section
                Column(
                  children: [
                    _buildLoginButton(
                      context: context,
                      color: Colors.red,
                      text: 'Sign in with Google',
                      icon: FontAwesomeIcons.google,
                      loginMethod: authService.signInWithGoogle,
                    ),
                    const SizedBox(height: 16),
                    _buildLoginButton(
                      context: context,
                      color: Colors.deepPurple,
                      text: 'Continue as Guest',
                      icon: FontAwesomeIcons.userNinja,
                      loginMethod: authService.anonLogin,
                    ),
                  ],
                ),

                const Spacer(flex: 1),

                // Info Text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to access your personalized profile, save favorite events, and get location-based recommendations!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required BuildContext context,
    required Color color,
    required String text,
    required IconData icon,
    required Function loginMethod,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: color.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () async {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => const Center(child: CircularProgressIndicator()),
          );

          try {
            await loginMethod();
            if (context.mounted) {
              Navigator.pop(context); // Remove loading dialog
              // The StreamBuilder will automatically update once user is logged in
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context); // Remove loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sign in failed: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
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
              radius: 40,
              backgroundColor: Colors.pink[300],
              child: Text(
                user.name?.isNotEmpty == true
                    ? user.name![0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                Navigator.of(context).pop(); // Close dialog first

                try {
                  await authService.signOut();

                  // Navigate to sign-up page after successful sign out
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/sign_up', // Make sure this route exists in your main.dart
                      (route) => false, // Remove all previous routes from stack
                    );
                  }
                } catch (e) {
                  // Handle sign out error
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sign out failed: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
