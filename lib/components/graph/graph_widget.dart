import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:watr/controllers/graph_controller.dart';
import 'package:watr/utils/themes/colors.dart';

class HydrationGraph extends StatelessWidget {
  HydrationGraph({super.key});

  final HydrationController controller = Get.find<HydrationController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedDay = controller.selectedDay.value;
      final dayDetails = controller.dayDetails[selectedDay] ?? [];

      return Column(
        children: [
          // Day selector chips with better styling
          SizedBox(
            height: 50,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (var day in ['mo', 'tu', 'we', 'th', 'fr', 'sa', 'su'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_getDayName(day)),
                        selected: selectedDay == day,
                        onSelected: (selected) {
                          if (selected) controller.setSelectedDay(day);
                        },
                        selectedColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color:
                              selectedDay == day ? Colors.white : Colors.black,
                          fontWeight: selectedDay == day
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Timeline View
          Expanded(
            child: dayDetails.isEmpty
                ? const Center(
                    child: Text(
                      'No water intake recorded for this day',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    itemCount: dayDetails.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final entry = dayDetails[index];
                      // Parse the timestamp and ensure it's in local time
                      final time =
                          DateTime.parse(entry['created_at']).toLocal();
                      final amount = entry['amount'];

                      // Calculate time difference
                      String timeDiff = '';
                      if (index > 0) {
                        final prevTime =
                            DateTime.parse(dayDetails[index - 1]['created_at'])
                                .toLocal();
                        final diff = time.difference(prevTime);
                        final hours = diff.inHours;
                        final minutes = diff.inMinutes % 60;
                        if (hours > 0) {
                          timeDiff = '+${hours}h ${minutes}m';
                        } else {
                          timeDiff = '+${minutes}m';
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time
                              SizedBox(
                                width: 90, // Increased from 70 to 90
                                child: Text(
                                  DateFormat('h:mm a').format(time),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // Timeline dot and line
                              Column(
                                children: [
                                  Container(
                                    width: 2,
                                    height: 24,
                                    color: index == 0
                                        ? Colors.transparent
                                        : AppColors.appGreenlight,
                                  ),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                      width: 2,
                                      height: 24,
                                      color: index == dayDetails.length - 1
                                          ? Colors.transparent
                                          : AppColors.secondary),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // Amount and time difference
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.water_drop,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '$amount ml',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (timeDiff.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          timeDiff,
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }

  String _getDayName(String day) {
    switch (day) {
      case 'mo':
        return 'Mon';
      case 'tu':
        return 'Tue';
      case 'we':
        return 'Wed';
      case 'th':
        return 'Thu';
      case 'fr':
        return 'Fri';
      case 'sa':
        return 'Sat';
      case 'su':
        return 'Sun';
      default:
        return '';
    }
  }
}
