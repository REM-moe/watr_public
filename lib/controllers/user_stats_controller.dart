// ignore_for_file: unnecessary_null_comparison

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class UserStatsController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Gemini _gemini = Gemini.instance;

  RxString username = 'User'.obs;
  RxInt streakDays = 0.obs;
  RxString hydrationPersonality = 'Analyzing...'.obs;
  RxString funFact = 'Analyzing...'.obs;
  RxString waterAdvice = 'Analyzing...'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return;
    }

    try {
      // Fetch username
      final profile =
          await _supabase.from('users').select().eq('id', userId).single();
      username.value = profile['f_name'] ?? 'User';

      await fetchStreak(userId);
      await generateFunInsights(userId);
      await assignHydrationPersonality(userId);
      await generateWaterAdvice(userId);
    } catch (e) {}
  }

  Future<void> generateFunInsights(String userId) async {
    try {
      final intakes = await _supabase
          .from('intakes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(30);

      final waterPlan = await _supabase
          .from('water_plan')
          .select()
          .eq('user_id', userId)
          .single()
          .then(
              (value) => value != null ? Map<String, dynamic>.from(value) : {});
      double dailyGoal =
          (waterPlan['daily_water_goal'] as num?)?.toDouble() ?? 0.0;

      final prompt = """
      Based on this user's water drinking data:
      Daily Goal: ${waterPlan['daily_water_goal']}L
      Recent intakes: ${intakes.map((e) => "${e['amount']}ml on ${e['created_at']}").join(', ')}
      Format: Return exactly two lines, fun fact water. 40 words
      """;

      final geminiResponse = await _gemini.prompt(parts: [Part.text(prompt)]);

      if (geminiResponse?.output != null) {
        final insights = geminiResponse!.output?.split('\n');
        if (insights!.length >= 2) {
          funFact.value = insights[0];
        }
      }
    } catch (e) {}
  }

  Future<void> generateWaterAdvice(String userId) async {
    try {
      final intakes = await _supabase
          .from('intakes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(30);

      final waterPlan = await _supabase
          .from('water_plan')
          .select()
          .eq('user_id', userId)
          .single()
          .then(
              (value) => value != null ? Map<String, dynamic>.from(value) : {});
      double dailyGoal =
          (waterPlan['daily_water_goal'] as num?)?.toDouble() ?? 0.0;

      final prompt = """
      Based on this user's water drinking data:
      Daily Goal: ${waterPlan['daily_water_goal']}L
      Recent intakes: ${intakes.map((e) => "${e['amount']}ml on ${e['created_at']}").join(', ')}
      Format: Return exactly two lines, one for each insight. 20 words
      """;

      final geminiResponse = await _gemini.prompt(parts: [Part.text(prompt)]);

      if (geminiResponse?.output != null) {
        final insights = geminiResponse!.output?.split('\n');
        if (insights!.length >= 2) {
          waterAdvice.value = insights[0];
        }
      }
    } catch (e) {}
  }

  Future<void> fetchStreak(String userId) async {
    try {
      final response = await _supabase
          .from('intakes')
          .select('created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      int streak = 0;
      DateTime? lastDate;
      for (var record in response) {
        DateTime date = DateTime.parse(record['created_at']).toLocal();
        if (lastDate == null || lastDate.difference(date).inDays == 1) {
          streak++;
          lastDate = date;
        } else {
          break;
        }
      }
      streakDays.value = streak;
    } catch (e) {}
  }

  Future<void> assignHydrationPersonality(String userId) async {
    try {
      final response = await _supabase
          .from('intakes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(7);

      final prompt = """
      Based on the user's water intake over the last 7 days:
      ${response.map((e) => "Date: ${e['created_at']}, Amount: ${e['amount']} ml").join('\n')}

      Assign a fun hydration personality:
      - Compare them to an animal, famous person, or character.
      just return the name only one word like You're as hydrated as a dolphin!
      """;

      final geminiResponse = await _gemini.prompt(parts: [Part.text(prompt)]);
      hydrationPersonality.value =
          geminiResponse?.output ?? "You're as hydrated as a dolphin!";
    } catch (e) {}
  }
}
