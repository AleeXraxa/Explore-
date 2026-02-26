import 'package:city_guide_app/app/data/services/auth_service.dart';
import 'package:city_guide_app/app/modules/register/controllers/register_controller.dart';
import 'package:get/get.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(AuthService(), permanent: true);
    }
    Get.lazyPut<RegisterController>(
      () => RegisterController(Get.find<AuthService>()),
    );
  }
}
