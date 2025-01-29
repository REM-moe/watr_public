import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watr/components/blur/fliter.dart';
import 'package:watr/controllers/water_intake_form.dart';
import 'package:watr/utils/themes/text_themes.dart';

class FirstFormPage extends StatelessWidget {
  const FirstFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WaterIntakeController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Select Your Water Plan',
          style: AppTextThemes.lightTextTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Stack(
            children: [
              ...Myfilter(),
              const Align(
                alignment: Alignment(0, -1),
                child: Image(
                  image: AssetImage('assets/bottle.png'),
                  width: 200,
                ),
              ),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepPurpleAccent,
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Daily Water Goal (in Liters)
                      Text(
                        'How many liters of water do you want to drink per day?',
                        style:
                            AppTextThemes.lightTextTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Column(
                            children: [
                              Slider(
                                min: 1.0,
                                max: 5.0,
                                divisions: 8,
                                label:
                                    '${controller.dailyWaterGoal.value.toStringAsFixed(1)} L',
                                value: controller.dailyWaterGoal.value,
                                onChanged: (value) =>
                                    controller.dailyWaterGoal.value = value,
                                activeColor: Colors.deepPurpleAccent,
                                inactiveColor: Colors.white.withOpacity(0.3),
                              ),
                              Text(
                                '${controller.dailyWaterGoal.value.toStringAsFixed(1)} Liters',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )),

                      const SizedBox(height: 32),

                      // Amount per Serving (in Milliliters)
                      Text(
                        'How much water per serving do you drink (in mL)?',
                        style:
                            AppTextThemes.lightTextTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Column(
                            children: [
                              Slider(
                                min: 200,
                                max: 500,
                                divisions: 6,
                                label:
                                    '${controller.amountPerServing.value} mL',
                                value: controller.amountPerServing.value
                                    .toDouble(),
                                onChanged: (value) => controller
                                    .amountPerServing.value = value.toInt(),
                                activeColor: Colors.deepPurpleAccent,
                                inactiveColor: Colors.white.withOpacity(0.3),
                              ),
                              Text(
                                '${controller.amountPerServing.value} mL',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )),

                      const SizedBox(height: 40),

                      // Submit Button
                      SizedBox(
                        width: 160,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: controller.submitWaterPlan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Save Plan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
