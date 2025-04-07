import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watr/controllers/bottle_config_controler.dart';

class BottleWeightConfig extends StatelessWidget {
  const BottleWeightConfig({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BottleController());

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Bottle Configuration',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Empty weight field
          TextField(
            controller: controller.emptyWeightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Empty Bottle Weight (g)',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),

          // Full weight field
          TextField(
            controller: controller.fullWeightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Full Bottle Weight (g)',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 24),

          // Update button
          Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.updateBottleWeights,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Update Bottle Weights',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              )),

          // Error message
          Obx(() => controller.errorMessage.value.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox.shrink()),

          // Success message
          Obx(() => controller.isSuccess.value
              ? const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Bottle weights updated successfully!',
                    style: TextStyle(color: Colors.greenAccent),
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
