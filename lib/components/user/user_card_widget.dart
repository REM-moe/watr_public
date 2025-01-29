import 'dart:core';
import 'dart:ui'; // Import for BackdropFilter
import 'package:flutter/material.dart';
import 'package:watr/utils/themes/text_themes.dart';

class UserCardWidget extends StatelessWidget {
  final AssetImage image;
  final Text mainMessage;
  final Text subMessage;
  final Icon mainIcon;

  const UserCardWidget({
    super.key,
    required this.image,
    required this.mainMessage,
    required this.mainIcon,
    required this.subMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      width: 200, // Ensures a fixed width
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Backdrop Filter for frosted-glass effect
            Positioned.fill(
              child: BackdropFilter(
                filter:
                    ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Adjust the blur
                child: Container(
                  color:
                      Colors.white.withOpacity(0.2), // Semi-transparent black
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(
                  16.0), // Adjust padding for better spacing
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Image(
                          image: image,
                          height: 60,
                          fit: BoxFit.contain)), // Ensure image fits well

                  const SizedBox(height: 10), // Add spacing

                  // Main message with an icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      mainIcon,
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mainMessage.data ?? '',
                          style:
                              AppTextThemes.lightTextTheme.bodyLarge?.copyWith(
                            color: Colors
                                .white, // White text to stand out on dark background
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2, // Limits to two lines
                          overflow:
                              TextOverflow.ellipsis, // Adds "..." for overflow
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10), // Add spacing

                  // Sub message wrapped properly
                  Text(
                    subMessage.data ?? '',
                    style: AppTextThemes.lightTextTheme.bodyMedium?.copyWith(
                      color: Colors.white, // White text for contrast
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2, // Ensures it doesn't overflow
                    overflow: TextOverflow.ellipsis,
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
