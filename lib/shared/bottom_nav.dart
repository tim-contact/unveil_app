import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unveilapp/favorites_page.dart';
import 'package:unveilapp/for_you_page.dart';
import 'package:unveilapp/profile_page.dart';

class BottomNavProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

class BottomNavScreen extends StatelessWidget {
  const BottomNavScreen({super.key});

  static const List<Widget> _pages = <Widget>[
    ForYouPage(),
    FavoritesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BottomNavProvider(),
      child: Consumer<BottomNavProvider>(
        builder: (context, navProvider, child) {
          final currentIndex = navProvider.currentIndex;

          return Scaffold(
            body: IndexedStack(index: currentIndex, children: _pages),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore),
                  label: 'For You',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.user),
                  activeIcon: Icon(FontAwesomeIcons.solidUser),
                  label: 'Profile',
                ),
              ],
              currentIndex: currentIndex,
              onTap: (index) {
                context.read<BottomNavProvider>().setCurrentIndex(index);
              },
            ),
          );
        },
      ),
    );
  }
}
