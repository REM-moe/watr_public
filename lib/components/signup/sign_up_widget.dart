import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watr/components/login/login_dialog_widget.dart';
import 'package:watr/controllers/signup_controller.dart';
import 'package:watr/utils/themes/colors.dart';
import 'package:watr/utils/themes/text_themes.dart';

class SignUpWidget extends GetView<SignUpController> {
  const SignUpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is initialized
    Get.put(SignUpController());

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
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
                      'Sign Up',
                      style: AppTextThemes.lightTextTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.resetForm();
                        Get.back();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Welcome! Please enter your details.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() => TextFormField(
                      controller: controller.first_namenameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        hintText: 'Enter your first name',
                        errorText: controller.nameError.value,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      onChanged: (value) => controller.nameError.value = null,
                      validator: controller.validateName,
                    )),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.last_namenameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    hintText: 'Enter your last name',
                    errorText: controller.nameError.value,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  onChanged: (value) => controller.nameError.value = null,
                  validator: controller.validateName,
                ),
                const SizedBox(height: 16),
                Obx(() => TextFormField(
                      controller: controller.phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter your phone number',
                        errorText: controller.phoneError.value,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) => controller.phoneError.value = null,
                      validator: controller.validatePhone,
                    )),
                const SizedBox(height: 16),
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
                        hintText: 'Create a password',
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
                Obx(() => TextFormField(
                      controller: controller.confirmPasswordController,
                      obscureText: !controller.isConfirmPasswordVisible.value,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Confirm your password',
                        errorText: controller.confirmPasswordError.value,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmPasswordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: controller.toggleConfirmPasswordVisibility,
                        ),
                      ),
                      onChanged: (value) =>
                          controller.confirmPasswordError.value = null,
                      validator: controller.validateConfirmPassword,
                    )),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Obx(() => Checkbox(
                          value: controller.agreeToTerms.value,
                          onChanged: controller.toggleAgreeToTerms,
                          activeColor: AppColors.buttons,
                        )),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'I agree to the ',
                            style: AppTextThemes.lightTextTheme.labelMedium
                                ?.copyWith(color: Colors.black87),
                          ),
                          MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Get.toNamed('/faqs');
                                },
                                child: Text('Terms and Conditions',
                                    style: AppTextThemes
                                        .lightTextTheme.labelMedium
                                        ?.copyWith(
                                      color: Colors.purple,
                                    )),
                              )),
                        ],
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
                            : controller.handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      )),
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                          Get.dialog(const LoginDialog());
                        },
                        child: const Text(
                          'Log In ',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
