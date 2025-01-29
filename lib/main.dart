import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:watr/controllers/auth_controller.dart';
import 'package:watr/controllers/graph_controller.dart';
import 'package:watr/controllers/login_controller.dart';
import 'package:watr/controllers/user_stats_controller.dart';
import 'package:watr/controllers/water_pan_controller.dart';
import 'package:watr/routes/routes.dart';
import 'package:watr/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => SupabaseService().init());
  Gemini.init(apiKey: 'Your Api Key');

  Get.put(AuthController());
  Get.put(LoginController());
  Get.put(HydrationController());
  Get.put(WaterPlanController());
  Get.put(UserStatsController());

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      getPages: getPages,
    );
  }
}
