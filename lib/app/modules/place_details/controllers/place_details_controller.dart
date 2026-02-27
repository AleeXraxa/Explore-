import 'dart:async';

import 'package:city_guide_app/app/data/models/admin_review_model.dart';
import 'package:city_guide_app/app/data/services/user_review_service.dart';
import 'package:city_guide_app/app/shared/widgets/premium_dialogs.dart';
import 'package:get/get.dart';

class PlaceDetailsController extends GetxController {
  PlaceDetailsController(this._userReviewService);

  final UserReviewService _userReviewService;
  String title = 'Place Details';
  String listingId = '';
  String category = 'Category';
  String rating = '0.0';
  String distance = '-- km';
  String highlight = 'Top pick';
  int ratingsCount = 0;
  bool readOnly = false;
  String website = '';
  String imageUrl = '';
  String description = '';
  String contactInfo = '';
  String openingHours = '';
  String address = '';
  double latitude = 0;
  double longitude = 0;
  final RxList<AdminReviewModel> reviews = <AdminReviewModel>[].obs;
  final RxBool isReviewsLoading = true.obs;
  final RxString reviewsError = ''.obs;
  final RxBool hasSubmittedReview = false.obs;
  StreamSubscription<List<AdminReviewModel>>? _reviewsSubscription;
  String get currentUserId => _userReviewService.currentUserId;
  bool get hasUserReviewed =>
      hasSubmittedReview.value ||
      reviews.any(
        (AdminReviewModel item) => item.userId.trim() == currentUserId,
      );
  bool hasUserLikedReview(AdminReviewModel review) =>
      review.isLikedBy(currentUserId);

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args =
        (Get.arguments as Map<String, dynamic>?) ?? <String, dynamic>{};
    title = (args['title'] as String?) ?? 'Place Details';
    listingId = (args['listingId'] as String?)?.trim() ?? '';
    category = (args['category'] as String?) ?? 'Category';
    rating = (args['rating'] as String?) ?? '0.0';
    distance = (args['distance'] as String?) ?? '-- km';
    highlight = (args['highlight'] as String?) ?? 'Top pick';
    ratingsCount = (args['ratingsCount'] as int?) ?? 0;
    readOnly = args['readOnly'] == true;
    website = (args['website'] as String?)?.trim() ?? '';
    imageUrl = (args['imageUrl'] as String?)?.trim() ?? '';
    description = (args['description'] as String?)?.trim() ?? '';
    contactInfo = (args['contactInfo'] as String?)?.trim() ?? '';
    openingHours = (args['openingHours'] as String?)?.trim() ?? '';
    address = (args['address'] as String?)?.trim() ?? '';
    latitude = (args['latitude'] as num?)?.toDouble() ?? 0;
    longitude = (args['longitude'] as num?)?.toDouble() ?? 0;
    _loadSubmittedState();
    _subscribeReviews();
  }

  Future<void> _loadSubmittedState() async {
    try {
      hasSubmittedReview.value = await _userReviewService
          .hasCurrentUserReviewedListing(listingId);
    } catch (_) {
      hasSubmittedReview.value = false;
    }
  }

  void _subscribeReviews() {
    _reviewsSubscription?.cancel();
    isReviewsLoading.value = true;
    reviewsError.value = '';
    _reviewsSubscription = _userReviewService
        .watchListingReviews(listingId)
        .listen(
          (List<AdminReviewModel> items) {
            reviews.assignAll(items);
            isReviewsLoading.value = false;
          },
          onError: (_) {
            reviewsError.value = 'Unable to load reviews.';
            isReviewsLoading.value = false;
          },
        );
  }

  Future<bool> submitReview({
    required double stars,
    required String comment,
  }) async {
    if (listingId.isEmpty) {
      await PremiumDialogs.showStatus(
        success: false,
        title: 'Unable to submit',
        message: 'Listing details are incomplete. Please try again.',
        buttonText: 'Close',
      );
      return false;
    }
    if (comment.trim().isEmpty) {
      await PremiumDialogs.showStatus(
        success: false,
        title: 'Missing comment',
        message: 'Please add a short comment with your rating.',
        buttonText: 'Close',
      );
      return false;
    }
    if (hasUserReviewed) {
      await PremiumDialogs.showStatus(
        success: false,
        title: 'Already reviewed',
        message: 'You can submit only one review for this listing.',
        buttonText: 'Close',
      );
      return false;
    }

    PremiumDialogs.showLoading(
      title: 'Posting review',
      subtitle: 'Saving your feedback...',
    );
    try {
      await _userReviewService.submitReview(
        listingId: listingId,
        listingName: title,
        rating: stars,
        comment: comment,
      );
      hasSubmittedReview.value = true;
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: true,
        title: 'Review posted',
        message: 'Thanks for sharing your experience.',
        buttonText: 'Done',
      );
      _subscribeReviews();
      return true;
    } catch (e) {
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: false,
        title: 'Submit failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        buttonText: 'Close',
      );
      return false;
    } finally {
      PremiumDialogs.hideLoading();
    }
  }

  Future<void> likeReview(AdminReviewModel review) async {
    if (hasUserLikedReview(review)) {
      return;
    }
    try {
      await _userReviewService.likeReview(review.id);
    } catch (_) {
      // Silent fail for lightweight interaction.
    }
  }

  @override
  void onClose() {
    _reviewsSubscription?.cancel();
    super.onClose();
  }
}
