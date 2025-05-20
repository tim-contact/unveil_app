import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: const Center(
        child: Text('Favorites Page', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
