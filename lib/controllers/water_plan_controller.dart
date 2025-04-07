import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WaterPlanController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Gemini _gemini = Gemini.instance;

  RxString dailyGoal = ''.obs;
  RxString perSip = ''.obs;
  RxList<Map<String, dynamic>> weeklyDrinkHistory =
      <Map<String, dynamic>>[].obs;
  RxString reminderPlan = ''.obs;
  RxString personality = ''.obs;
  RxString displayContent = 'Fetching insights...'.obs;

  final List<Future<void> Function()> _geminiFunctions = [];
  Timer? _insightTimer;

  @override
  void onInit() {
    super.onInit();

    _geminiFunctions.addAll([
      generateReminderPlan,
      assignDrinkingPersonality,
    ]);

    fetchUserData();

    _insightTimer = Timer.periodic(const Duration(seconds: 50), (timer) {
      updateRandomContent();
    });
  }

  @override
  void onClose() {
    _insightTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchUserData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return;
    }

    try {
      final planResponse = await _supabase
          .rpc('get_or_create_water_plan', params: {'user_id_param': userId});

      if (planResponse != null) {
        dailyGoal.value = planResponse['daily_water_goal'].toString();
        perSip.value = planResponse['amount_per_serving'].toString();
      }

      await fetchWeeklyDrinkHistory();
    } catch (e) {
      // Set default values if there's an error
      dailyGoal.value = '2000';
      perSip.value = '250';
    }
  }

  Future<void> fetchWeeklyDrinkHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return;
    }

    try {
      final oneWeekAgo =
          DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

      final historyResponse = await _supabase
          .from('intakes')
          .select('created_at, amount::text') // Ensure amount is cast to text
          .eq('user_id', userId)
          .gte('created_at', oneWeekAgo)
          .order('created_at', ascending: false);

      weeklyDrinkHistory.value =
          List<Map<String, dynamic>>.from(historyResponse);

      if (weeklyDrinkHistory.isEmpty) {
        // No need to fetch fallback plan since we already have defaults
        updateRandomContent();
      } else {
        updateRandomContent();
      }
    } catch (e) {
      log("Error fetching weekly drink history: $e");
      weeklyDrinkHistory.value = [];
      updateRandomContent();
    }
  }

  Future<void> fetchFallbackPlan() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final planResponse = await _supabase
          .from('water_plan')
          .select()
          .eq('user_id', userId)
          .single();

      if (planResponse.isNotEmpty) {
        dailyGoal.value = planResponse['daily_water_goal'] ?? '2000';
        perSip.value = planResponse['amount_per_serving'] ?? '250';
      } else {
        log("No fallback plan found.");
      }
    } catch (e) {
      log("Error fetching fallback water plan: $e");
    }
  }

  Future<void> generateReminderPlan() async {
    log("Generating reminder plan...");

    String prompt;
    if (weeklyDrinkHistory.isEmpty) {
      prompt = """
    This user hasn't logged recent water intakes, but their goal is **${dailyGoal.value} ml per day** 
    and they drink **${perSip.value} ml per sip**. 
    Suggest a fun hydration reminder in **40 words**.
    """;
    } else {
      prompt = """
    This user's **drinking pattern for the last 7 days**:
    ${weeklyDrinkHistory.map((e) => "Date: ${e['created_at']}, Amount: ${e['amount']} ml").join('\n')}

    - Daily goal: ${dailyGoal.value} ml
    - Per sip: ${perSip.value} ml
    Say something fun in **40 words** based on this pattern.
    """;
    }

    try {
      final response = await _gemini.prompt(parts: [Part.text(prompt)]);
      reminderPlan.value = response?.output ?? "Stay hydrated regularly!";
      displayContent.value = reminderPlan.value;
    } catch (e) {
      log("Gemini Error (Reminder Plan): $e");
    }
  }

  Future<void> assignDrinkingPersonality() async {
    String prompt;
    if (weeklyDrinkHistory.isEmpty) {
      prompt = """
    This user hasn't logged much water intake, but they aim to drink **${dailyGoal.value} ml daily** 
    with **${perSip.value} ml per sip**. Assign a fun hydration personality in **30 words**.
    - Compare them to an **animal, famous person, or athlete**.
    """;
    } else {
      prompt = """
    Based on the user's **past 7 days of water intake**, analyze their drinking pattern:
    ${weeklyDrinkHistory.map((e) => "Date: ${e['created_at']}, Amount: ${e['amount']} ml").join('\n')}

    - Daily goal: ${dailyGoal.value} ml
    - Per sip: ${perSip.value} ml

    Assign a **fun hydration personality** in **30 words**:
    - Compare them to an **animal, famous person, athlete, or character**.
    """;
    }

    try {
      final response = await _gemini.prompt(parts: [Part.text(prompt)]);
      personality.value =
          response?.output ?? "You're as hydrated as a dolphin!";
      displayContent.value = personality.value;
    } catch (e) {
      log("Gemini Error (Personality): $e");
    }
  }

  void updateRandomContent() {
    if (_geminiFunctions.isNotEmpty) {
      final randomFunction =
          _geminiFunctions[Random().nextInt(_geminiFunctions.length)];
      randomFunction();
    } else {
      log("No Gemini functions available.");
    }
  }

  void log(String message) {
    print("[WaterPlanController]: $message");
  }
}
