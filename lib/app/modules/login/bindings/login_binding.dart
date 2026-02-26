import 'package:city_guide_app/app/data/services/auth_service.dart';
import 'package:city_guide_app/app/modules/login/controllers/login_controller.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(AuthService(), permanent: true);
    }
    Get.lazyPut<LoginController>(() => LoginController(Get.find<AuthService>()));
  }
}
