import 'package:flutter/material.dart';
import 'package:watr/components/blur/fliter.dart';
import 'package:watr/components/bottle_config/bottle_config_widget.dart';

class BottleConfigPage extends StatelessWidget {
  const BottleConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: [
            ...Myfilter(),
            SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: BottleWeightConfig(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
