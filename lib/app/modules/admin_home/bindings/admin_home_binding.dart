import 'package:city_guide_app/app/data/services/admin_listing_service.dart';
import 'package:city_guide_app/app/data/services/admin_review_service.dart';
import 'package:city_guide_app/app/data/services/admin_settings_service.dart';
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
    Get.lazyPut<AdminListingService>(AdminListingService.new);
    Get.lazyPut<AdminReviewService>(AdminReviewService.new);
    Get.lazyPut<AdminSettingsService>(AdminSettingsService.new);
    Get.lazyPut<CityService>(CityService.new);
    Get.lazyPut<AdminHomeController>(
      () => AdminHomeController(
        Get.find<CityService>(),
        Get.find<AuthService>(),
        Get.find<AdminListingService>(),
        Get.find<AdminReviewService>(),
        Get.find<AdminSettingsService>(),
      ),
    );
  }
}
