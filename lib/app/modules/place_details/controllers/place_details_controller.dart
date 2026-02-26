import 'package:get/get.dart';

class PlaceDetailsController extends GetxController {
  late final String title;
  late final String category;
  late final String rating;
  late final String distance;
  late final String highlight;

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args = (Get.arguments as Map<String, dynamic>?) ?? <String, dynamic>{};
    title = (args['title'] as String?) ?? 'Place Details';
    category = (args['category'] as String?) ?? 'Category';
    rating = (args['rating'] as String?) ?? '0.0';
    distance = (args['distance'] as String?) ?? '-- km';
    highlight = (args['highlight'] as String?) ?? 'Top pick';
  }
}
