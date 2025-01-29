import 'package:get/get.dart';
import 'package:watr/controllers/auth_controller.dart';
import 'package:watr/services/supabase_service.dart';

class HydrationController extends GetxController {
  final SupabaseService _supabase = Get.find<SupabaseService>();
  final AuthController _authController = Get.find<AuthController>();

  final Rx<String> selectedDay = 'mo'.obs;
  final RxMap<String, List<Map<String, dynamic>>> dayDetails =
      <String, List<Map<String, dynamic>>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Set initial selected day to current weekday
    final today = _weekdayToKey(DateTime.now().weekday);
    selectedDay.value = today;
    fetchAllData();
  }

  String _weekdayToKey(int weekday) {
    const days = ['mo', 'tu', 'we', 'th', 'fr', 'sa', 'su'];
    return days[weekday - 1];
  }

  Future<void> fetchAllData() async {
    try {
      final userId = _authController.user.value?.id;
      if (userId == null) return;

      final response = await _supabase.client
          .from('intakes')
          .select()
          .eq('user_id', userId)
          .order('created_at'); // Fetch all data without filtering by date

      // Initialize empty lists for each day
      final Map<String, List<Map<String, dynamic>>> weekData = {
        'mo': [],
        'tu': [],
        'we': [],
        'th': [],
        'fr': [],
        'sa': [],
        'su': []
      };

      // Process each entry and group by day
      for (var entry in response) {
        final DateTime createdAtUtc =
            DateTime.parse(entry['created_at']).toUtc();
        final localCreatedAt = createdAtUtc.toLocal(); // Convert to local time
        final dayKey = _weekdayToKey(localCreatedAt.weekday);

        weekData[dayKey]!.add({
          'created_at': localCreatedAt.toIso8601String(),
          'amount': entry['amount'],
        });
      }

      // Process the grouped data on the client side
      processDayData(weekData);
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Process the data on the client side: calculate time differences and totals
  void processDayData(Map<String, List<Map<String, dynamic>>> weekData) {
    final processedWeekData = <String, List<Map<String, dynamic>>>{};

    weekData.forEach((day, entries) {
      final List<Map<String, dynamic>> processedEntries = [];
      DateTime? previousTime;

      for (var entry in entries) {
        final DateTime createdAt = DateTime.parse(entry['created_at']);

        // Calculate time difference from previous entry
        String timeDiff = '';
        if (previousTime != null) {
          final diff = createdAt.difference(previousTime);
          final hours = diff.inHours;
          final minutes = diff.inMinutes % 60;
          timeDiff = hours > 0 ? '+$hours h $minutes m' : '+$minutes m';
        }

        processedEntries.add({
          'created_at': createdAt.toIso8601String(),
          'amount': entry['amount'],
          'time_diff': timeDiff,
        });

        // Update previous time for the next comparison
        previousTime = createdAt;
      }

      processedWeekData[day] = processedEntries;
    });

    // Update the observable with processed data
    dayDetails.value = processedWeekData;
    dayDetails.refresh();
  }

  void setSelectedDay(String day) async {
    if (selectedDay.value != day) {
      selectedDay.value = day;
      // Ensure we have data for the selected day
      if (dayDetails[day]?.isEmpty ?? true) {
        await fetchAllData(); // Fetch again if necessary
      }
      dayDetails.refresh();
    }
  }
}
