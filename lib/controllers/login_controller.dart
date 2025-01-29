import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watr/controllers/auth_controller.dart';

class LoginController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final rememberMe = false.obs;
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  // Added error handling
  final emailError = RxnString();
  final passwordError = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    ever(authController.isLoggedIn, (bool isLoggedIn) {
      if (isLoggedIn) {
        // User is logged in, close the login dialog
        resetForm();
        Get.back(closeOverlays: true);
      }
    });
  }

  void resetForm() {
    emailController.clear();
    passwordController.clear();
    emailError.value = null;
    passwordError.value = null;
    rememberMe.value = false;
    isPasswordVisible.value = false;
    isLoading.value = false;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> handleLogin() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    try {
      await authController.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // No need to check authController.isLoggedIn here
      // The ever() listener in onInit will handle the navigation
      // when the auth state updates
    } catch (error) {
      Get.snackbar(
        'Error',
        error.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleForgotPassword() async {
    if (emailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email first',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    try {
      await authController.resetPassword(emailController.text.trim());
    } catch (error) {
      Get.snackbar(
        'Error',
        error.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> handleGoogleSignIn() async {
    // TODO: Implement Google Sign In
    Get.snackbar(
      'Coming Soon',
      'Google Sign In will be available soon!',
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
