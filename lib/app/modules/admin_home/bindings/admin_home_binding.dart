import 'package:city_guide_app/app/data/services/auth_service.dart';
import 'package:city_guide_app/app/data/services/city_service.dart';
import 'package:city_guide_app/app/modules/admin_home/controllers/admin_home_controller.dart';
import 'package:get/get.dart';

class AdminHomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(AuthService(), permanent: true);
    }
    Get.lazyPut<CityService>(CityService.new);
    Get.lazyPut<AdminHomeController>(
      () => AdminHomeController(
        Get.find<CityService>(),
        Get.find<AuthService>(),
      ),
    );
  }
}
