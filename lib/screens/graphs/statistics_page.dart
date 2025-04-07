import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:watr/components/blur/fliter.dart';
import 'package:watr/components/graph/graph_widget.dart';
import 'package:watr/controllers/auth_controller.dart';
import 'package:watr/controllers/graph_controller.dart';
import 'package:watr/utils/themes/text_themes.dart';

class StatisticsPage extends StatefulWidget {
  // Changed to StatefulWidget
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with WidgetsBindingObserver {
  late final HydrationController controller;

  @override
  void initState() {
    super.initState();
    // Try to find existing controller or create a new one if it doesn't exist
    if (Get.isRegistered<HydrationController>()) {
      controller = Get.find<HydrationController>();
    } else {
      controller = Get.put(HydrationController());
    }

    // Register for lifecycle events
    WidgetsBinding.instance.addObserver(this);

    // Initial refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onPageVisit();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when the app resumes
    if (state == AppLifecycleState.resumed) {
      controller.onPageVisit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background filter
            ...Myfilter(),

            // Main content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Your week",
                      style:
                          AppTextThemes.lightTextTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      // Check if user is authenticated
                      final user = Get.find<AuthController>().user.value;
                      if (user == null) {
                        return const Center(
                          child: Text(
                            'Please sign in to view your statistics',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      // Check if we have any data for the selected day
                      final selectedDay = controller.selectedDay.value;
                      final dayData = controller.dayDetails[selectedDay];

                      // Show loading state if data is being fetched
                      if (dayData == null || controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      // Show empty state if no data is available at all
                      if (!controller.hasAnyData()) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.water_drop_outlined,
                                color: Colors.white.withOpacity(0.5),
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hydration data recorded',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start logging your water intake to see statistics',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Show the hydration graph with data
                      return HydrationGraph();
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
