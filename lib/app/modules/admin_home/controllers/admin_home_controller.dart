import 'package:city_guide_app/app/data/models/user_role.dart';
import 'package:city_guide_app/app/data/services/auth_service.dart';
import 'package:city_guide_app/app/data/services/city_service.dart';
import 'package:city_guide_app/app/routes/app_routes.dart';
import 'package:get/get.dart';

class AdminHomeController extends GetxController {
  AdminHomeController(this._cityService, this._authService);

  final CityService _cityService;
  final AuthService _authService;

  String get title => 'Admin Console';
  String get subtitle => 'Manage platform quality, users, and city content.';

  void goToUserView() {
    _authService.setRole(UserRole.user);
    Get.offAllNamed(AppRoutes.userHome);
  }

  @override
  void onInit() {
    super.onInit();
    _cityService;
    _authService.setRole(UserRole.admin);
  }
}
