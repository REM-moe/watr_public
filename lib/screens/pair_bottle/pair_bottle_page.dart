import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:watr/components/blur/fliter.dart';
import 'package:watr/utils/themes/colors.dart';
import 'package:watr/utils/themes/text_themes.dart';

class PairBottlePage extends StatelessWidget {
  const PairBottlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 1.2 * kToolbarHeight, 40, 20),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Circle Decorations
              ...Myfilter(),
              // pairing with bottle
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage('assets/charge.png'),
                      width: 200,
                    ),
                    Text(
                      "Pair your any bottle to smart device!",
                      style: AppTextThemes.lightTextTheme.bodyLarge
                          ?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    SizedBox(
                      width: 260,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (true) {
                            Get.toNamed('/form');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tertiary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cruelty_free, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'connect',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
