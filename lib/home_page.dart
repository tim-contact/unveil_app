import 'package:flutter/material.dart';
import 'package:unveilapp/services/auth_service.dart';
import 'package:unveilapp/sign_up_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('error'));
        } else if (snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ModalRoute.of(context)?.settings.name == '/') {
              Navigator.pushReplacementNamed(context, '/app_shell');
            } else {
              Navigator.pushReplacementNamed(context, '/sign_up');
            }
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
              ),
            ),
          );
        } else {
          return SignUpPage();
        }
      },
    );
  }
}
