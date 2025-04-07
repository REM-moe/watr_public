// ignore_for_file: unnecessary_cast, unnecessary_null_comparison

import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WaterTrackingService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Observable variables
  final RxDouble currentWeight = 0.0.obs;
  final RxDouble previousWeight = 0.0.obs;
  final RxDouble emptyBottleWeight = 264.0.obs; // Empty bottle weight in grams
  final RxDouble fullBottleWeight = 650.0.obs; // Full bottle capacity in grams
  final RxString amountConsumed =
      "0".obs; // Total water consumed in current session
  final RxString leftInBottle = "0".obs; // Amount left in bottle
  final RxInt bottleNum =
      1.obs; // Bottle number (in case user has multiple bottles)
  final RxBool isBottleEmpty = false.obs;
  final RxBool isBottleRefilled = false.obs;

  // User's water plan
  final RxInt dailyWaterGoal = 2000.obs; // Default 2000ml
  final RxInt amountPerServing = 250.obs; // Default 250ml per serving
  final RxString planName = "Default".obs;

  // Timer for periodic checks
  Timer? _weightCheckTimer;

  // Cache for weight measurements
  final RxList<Map<String, dynamic>> _weightCache =
      <Map<String, dynamic>>[].obs;

  // Density of water: 1g = 1ml
  final double waterDensity = 1.0;

  Future<WaterTrackingService> init() async {
    print('🚰 WaterTrackingService: Initializing service');
    // Initialize the service
    await _loadUserWaterPlan();
    await _fetchLatestWeight();
    await _calculateLeftInBottle();

    // Start with a full day refresh to ensure accurate data
    await refreshFullDayData();

    // Start periodic weight check timer (every 30 seconds)
    _startPeriodicWeightCheck();

    print(
        '🚰 WaterTrackingService: Service initialized with bottle weight: ${currentWeight.value}g, empty: ${emptyBottleWeight.value}g, full: ${fullBottleWeight.value}g');
    return this;
  }

  void _startPeriodicWeightCheck() {
    // Cancel existing timer if any
    _weightCheckTimer?.cancel();

    print(
        '🚰 WaterTrackingService: Starting periodic weight checks (every 50 seconds)');
    // Set up new 30-second timer
    _weightCheckTimer = Timer.periodic(Duration(seconds: 50), (timer) {
      print(
          '🚰 WaterTrackingService: Executing periodic weight check #${timer.tick}');
      _fetchAndProcessWeightData();
    });
  }

  Future<void> _fetchAndProcessWeightData() async {
    try {
      // Get the timestamp of the last processed weight
      // Instead of just 5 minutes, let's fetch at least the last 24 hours of data
      // This ensures we don't miss any measurements due to time zone or sync issues
      DateTime lastProcessedTime = DateTime.now().subtract(Duration(hours: 24));

      if (_weightCache.isNotEmpty) {
        // Only use the cache time if it's more recent than our 24-hour lookback
        DateTime cacheTime = DateTime.parse(_weightCache.last['created_at']);
        if (cacheTime.isAfter(lastProcessedTime)) {
          // Add a small buffer (5 minutes) to avoid potential duplicates due to time precision issues
          lastProcessedTime = cacheTime.subtract(Duration(minutes: 5));
        }
      }

      print(
          '🚰 WaterTrackingService: Fetching weight data since ${lastProcessedTime.toIso8601String()}');

      // Fetch new weight measurements since the last processed one
      final response = await _supabase
          .from('weight_measurements')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .gt('created_at', lastProcessedTime.toIso8601String())
          .order('created_at', ascending: true);

      final weightMeasurements = response as List<Map<String, dynamic>>;

      print(
          '🚰 WaterTrackingService: Found ${weightMeasurements.length} new weight measurements');

      // Process each weight measurement in sequence
      for (final measurement in weightMeasurements) {
        // Check if this measurement is already in the cache to avoid duplicates
        bool isDuplicate = _weightCache.any((cached) =>
            cached['id'] == measurement['id'] ||
            cached['created_at'] == measurement['created_at']);

        if (!isDuplicate) {
          print(
              '🚰 WaterTrackingService: Processing weight update: ${measurement['weight']}g at ${measurement['created_at']}');
          _processWeightUpdate(measurement);
          _weightCache.add(measurement);
        } else {
          print(
              '🚰 WaterTrackingService: Skipping duplicate measurement: ${measurement['created_at']}');
        }
      }

      // Keep cache size manageable but large enough to maintain sufficient history
      // Increase from 50 to 200 to maintain longer history
      if (_weightCache.length > 200) {
        // Remove older entries
        _weightCache.removeRange(0, _weightCache.length - 200);
      }
    } catch (e) {
      print('❌ WaterTrackingService: Error fetching weight data: $e');
    }
  }

  Future<void> refreshFullDayData([int daysBack = 1]) async {
    try {
      print(
          '🚰 WaterTrackingService: Performing full day refresh for the past $daysBack day(s)');

      // Calculate the start of the period we want to refresh
      final now = DateTime.now().toUtc();
      final startDate =
          DateTime.utc(now.year, now.month, now.day - daysBack, 0, 0, 0);

      // Clear existing cache for the period we're refreshing
      _weightCache.removeWhere((item) {
        DateTime itemDate = DateTime.parse(item['created_at']);
        return itemDate.isAfter(startDate);
      });

      // Fetch all measurements since the start date
      final response = await _supabase
          .from('weight_measurements')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .gte('created_at', startDate.toIso8601String())
          .order('created_at', ascending: true);

      final weightMeasurements = response as List<Map<String, dynamic>>;

      print(
          '🚰 WaterTrackingService: Found ${weightMeasurements.length} measurements in the last $daysBack day(s)');

      // Process each measurement
      for (final measurement in weightMeasurements) {
        print(
            '🚰 WaterTrackingService: Processing weight: ${measurement['weight']}g at ${measurement['created_at']}');
        _processWeightUpdate(measurement);
        _weightCache.add(measurement);
      }

      // Recalculate current status
      await _calculateLeftInBottle();

      print('🚰 WaterTrackingService: Full day refresh complete');
    } catch (e) {
      print('❌ WaterTrackingService: Error performing full day refresh: $e');
    }
  }

  Future<void> _fetchLatestWeight() async {
    try {
      print('🚰 WaterTrackingService: Fetching latest weight measurement');
      // Fetch the most recent weight measurement
      final response = await _supabase
          .from('weight_measurements')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('created_at', ascending: false)
          .limit(1);

      if (response != null && (response as List).isNotEmpty) {
        final measurement = response[0];
        currentWeight.value = measurement['weight']?.toDouble() ?? 0.0;
        print(
            '🚰 WaterTrackingService: Latest weight: ${currentWeight.value}g');
      } else {
        print('🚰 WaterTrackingService: No weight measurements found');
      }
    } catch (e) {
      print('❌ WaterTrackingService: Error fetching latest weight: $e');
    }
  }

  void _processWeightUpdate(Map<String, dynamic> measurement) {
    // Extract the weight value from the payload
    final double newWeight = measurement['weight']?.toDouble() ?? 0.0;

    print(
        '🚰 WaterTrackingService: Processing weight change: ${currentWeight.value}g → ${newWeight}g');

    // Store previous weight before updating
    previousWeight.value = currentWeight.value;
    currentWeight.value = newWeight;

    // Calculate weight difference
    final double weightDifference = previousWeight.value - currentWeight.value;

    // Check if user drank water (weight decreased)
    if (weightDifference > 0 &&
        previousWeight.value > emptyBottleWeight.value) {
      // Calculate water consumed in ml (1g = 1ml)
      final int waterConsumedMl = (weightDifference * waterDensity).round();

      // Handle edge case: Only record if significant weight change (>10ml)
      if (waterConsumedMl > 10) {
        print(
            '🚰 WaterTrackingService: Detected water consumption of ${waterConsumedMl}ml (weight change: ${weightDifference.toStringAsFixed(1)}g)');
        // Record water consumption
        _recordWaterConsumption(waterConsumedMl);
      } else {
        print(
            '🚰 WaterTrackingService: Weight decreased but too small to record (${waterConsumedMl}ml)');
      }
    } else if (weightDifference < 0) {
      print(
          '🚰 WaterTrackingService: Weight increased by ${(-weightDifference).toStringAsFixed(1)}g');
    } else {
      print('🚰 WaterTrackingService: No significant weight change detected');
    }

    // Check if bottle was refilled (significant weight increase)
    if (currentWeight.value > previousWeight.value + 50) {
      print(
          '🚰 WaterTrackingService: Bottle refill detected! Weight increased from ${previousWeight.value}g to ${currentWeight.value}g');
      isBottleRefilled.value = true;
      // Increment bottle number when refilled
      bottleNum.value++;
      print('🚰 WaterTrackingService: New bottle count: ${bottleNum.value}');
      // Reset after 5 seconds
      Future.delayed(
          Duration(seconds: 5), () => isBottleRefilled.value = false);
    }

    // Calculate amount left in bottle
    _calculateLeftInBottle();

    // Check if bottle is empty
    final bool wasEmpty = isBottleEmpty.value;
    isBottleEmpty.value = currentWeight.value <=
        emptyBottleWeight.value + 20; // Threshold for empty

    if (isBottleEmpty.value && !wasEmpty) {
      print(
          '🚰 WaterTrackingService: Bottle is now empty (weight: ${currentWeight.value}g)');
    } else if (!isBottleEmpty.value && wasEmpty) {
      print(
          '🚰 WaterTrackingService: Bottle is no longer empty (weight: ${currentWeight.value}g)');
    }
  }

  Future<void> _calculateLeftInBottle() async {
    // Calculate amount left in bottle in ml
    double waterLeftMl =
        (currentWeight.value - emptyBottleWeight.value) * waterDensity;

    // Handle edge case: negative values
    if (waterLeftMl < 0) {
      print(
          '🚰 WaterTrackingService: Negative water amount calculated (${waterLeftMl.toStringAsFixed(1)}ml), setting to 0');
      waterLeftMl = 0;
    }

    leftInBottle.value = waterLeftMl.round().toString();
    print('🚰 WaterTrackingService: Left in bottle: ${leftInBottle.value}ml');

    // Calculate percentage full for logging
    double percentFull = (waterLeftMl /
        (fullBottleWeight.value - emptyBottleWeight.value) *
        100);
    if (percentFull > 100) percentFull = 100;
    print(
        '🚰 WaterTrackingService: Bottle is approximately ${percentFull.toStringAsFixed(1)}% full');
  }

  Future<void> _recordWaterConsumption(int amountMl) async {
    try {
      print(
          '🚰 WaterTrackingService: Recording water consumption of ${amountMl}ml');
      // Store the water consumption record in Supabase
      await _supabase.from('intakes').insert({
        'amount': amountMl.toString(),
        'left_in_bottle': leftInBottle.value,
        'bottle_num': bottleNum.value,
        'user_id': _supabase.auth.currentUser?.id,
      });

      // Update amount consumed
      amountConsumed.value = amountMl.toString();
      print('🚰 WaterTrackingService: Successfully recorded intake');

      // Get and log total consumption
      final total = await getTotalWaterConsumedToday();
      final progressPercentage =
          (total / dailyWaterGoal.value * 100).toStringAsFixed(1);
      print(
          '🚰 WaterTrackingService: Total consumed today: ${total}ml (${progressPercentage}% of daily goal)');
    } catch (e) {
      print('❌ WaterTrackingService: Error recording water consumption: $e');
    }
  }

  Future<void> _loadUserWaterPlan() async {
    try {
      print('🚰 WaterTrackingService: Loading user water plan');
      // Fetch user's water plan
      final response = await _supabase
          .from('water_plan')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .single();

      if (response != null) {
        dailyWaterGoal.value = response['daily_water_goal'] ?? 2000;
        amountPerServing.value = response['amount_per_serving'] ?? 250;
        planName.value = response['plan_name'] ?? 'Default';
        print(
            '🚰 WaterTrackingService: Loaded water plan "${planName.value}" with goal: ${dailyWaterGoal.value}ml, serving: ${amountPerServing.value}ml');
      }
    } catch (e) {
      print('❌ WaterTrackingService: Error loading water plan: $e');
      print('🚰 WaterTrackingService: Creating default water plan');
      // Create default water plan if none exists
      await _createDefaultWaterPlan();
    }
  }

  Future<void> _createDefaultWaterPlan() async {
    try {
      print(
          '🚰 WaterTrackingService: Creating default water plan (${dailyWaterGoal.value}ml daily goal)');
      await _supabase.from('water_plan').insert({
        'daily_water_goal': dailyWaterGoal.value,
        'amount_per_serving': amountPerServing.value,
        'plan_name': planName.value,
        'user_id': _supabase.auth.currentUser?.id,
      });
      print('🚰 WaterTrackingService: Default plan created successfully');
    } catch (e) {
      print('❌ WaterTrackingService: Error creating default water plan: $e');
    }
  }

  Future<void> updateWaterPlan({
    int? newDailyGoal,
    int? newAmountPerServing,
    String? newPlanName,
  }) async {
    try {
      print('🚰 WaterTrackingService: Updating water plan');

      if (newDailyGoal != null) {
        print(
            '🚰 WaterTrackingService: Changing daily goal: ${dailyWaterGoal.value}ml → ${newDailyGoal}ml');
        dailyWaterGoal.value = newDailyGoal;
      }

      if (newAmountPerServing != null) {
        print(
            '🚰 WaterTrackingService: Changing serving size: ${amountPerServing.value}ml → ${newAmountPerServing}ml');
        amountPerServing.value = newAmountPerServing;
      }

      if (newPlanName != null) {
        print(
            '🚰 WaterTrackingService: Changing plan name: "${planName.value}" → "${newPlanName}"');
        planName.value = newPlanName;
      }

      await _supabase.from('water_plan').upsert({
        'daily_water_goal': dailyWaterGoal.value,
        'amount_per_serving': amountPerServing.value,
        'plan_name': planName.value,
        'user_id': _supabase.auth.currentUser?.id,
      });

      print('🚰 WaterTrackingService: Water plan updated successfully');
    } catch (e) {
      print('❌ WaterTrackingService: Error updating water plan: $e');
    }
  }

  void updateEmptyBottleWeight(double weight) {
    print(
        '🚰 WaterTrackingService: Updating empty bottle weight: ${emptyBottleWeight.value}g → ${weight}g');
    emptyBottleWeight.value = weight;
    _calculateLeftInBottle();
    // You might want to store this in shared preferences or database
  }

  void updateFullBottleWeight(double weight) {
    print(
        '🚰 WaterTrackingService: Updating full bottle weight: ${fullBottleWeight.value}g → ${weight}g');
    fullBottleWeight.value = weight;
    // You might want to store this in shared preferences or database
  }

  Future<List<Map<String, dynamic>>> getTodayIntakes() async {
    try {
      print('🚰 WaterTrackingService: Fetching today\'s intakes');
      // Get today's date in UTC format
      final now = DateTime.now().toUtc();
      final startOfDay = DateTime.utc(now.year, now.month, now.day);

      // Fetch today's intakes
      final response = await _supabase
          .from('intakes')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .gte('created_at', startOfDay.toIso8601String())
          .order('created_at', ascending: true);

      final intakes = response as List<Map<String, dynamic>>;
      print('🚰 WaterTrackingService: Found ${intakes.length} intakes today');
      return intakes;
    } catch (e) {
      print('❌ WaterTrackingService: Error fetching today intakes: $e');
      return [];
    }
  }

  Future<int> getTotalWaterConsumedToday() async {
    try {
      final intakes = await getTodayIntakes();
      int total = 0;

      for (final intake in intakes) {
        final int amount = int.tryParse(intake['amount'].toString()) ?? 0;
        total += amount;
      }

      print('🚰 WaterTrackingService: Total water consumed today: ${total}ml');
      return total;
    } catch (e) {
      print(
          '❌ WaterTrackingService: Error calculating total water consumed: $e');
      return 0;
    }
  }

  // Get historical consumption data for a specific time range
  Future<Map<String, dynamic>> getHistoricalData(
      DateTime startDate, DateTime endDate) async {
    try {
      print(
          '🚰 WaterTrackingService: Fetching historical data from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');

      final response = await _supabase
          .from('intakes')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: true);

      final intakes = response as List<Map<String, dynamic>>;

      // Group by day
      Map<String, int> dailyTotals = {};
      int overallTotal = 0;

      for (final intake in intakes) {
        final DateTime date = DateTime.parse(intake['created_at']);
        final String day =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final int amount = int.tryParse(intake['amount'].toString()) ?? 0;

        dailyTotals[day] = (dailyTotals[day] ?? 0) + amount;
        overallTotal += amount;
      }

      // Calculate averages
      double dailyAverage = intakes.isEmpty
          ? 0
          : overallTotal / (endDate.difference(startDate).inDays + 1);

      return {
        'daily_totals': dailyTotals,
        'overall_total': overallTotal,
        'daily_average': dailyAverage.round(),
        'number_of_days': endDate.difference(startDate).inDays + 1,
        'total_intakes': intakes.length,
      };
    } catch (e) {
      print('❌ WaterTrackingService: Error fetching historical data: $e');
      return {
        'daily_totals': {},
        'overall_total': 0,
        'daily_average': 0,
        'number_of_days': 0,
        'total_intakes': 0,
      };
    }
  }

  // Schedule a midnight refresh to ensure daily calculations are accurate
  void scheduleMidnightRefresh() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    print(
        '🚰 WaterTrackingService: Scheduling midnight refresh in ${timeUntilMidnight.inHours}h ${timeUntilMidnight.inMinutes % 60}m');

    Timer(timeUntilMidnight, () {
      print('🚰 WaterTrackingService: Executing midnight data refresh');
      refreshFullDayData(2); // Refresh past 2 days to handle edge cases
      scheduleMidnightRefresh(); // Schedule next midnight refresh
    });
  }

  // Method to log all measurements in cache (for debugging)
  void logWeightCache() {
    print('📊 WEIGHT MEASUREMENT CACHE 📊');
    print('Total entries: ${_weightCache.length}');

    if (_weightCache.isEmpty) {
      print('Cache is empty');
      return;
    }

    for (int i = 0; i < _weightCache.length; i++) {
      final entry = _weightCache[i];
      print('${i + 1}. ${entry['weight']}g at ${entry['created_at']}');
    }
  }

  @override
  void onClose() {
    // Clean up timer when service is closed
    print('🚰 WaterTrackingService: Service being closed');
    _weightCheckTimer?.cancel();
    super.onClose();
  }
}
