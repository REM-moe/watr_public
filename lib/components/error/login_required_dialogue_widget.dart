import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watr/components/login/login_dialog_widget.dart';
import 'package:watr/utils/themes/colors.dart';
import 'package:watr/utils/themes/text_themes.dart';

class LoginRequiredDialog extends StatelessWidget {
  const LoginRequiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      backgroundColor: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 64,
              color: AppColors.buttons,
            ),
            const SizedBox(height: 16),
            Text(
              'Login Required',
              style: AppTextThemes.lightTextTheme.bodyLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please log in to access this feature.',
              style: AppTextThemes.lightTextTheme.bodySmall?.copyWith(
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 210,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Close the dialog
                  Get.dialog(const LoginDialog());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttons,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Go to Login',
                  style: AppTextThemes.lightTextTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 210,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(
                      color: AppColors.buttons,
                    ),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: AppTextThemes.lightTextTheme.bodyMedium?.copyWith(
                    color: AppColors.buttons,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showLoginRequiredDialog() {
  Get.dialog(
    const LoginRequiredDialog(),
    barrierDismissible: true, // Prevents closing by tapping outside
  );
}
