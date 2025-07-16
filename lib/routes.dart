import 'package:unveilapp/home_page.dart';
import 'package:unveilapp/sign_up_page.dart';
import 'package:unveilapp/shared/bottom_nav.dart';
import 'package:unveilapp/for_you_page.dart';

var appRoutes = {
  '/': (context) => const HomePage(),
  '/for_you': (context) => const ForYouPage(),
  '/app_shell': (context) => const BottomNavScreen(),
  '/sign_up': (context) => const SignUpPage(),
};
