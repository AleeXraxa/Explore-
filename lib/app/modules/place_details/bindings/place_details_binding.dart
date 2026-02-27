import 'package:city_guide_app/app/data/services/user_review_service.dart';
import 'package:city_guide_app/app/modules/place_details/controllers/place_details_controller.dart';
import 'package:get/get.dart';

class PlaceDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserReviewService>(UserReviewService.new);
    Get.lazyPut<PlaceDetailsController>(
      () => PlaceDetailsController(Get.find<UserReviewService>()),
    );
  }
}
