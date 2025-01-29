// lib/src/routes.dart
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:watr/screens/form/first_form_page.dart';
import 'package:watr/screens/graphs/statistics_page.dart';
import 'package:watr/screens/home_page/home_page.dart';
import 'package:watr/screens/auth_page/auth_page.dart';
import 'package:watr/screens/pair_bottle/pair_bottle_page.dart';
import 'package:watr/screens/splash_page/splash_page.dart';
import 'package:watr/screens/user_page/user_page.dart';

class Routes {
  static const String home = '/';
  static const String auth = '/auth';
  static const String splash = '/splash';
  static const String pair = '/pair';
  static const String form = '/form';
  static const String graph = '/graph';
  static const String user = '/user';
}

final getPages = [
  GetPage(
    name: Routes.home,
    page: () => const HomeScreen(),
  ),
  GetPage(
    name: Routes.auth,
    page: () => const AuthPage(),
  ),
  GetPage(
    name: Routes.splash,
    page: () => const SplashScreen(),
  ),
  GetPage(
    name: Routes.pair,
    page: () => const PairBottlePage(),
  ),
  GetPage(
    name: Routes.form,
    page: () => const FirstFormPage(),
    // Unauthorized page for non-authenticated users
  ),

  GetPage(
    name: Routes.graph,
    page: () => const StatisticsPage(),
    // Unauthorized page for non-authenticated users
  ),
  GetPage(
    name: Routes.user,
    page: () => UserPage(),
    // Unauthorized page for non-authenticated users
  ),

  // GetPage(
  //   name: Routes.userPage,
  //   page: () => const FaqPage(),
  //   // Unauthorized page for non-authenticated users
  // ),
];
