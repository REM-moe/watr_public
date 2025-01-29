import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watr/services/supabase_service.dart';

class WaterIntakeController extends GetxController {
  final SupabaseService supabaseService = Get.find<SupabaseService>();

  var dailyWaterGoal = 2.0.obs;
  var amountPerServing = 250.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadExistingPlan();
  }

  Future<void> loadExistingPlan() async {
    try {
      final userId = supabaseService.client.auth.currentUser?.id;
      if (userId == null) return;

      final existingPlan = await supabaseService.client
          .from('water_plan')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (existingPlan != null) {
        dailyWaterGoal.value = existingPlan['daily_water_goal'] ?? 2.0;
        amountPerServing.value = existingPlan['amount_per_serving'] ?? 250;
      }
    } catch (e) {
      showErrorSnackbar('Failed to load existing plan');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitWaterPlan() async {
    final userId = supabaseService.client.auth.currentUser?.id;
    if (userId == null) {
      showErrorSnackbar('User not authenticated');
      return;
    }

    try {
      final existingPlan = await supabaseService.client
          .from('water_plan')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      final Map<String, dynamic> waterPlanData = {
        'daily_water_goal': dailyWaterGoal.value,
        'amount_per_serving': amountPerServing.value,
      };

      if (existingPlan != null) {
        await supabaseService.client
            .from('water_plan')
            .update(waterPlanData)
            .eq('user_id', userId);
        showSuccessSnackbar('Water plan updated successfully');
      } else {
        waterPlanData['user_id'] = userId;
        await supabaseService.client.from('water_plan').insert(waterPlanData);
        showSuccessSnackbar('Water plan created successfully');
      }

      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed('/');
    } catch (e) {
      showErrorSnackbar('An unexpected error occurred');
    }
  }

  void showSuccessSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade400,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  void showErrorSnackbar(String message) {
    Get.closeAllSnackbars();
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade400,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }
}
