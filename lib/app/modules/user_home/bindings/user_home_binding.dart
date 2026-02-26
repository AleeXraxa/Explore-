import 'package:city_guide_app/app/data/services/auth_service.dart';
import 'package:city_guide_app/app/data/services/city_service.dart';
import 'package:city_guide_app/app/modules/user_home/controllers/user_home_controller.dart';
import 'package:get/get.dart';

class UserHomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(AuthService(), permanent: true);
    }
    Get.lazyPut<CityService>(CityService.new);
    Get.lazyPut<UserHomeController>(
      () => UserHomeController(
        Get.find<CityService>(),
        Get.find<AuthService>(),
      ),
    );
  }
}
