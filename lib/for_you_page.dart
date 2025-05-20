import 'package:flutter/material.dart';

class ForYouPage extends StatelessWidget {
  const ForYouPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: const Center(
        child: Text('For You Page', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
