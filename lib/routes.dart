import 'package:unveilapp/home_page.dart';
import 'package:unveilapp/sign_up_page.dart';
import 'package:unveilapp/shared/bottom_nav.dart';

var appRoutes = {
  '/': (context) => const HomePage(),
  '/app_shell': (context) => const BottomNavScreen(),
  '/sign_up': (context) => const SignUpPage(),
};
