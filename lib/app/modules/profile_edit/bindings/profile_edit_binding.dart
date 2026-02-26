import 'package:city_guide_app/app/modules/profile_edit/controllers/profile_edit_controller.dart';
import 'package:get/get.dart';

class ProfileEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileEditController>(ProfileEditController.new);
  }
}
