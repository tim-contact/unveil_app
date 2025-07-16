import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unveilapp/services/auth_service.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const FlutterLogo(size: 30),
            Flexible(
              child: LoginButton(
                color: Colors.deepPurple,
                text: 'Continue as guest',
                icon: FontAwesomeIcons.userNinja,
                loginMethod: AuthService().anonLogin,
              ),
            ),
            Flexible(
              child: LoginButton(
                color: Colors.red,
                text: 'Continue with Google',
                icon: FontAwesomeIcons.google,
                loginMethod: AuthService().signInWithGoogle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final Color color;
  final String text;
  final IconData icon;
  final Function loginMethod;

  const LoginButton({
    Key? key,
    required this.color,
    required this.text,
    required this.icon,
    required this.loginMethod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () async {
          await loginMethod();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/app_shell');
          }
        },
        icon: Icon(icon, size: 20),
        label: Text(text),
      ),
    );
  }
}
