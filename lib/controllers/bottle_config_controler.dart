import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BottleController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Text editing controllers for the input fields
  final emptyWeightController = TextEditingController();
  final fullWeightController = TextEditingController();

  // Observable variables to track loading and error states
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isSuccess = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBottleData();
  }

  @override
  void onClose() {
    emptyWeightController.dispose();
    fullWeightController.dispose();
    super.onClose();
  }

  // Get current user ID - properly formatted as UUID
  String? get userId {
    // Make sure we're returning a string, not an Rx object
    return _supabase.auth.currentUser?.id;
  }

  // Fetch bottle data from Supabase
  Future<void> fetchBottleData() async {
    if (userId!.isEmpty) {
      errorMessage.value = 'User not authenticated';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Debug log to verify user ID format
      print('Fetching bottle data for user ID: $userId');

      final response = await _supabase
          .from('current_bottle')
          .select('empty_weight, full_weight')
          .eq('user_id', userId.toString())
          .maybeSingle();

      if (response != null) {
        // Update text controllers with fetched values
        emptyWeightController.text = response['empty_weight']?.toString() ?? '';
        fullWeightController.text = response['full_weight']?.toString() ?? '';
      } else {
        // No data found, set empty values
        emptyWeightController.text = '';
        fullWeightController.text = '';
      }
    } catch (e) {
      print('Error fetching bottle data: $e');
      errorMessage.value = 'Failed to fetch bottle data: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Update bottle weights in Supabase
  Future<void> updateBottleWeights() async {
    if (userId.toString().isEmpty) {
      errorMessage.value = 'User not authenticated';
      return;
    }

    // Validate inputs
    final emptyWeight = int.tryParse(emptyWeightController.text);
    final fullWeight = int.tryParse(fullWeightController.text);

    if (emptyWeight == null || fullWeight == null) {
      errorMessage.value = 'Please enter valid weights in grams';
      return;
    }

    if (emptyWeight >= fullWeight) {
      errorMessage.value = 'Full weight must be greater than empty weight';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      isSuccess.value = false;

      // Debug log to verify user ID format
      print('Updating bottle weights for user ID: $userId');

      // Check if record exists for the user
      final exists = await _supabase
          .from('current_bottle')
          .select('user_id')
          .eq('user_id', userId.toString())
          .maybeSingle();

      if (exists != null) {
        // Update existing record
        await _supabase.from('current_bottle').update({
          'empty_weight': emptyWeight,
          'full_weight': fullWeight,
        }).eq('user_id', userId.toString());
      } else {
        // Insert new record
        await _supabase.from('current_bottle').insert({
          'user_id': userId,
          'empty_weight': emptyWeight,
          'full_weight': fullWeight,
        });
      }

      isSuccess.value = true;
    } catch (e) {
      print('Error updating bottle weights: $e');
      errorMessage.value = 'Failed to update bottle weights: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}
