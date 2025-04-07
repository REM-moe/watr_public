import 'package:get/get.dart';
import 'package:watr/services/water_tracking_service.dart';

class WaterController extends GetxController {
  final WaterTrackingService waterService = Get.put(WaterTrackingService());
  RxInt totalConsumed = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTotalWaterConsumed();
  }

  Future<void> fetchTotalWaterConsumed() async {
    totalConsumed.value = await waterService.getTotalWaterConsumedToday();
  }
}
