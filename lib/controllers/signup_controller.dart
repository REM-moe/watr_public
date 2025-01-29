import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watr/controllers/auth_controller.dart';

class SignUpController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final first_namenameController = TextEditingController();
  final last_namenameController = TextEditingController();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController(); // Added phone controller

  final formKey = GlobalKey<FormState>();
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;
  final agreeToTerms = false.obs;

  // Error handling
  final nameError = RxnString();
  final emailError = RxnString();
  final passwordError = RxnString();
  final confirmPasswordError = RxnString();
  final phoneError = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    ever(authController.isLoggedIn, (bool isLoggedIn) {
      if (isLoggedIn) {
        // User is logged in, close the signup dialog
        resetForm();
        Get.back(closeOverlays: true);
      }
    });
  }

  void resetForm() {
    first_namenameController.clear();
    last_namenameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    phoneController.clear();
    nameError.value = null;
    emailError.value = null;
    passwordError.value = null;
    confirmPasswordError.value = null;
    phoneError.value = null;
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
    isLoading.value = false;
    agreeToTerms.value = false;
  }

  // ... your existing validation methods ...
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
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

  String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      // Add your phone validation logic here if needed
      if (value.length < 10) {
        return 'Please enter a valid phone number';
      }
    }
    return null;
  }

  Future<void> handleSignUp() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!agreeToTerms.value) {
      Get.snackbar(
        'Error',
        'Please agree to the terms and conditions',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    isLoading.value = true;
    try {
      await authController.signUp(
        f_name: first_namenameController.text.trim(),
        l_name: last_namenameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        phone: phoneController.text.trim(),
        // profile_pic will be added later when implementing profile picture upload
      );

      // No need to check isLoggedIn here as we're now using ever() listener
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

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.length < 2) {
      return 'Full name must be at least 2 characters long';
    }
    return null;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void toggleAgreeToTerms(bool? value) {
    if (value != null) {
      agreeToTerms.value = value;
    }
  }

  @override
  void onClose() {
    first_namenameController.dispose();
    last_namenameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
