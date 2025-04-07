import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watr/controllers/water_plan_controller.dart';
import 'package:watr/utils/themes/text_themes.dart';

class GeminiWidget extends StatelessWidget {
  const GeminiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final WaterPlanController controller = Get.find();

    return Obx(() => Container(
          padding: const EdgeInsets.all(12),
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              controller.displayContent.value,
              textAlign: TextAlign.center,
              style: AppTextThemes.lightTextTheme.bodySmall
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ));
  }
}
