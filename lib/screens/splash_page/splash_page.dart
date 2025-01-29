import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watr/components/blur/fliter.dart';
import 'package:watr/controllers/auth_controller.dart';
import 'package:watr/utils/themes/text_themes.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _checkFirstTime(AuthController authController) async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (!authController.isLoggedIn()) {
      // If the user is not logged in, go to Auth screen first
      Get.offAllNamed('/auth');
      return;
    }

    // If the user just logged in, check if it's their first time
    if (isFirstTime) {
      prefs.setBool('isFirstTime', false);
      Get.offAllNamed('/form'); // Navigate to onboarding form
    } else {
      Get.offAllNamed('/'); // Navigate to home
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    Future.delayed(const Duration(seconds: 2), () {
      _checkFirstTime(authController);
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: [
            ...Myfilter(),
            Center(
              child: Text(
                'Watr💦',
                style: AppTextThemes.lightTextTheme.displaySmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
