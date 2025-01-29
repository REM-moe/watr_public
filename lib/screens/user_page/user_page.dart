import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watr/components/blur/fliter.dart';
import 'package:watr/components/stats/stats_widget.dart';
import 'package:watr/components/user/user_card_widget.dart';
import 'package:watr/controllers/user_stats_controller.dart';
import 'package:watr/utils/themes/text_themes.dart';

class UserPage extends StatelessWidget {
  UserPage({super.key});

  final UserStatsController controller = Get.put(UserStatsController());

  @override
  Widget build(BuildContext context) {
    controller.update(); // Force a rebuild

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ...Myfilter(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
              child: Obx(
                () => Text(
                  "Hi ${controller.username.value} 👋",
                  style: AppTextThemes.lightTextTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Updated layout for user cards
                      _buildUserCards(),
                      // Updated layout for stats cards
                      _buildStatsCards(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCards() {
    return Column(
      children: [
        Obx(
          () => Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: StatsWidget(
              mainIcon: const Icon(Icons.emoji_events,
                  color: Colors.orange, size: 36),
              mainMessage: Text("Best Day",
                  style: AppTextThemes.lightTextTheme.bodyMedium),
              subMessage: Text(
                controller.funFact.value,
                style: AppTextThemes.lightTextTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              image: const AssetImage('assets/user.png'),
            ),
          ),
        ),
        Obx(
          () => Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: StatsWidget(
              mainIcon:
                  const Icon(Icons.show_chart, color: Colors.green, size: 36),
              mainMessage:
                  Text("Stats", style: AppTextThemes.lightTextTheme.bodyMedium),
              subMessage: Text(
                controller.waterAdvice.value,
                style: AppTextThemes.lightTextTheme.bodySmall,
              ),
              image: const AssetImage('assets/graph.png'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Column(
      children: [
        Obx(
          () => Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: UserCardWidget(
              mainIcon: const Icon(Icons.pets, color: Colors.blue, size: 36),
              mainMessage: Text("Personality",
                  style: AppTextThemes.lightTextTheme.bodyMedium),
              subMessage: Text(
                controller.hydrationPersonality.value,
                style: AppTextThemes.lightTextTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              image: const AssetImage('assets/duck.png'),
            ),
          ),
        ),
        Obx(
          () => Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: UserCardWidget(
              mainIcon: const Icon(Icons.local_fire_department,
                  color: Colors.red, size: 36),
              mainMessage: Text("Your Streak",
                  style: AppTextThemes.lightTextTheme.bodyMedium),
              subMessage: Text(
                "Streak: ${controller.streakDays.value} days",
                style: AppTextThemes.lightTextTheme.bodySmall,
              ),
              image: const AssetImage('assets/lily.png'),
            ),
          ),
        ),
      ],
    );
  }
}
