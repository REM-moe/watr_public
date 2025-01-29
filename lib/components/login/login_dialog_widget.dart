import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watr/components/signup/sign_up_widget.dart';

import 'package:watr/controllers/login_controller.dart';
import 'package:watr/utils/themes/colors.dart';
import 'package:watr/utils/themes/text_themes.dart'; // Import your color constants

class LoginDialog extends GetView<LoginController> {
  const LoginDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Make sure controller is initialized
    Get.put(LoginController());

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        // Added for better mobile handling
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Log in',
                      style: AppTextThemes.lightTextTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.resetForm(); // Clear form on close
                        Get.back();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Welcome back! Please enter your details.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() => TextFormField(
                      controller: controller.emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        errorText: controller.emailError.value,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      onChanged: (value) => controller.emailError.value = null,
                      validator: controller.validateEmail,
                    )),
                const SizedBox(height: 16),
                Obx(() => TextFormField(
                      controller: controller.passwordController,
                      obscureText: !controller.isPasswordVisible.value,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        errorText: controller.passwordError.value,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                      onChanged: (value) =>
                          controller.passwordError.value = null,
                      validator: controller.validatePassword,
                    )),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Row(
                    //   children: [
                    //     // Obx(() => Checkbox(
                    //     //       value: controller.rememberMe.value,
                    //     //       onChanged: controller.toggleRememberMe,
                    //     //       activeColor: AppColors.buttons,
                    //     //     )),
                    //     // Text(
                    //     //   'Remember for 30 days',
                    //     //   style: AppTextThemes.lightTextTheme.bodySmall,
                    //     // ),
                    //   ],
                    // ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Forgot password ?',
                          style: TextStyle(color: AppColors.buttons),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Log in',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      )),
                ),
                const SizedBox(height: 16),
                // SizedBox(
                //   width: double.infinity,
                //   height: 48,
                //   child: OutlinedButton.icon(
                //     onPressed: () => controller.handleGoogleSignIn(),
                //     icon: Image.asset(
                //       'assets/logo/logo.png', // Use local asset instead of network image
                //       height: 24,
                //     ),
                //     label: const Text('Sign in with Google'),
                //     style: OutlinedButton.styleFrom(
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //       side: const BorderSide(color: Colors.grey),
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                          Get.dialog(const SignUpWidget());
                        },
                        child: const Text(
                          'Sign Up ',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
