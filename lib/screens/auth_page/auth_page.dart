import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:watr/components/blur/fliter.dart';
import 'package:watr/components/login/login_dialog_widget.dart';
import 'package:watr/components/signup/sign_up_widget.dart';
import 'package:watr/controllers/auth_controller.dart';
import 'package:watr/utils/themes/colors.dart';
import 'package:watr/utils/themes/text_themes.dart';

class AuthPage extends GetView<AuthController> {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 1.2 * kToolbarHeight, 40, 20),
        child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                // Circle Decorations
                ...Myfilter(),
                // all auth logic here
                Obx(() => Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (!controller.isLoggedIn.value) ...[
                          // login
                          Align(
                            alignment: AlignmentDirectional.topCenter,
                            child: Text(
                              "Watr",
                              style: AppTextThemes.lightTextTheme.headlineMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          const SizedBox(
                            height: 44,
                          ),
                          Column(
                            children: [
                              Text(
                                'Welcome,',
                                style: AppTextThemes.lightTextTheme.bodyLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                              Text(
                                'start your hydration journey here',
                                style: AppTextThemes.lightTextTheme.bodySmall
                                    ?.copyWith(color: Colors.white),
                              ),
                              const SizedBox(
                                height: 44,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  OutlinedButton(
                                    onPressed: () =>
                                        Get.dialog(const LoginDialog()),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      side: const BorderSide(
                                          color: AppColors.buttons),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                    ),
                                    child: const Text(
                                      'Log In',
                                      style: TextStyle(
                                        color: AppColors.buttons,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 32),

                                  // sign up
                                  ElevatedButton(
                                    onPressed: () {
                                      Get.dialog(const SignUpWidget());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.buttons,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                    ),
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ],
                    )),
              ],
            )),
      ),
    );
  }
}
