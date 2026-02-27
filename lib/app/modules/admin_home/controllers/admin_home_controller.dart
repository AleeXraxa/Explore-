import 'dart:async';

import 'package:city_guide_app/app/data/models/admin_listing_model.dart';
import 'package:city_guide_app/app/data/models/admin_review_model.dart';
import 'package:city_guide_app/app/data/models/city_model.dart';
import 'package:city_guide_app/app/data/models/user_role.dart';
import 'package:city_guide_app/app/data/services/admin_listing_service.dart';
import 'package:city_guide_app/app/data/services/admin_review_service.dart';
import 'package:city_guide_app/app/data/services/admin_settings_service.dart';
import 'package:city_guide_app/app/data/services/auth_service.dart';
import 'package:city_guide_app/app/data/services/city_service.dart';
import 'package:city_guide_app/app/shared/widgets/premium_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminHomeController extends GetxController {
  AdminHomeController(
    this._cityService,
    this._authService,
    this._adminListingService,
    this._adminReviewService,
    this._adminSettingsService,
  );

  final CityService _cityService;
  final AuthService _authService;
  final AdminListingService _adminListingService;
  final AdminReviewService _adminReviewService;
  final AdminSettingsService _adminSettingsService;
  final RxInt selectedTabIndex = 0.obs;
  final TextEditingController listingSearchController = TextEditingController();
  final TextEditingController reviewSearchController = TextEditingController();
  final RxString listingQuery = ''.obs;
  final RxString reviewQuery = ''.obs;
  final RxString listingStatusFilter = 'all'.obs;
  final RxString reviewStatusFilter = 'all'.obs;
  final RxBool isListingsLoading = true.obs;
  final RxBool isReviewsLoading = true.obs;
  final RxString listingsError = ''.obs;
  final RxString reviewsError = ''.obs;
  final RxList<AdminListingModel> listings = <AdminListingModel>[].obs;
  final RxList<AdminReviewModel> reviews = <AdminReviewModel>[].obs;
  final RxList<CityModel> adminCities = <CityModel>[].obs;
  final TextEditingController citySearchController = TextEditingController();
  final RxString citySearchQuery = ''.obs;
  final RxBool isCitiesLoading = true.obs;
  final RxString citiesError = ''.obs;
  final RxString adminName = 'Alee Khan'.obs;
  final RxString adminEmail = 'admin@explora.app'.obs;
  final RxString adminPhone = '+92 300 1234567'.obs;
  final RxBool strictModerationEnabled = true.obs;
  final RxBool autoHideFlaggedEnabled = false.obs;
  final RxBool realTimeAlertsEnabled = true.obs;
  final RxBool isAdminProfileLoading = true.obs;
  StreamSubscription<List<AdminListingModel>>? _listingsSubscription;
  StreamSubscription<List<AdminReviewModel>>? _reviewsSubscription;
  StreamSubscription<List<CityModel>>? _citiesSubscription;

  String get title => 'Admin Console';
  String get subtitle => 'Manage platform quality, users, and city content.';
  String get profileName => adminName.value;
  String get profileEmail => adminEmail.value;
  String get profilePhone => adminPhone.value;
  List<String> get listingFilters => const <String>[
    'all',
    'pending',
    'approved',
    'rejected',
  ];
  List<String> get reviewFilters => const <String>[
    'all',
    'flagged',
    'visible',
    'hidden',
    'removed',
  ];

  List<AdminListingModel> get filteredListings {
    final String query = listingQuery.value.trim().toLowerCase();
    return listings.where((AdminListingModel listing) {
      final bool statusMatches =
          listingStatusFilter.value == 'all' ||
          listing.status == listingStatusFilter.value;
      final bool queryMatches =
          query.isEmpty ||
          listing.name.toLowerCase().contains(query) ||
          listing.city.toLowerCase().contains(query) ||
          listing.category.toLowerCase().contains(query);
      return statusMatches && queryMatches;
    }).toList();
  }

  int get totalListingsCount => listings.length;
  int get pendingListingsCount =>
      listings.where((AdminListingModel l) => l.status == 'pending').length;
  int get approvedListingsCount =>
      listings.where((AdminListingModel l) => l.status == 'approved').length;
  int get rejectedListingsCount =>
      listings.where((AdminListingModel l) => l.status == 'rejected').length;
  List<AdminReviewModel> get filteredReviews {
    final String query = reviewQuery.value.trim().toLowerCase();
    return reviews.where((AdminReviewModel review) {
      final bool filterMatches = switch (reviewStatusFilter.value) {
        'all' => true,
        'flagged' => review.isFlagged,
        'visible' => review.status == 'visible',
        'hidden' => review.status == 'hidden',
        'removed' => review.status == 'removed',
        _ => true,
      };
      final bool queryMatches =
          query.isEmpty ||
          review.listingName.toLowerCase().contains(query) ||
          review.userName.toLowerCase().contains(query) ||
          review.comment.toLowerCase().contains(query);
      return filterMatches && queryMatches;
    }).toList();
  }

  int get totalReviewsCount => reviews.length;
  int get flaggedReviewsCount =>
      reviews.where((AdminReviewModel r) => r.isFlagged).length;
  int get hiddenReviewsCount =>
      reviews.where((AdminReviewModel r) => r.status == 'hidden').length;
  int get removedReviewsCount =>
      reviews.where((AdminReviewModel r) => r.status == 'removed').length;
  int get resolvedReviewsCount => hiddenReviewsCount + removedReviewsCount;
  int get activeCitiesCount => listings
      .map((AdminListingModel l) => l.city.toLowerCase())
      .toSet()
      .length;
  String get dashboardSystemLabel {
    final bool hasError =
        listingsError.value.isNotEmpty || reviewsError.value.isNotEmpty;
    return hasError ? 'Needs Attention' : 'System Stable';
  }

  String get dashboardQueueLabel => '$pendingListingsCount Pending';
  String get dashboardActiveLabel => '$approvedListingsCount Live';
  String get dashboardSlaScore {
    final int total = totalReviewsCount;
    if (total == 0) return '100%';
    final double score = ((total - flaggedReviewsCount) / total) * 100;
    return '${score.clamp(0, 100).round()}%';
  }

  List<DashboardActivityItem> get dashboardRecentActivities {
    final List<DashboardActivityItem> items = <DashboardActivityItem>[
      ...listings.take(3).map((AdminListingModel listing) {
        final String action = switch (listing.status) {
          'pending' => 'Listing pending moderation',
          'approved' => 'Listing approved and live',
          'rejected' => 'Listing rejected by moderator',
          _ => 'Listing updated',
        };
        return DashboardActivityItem(
          title: action,
          subtitle: '${listing.name} • ${_timeAgo(listing.createdAt)}',
          timestamp: listing.createdAt,
        );
      }),
      ...reviews.take(3).map((AdminReviewModel review) {
        final String action = review.isFlagged
            ? 'Review flagged by community'
            : 'New user review received';
        return DashboardActivityItem(
          title: action,
          subtitle: '${review.listingName} • ${_timeAgo(review.createdAt)}',
          timestamp: review.createdAt,
        );
      }),
    ];

    items.sort(
      (DashboardActivityItem a, DashboardActivityItem b) =>
          (b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
            a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0),
          ),
    );
    return items.take(4).toList();
  }

  String _timeAgo(DateTime? time) {
    if (time == null) return 'just now';
    final Duration diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} d ago';
  }

  List<CityModel> get filteredAdminCities {
    final String query = citySearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return adminCities;
    return adminCities.where((CityModel city) {
      return city.name.toLowerCase().contains(query) ||
          city.country.toLowerCase().contains(query);
    }).toList();
  }

  void onTabChanged(int index) {
    selectedTabIndex.value = index;
  }

  void onListingSearchChanged(String value) {
    listingQuery.value = value;
  }

  void onListingFilterChanged(String value) {
    listingStatusFilter.value = value;
  }

  void onReviewSearchChanged(String value) {
    reviewQuery.value = value;
  }

  void onReviewFilterChanged(String value) {
    reviewStatusFilter.value = value;
  }

  void onCitySearchChanged(String value) {
    citySearchQuery.value = value;
  }

  void setStrictModeration(bool value) {
    strictModerationEnabled.value = value;
    _persistAdminPreferences();
  }

  void setAutoHideFlagged(bool value) {
    autoHideFlaggedEnabled.value = value;
    _persistAdminPreferences();
  }

  void setRealTimeAlerts(bool value) {
    realTimeAlertsEnabled.value = value;
    _persistAdminPreferences();
  }

  Future<void> loadAdminProfileAndSettings() async {
    isAdminProfileLoading.value = true;
    try {
      final Map<String, dynamic> payload = await _adminSettingsService
          .loadAdminProfileAndSettings()
          .timeout(const Duration(seconds: 8));
      adminName.value = (payload['fullName'] as String?) ?? adminName.value;
      adminEmail.value = (payload['email'] as String?) ?? adminEmail.value;
      adminPhone.value = (payload['phone'] as String?) ?? adminPhone.value;
      strictModerationEnabled.value =
          (payload['strictModeration'] as bool?) ?? true;
      autoHideFlaggedEnabled.value =
          (payload['autoHideFlagged'] as bool?) ?? false;
      realTimeAlertsEnabled.value =
          (payload['realTimeAlerts'] as bool?) ?? true;
    } on TimeoutException {
      // Keep defaults if remote read takes too long.
    } catch (_) {
      // Keep local defaults if remote read fails.
    } finally {
      isAdminProfileLoading.value = false;
    }
  }

  Future<void> _persistAdminPreferences() async {
    try {
      await _adminSettingsService.saveAdminPreferences(
        strictModeration: strictModerationEnabled.value,
        autoHideFlagged: autoHideFlaggedEnabled.value,
        realTimeAlerts: realTimeAlertsEnabled.value,
      );
    } catch (_) {
      // Non-blocking persistence; UI state remains responsive.
    }
  }

  Future<void> approveListing(AdminListingModel listing) {
    return _updateListingStatus(
      listing: listing,
      status: 'approved',
      loadingTitle: 'Approving listing',
      successTitle: 'Listing approved',
      successMessage: '${listing.name} is now live for users.',
    );
  }

  Future<void> rejectListing(AdminListingModel listing) {
    return _updateListingStatus(
      listing: listing,
      status: 'rejected',
      loadingTitle: 'Rejecting listing',
      successTitle: 'Listing rejected',
      successMessage: '${listing.name} was removed from approval queue.',
    );
  }

  Future<bool> createListing({
    required String name,
    required String city,
    required String category,
    required String description,
    required String imageUrl,
    required String address,
    required String contactInfo,
    required String openingHours,
    required String website,
    required double latitude,
    required double longitude,
    required double rating,
  }) async {
    PremiumDialogs.showLoading(
      title: 'Creating listing',
      subtitle: 'Publishing record to moderation queue...',
    );
    try {
      await _adminListingService.createListing(
        name: name,
        city: city,
        category: category,
        description: description,
        imageUrl: imageUrl,
        address: address,
        contactInfo: contactInfo,
        openingHours: openingHours,
        website: website,
        latitude: latitude,
        longitude: longitude,
        rating: rating,
      );
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: true,
        title: 'Listing added',
        message: 'New listing created successfully.',
        buttonText: 'Done',
      );
      return true;
    } catch (e) {
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: false,
        title: 'Create failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        buttonText: 'Close',
      );
      return false;
    } finally {
      PremiumDialogs.hideLoading();
    }
  }

  Future<bool> updateListing({
    required String listingId,
    required String name,
    required String city,
    required String category,
    required String description,
    required String imageUrl,
    required String address,
    required String contactInfo,
    required String openingHours,
    required String website,
    required double latitude,
    required double longitude,
    required double rating,
  }) async {
    PremiumDialogs.showLoading(
      title: 'Updating listing',
      subtitle: 'Saving latest content changes...',
    );
    try {
      await _adminListingService.updateListing(
        listingId: listingId,
        name: name,
        city: city,
        category: category,
        description: description,
        imageUrl: imageUrl,
        address: address,
        contactInfo: contactInfo,
        openingHours: openingHours,
        website: website,
        latitude: latitude,
        longitude: longitude,
        rating: rating,
      );
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: true,
        title: 'Listing updated',
        message: 'Listing details were updated successfully.',
        buttonText: 'Done',
      );
      return true;
    } catch (e) {
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: false,
        title: 'Update failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        buttonText: 'Close',
      );
      return false;
    } finally {
      PremiumDialogs.hideLoading();
    }
  }

  Future<void> _updateListingStatus({
    required AdminListingModel listing,
    required String status,
    required String loadingTitle,
    required String successTitle,
    required String successMessage,
  }) async {
    PremiumDialogs.showLoading(
      title: loadingTitle,
      subtitle: 'Applying moderation decision...',
    );
    try {
      await _adminListingService.updateListingStatus(
        listingId: listing.id,
        status: status,
      );
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: true,
        title: successTitle,
        message: successMessage,
        buttonText: 'Done',
      );
    } catch (e) {
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: false,
        title: 'Update failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        buttonText: 'Close',
      );
    } finally {
      PremiumDialogs.hideLoading();
    }
  }

  Future<void> hideReview(AdminReviewModel review) {
    return _moderateReview(
      review: review,
      status: 'hidden',
      loadingTitle: 'Hiding review',
      successTitle: 'Review hidden',
      successMessage: 'This review is now hidden from users.',
      options: const <_ModerationReasonOption>[
        _ModerationReasonOption(
          code: 'spam_or_promo',
          label: 'Spam or Promotion',
          description: 'Contains ads, spam, or promotional noise.',
        ),
        _ModerationReasonOption(
          code: 'off_topic',
          label: 'Off-topic',
          description: 'Not relevant to the place experience.',
        ),
        _ModerationReasonOption(
          code: 'low_quality',
          label: 'Low Quality',
          description: 'Too vague or low-signal for users.',
        ),
      ],
    );
  }

  Future<void> restoreReview(AdminReviewModel review) {
    return _moderateReview(
      review: review,
      status: 'visible',
      loadingTitle: 'Restoring review',
      successTitle: 'Review restored',
      successMessage: 'This review is visible for users again.',
      options: const <_ModerationReasonOption>[
        _ModerationReasonOption(
          code: 'appeal_approved',
          label: 'Appeal Approved',
          description: 'Review passed moderation after reevaluation.',
        ),
        _ModerationReasonOption(
          code: 'false_flag',
          label: 'False Flag',
          description: 'Previous moderation signal was incorrect.',
        ),
      ],
    );
  }

  Future<void> removeReview(AdminReviewModel review) {
    return _moderateReview(
      review: review,
      status: 'removed',
      loadingTitle: 'Removing review',
      successTitle: 'Review removed',
      successMessage: 'This review has been marked as removed.',
      options: const <_ModerationReasonOption>[
        _ModerationReasonOption(
          code: 'abusive_language',
          label: 'Abusive Language',
          description: 'Contains harassment, hate, or abusive text.',
        ),
        _ModerationReasonOption(
          code: 'policy_violation',
          label: 'Policy Violation',
          description: 'Violates review or community policies.',
        ),
        _ModerationReasonOption(
          code: 'fake_or_misleading',
          label: 'Fake or Misleading',
          description: 'Likely fabricated or deceptive review.',
        ),
      ],
    );
  }

  Future<void> _moderateReview({
    required AdminReviewModel review,
    required String status,
    required String loadingTitle,
    required String successTitle,
    required String successMessage,
    required List<_ModerationReasonOption> options,
  }) async {
    final _ModerationDecision? decision = await _promptModerationDecision(
      actionStatus: status,
      options: options,
    );
    if (decision == null) {
      return;
    }
    return _updateReviewStatus(
      review: review,
      status: status,
      reasonCode: decision.reasonCode,
      moderationNote: decision.note,
      loadingTitle: loadingTitle,
      successTitle: successTitle,
      successMessage: successMessage,
    );
  }

  Future<void> _updateReviewStatus({
    required AdminReviewModel review,
    required String status,
    required String reasonCode,
    required String moderationNote,
    required String loadingTitle,
    required String successTitle,
    required String successMessage,
  }) async {
    PremiumDialogs.showLoading(
      title: loadingTitle,
      subtitle: 'Applying moderation action...',
    );
    try {
      await _adminReviewService.updateReviewStatus(
        reviewId: review.id,
        status: status,
        reasonCode: reasonCode,
        moderationNote: moderationNote,
      );
      if (review.listingId.trim().isNotEmpty) {
        await _adminReviewService.recomputeListingRatingAggregates(
          listingId: review.listingId.trim(),
        );
      }
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: true,
        title: successTitle,
        message: successMessage,
        buttonText: 'Done',
      );
    } catch (e) {
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: false,
        title: 'Update failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        buttonText: 'Close',
      );
    } finally {
      PremiumDialogs.hideLoading();
    }
  }

  Future<_ModerationDecision?> _promptModerationDecision({
    required String actionStatus,
    required List<_ModerationReasonOption> options,
  }) async {
    final TextEditingController noteController = TextEditingController();
    final RxString selectedCode = options.first.code.obs;
    try {
      return await Get.dialog<_ModerationDecision>(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Moderation reason',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select reason for ${actionStatus.capitalizeFirst ?? actionStatus}.',
                  style: Get.textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Column(
                    children: options.map((_ModerationReasonOption option) {
                      final bool selected = selectedCode.value == option.code;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(option.label),
                        subtitle: Text(option.description),
                        trailing: Icon(
                          selected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 20,
                          color: selected
                              ? Get.theme.colorScheme.primary
                              : Get.theme.colorScheme.outline,
                        ),
                        onTap: () => selectedCode.value = option.code,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Optional internal note',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back<_ModerationDecision>(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back<_ModerationDecision>(
                            result: _ModerationDecision(
                              reasonCode: selectedCode.value,
                              note: noteController.text.trim(),
                            ),
                          );
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: true,
      );
    } finally {
      noteController.dispose();
    }
  }

  Future<bool> createCity({
    required String name,
    required String country,
    required String description,
    double? latitude,
    double? longitude,
  }) async {
    PremiumDialogs.showLoading(
      title: 'Adding city',
      subtitle: 'Saving city metadata...',
    );
    try {
      await _cityService.createCity(
        name: name,
        country: country,
        description: description,
        latitude: latitude,
        longitude: longitude,
      );
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: true,
        title: 'City added',
        message: '$name has been added successfully.',
        buttonText: 'Done',
      );
      return true;
    } catch (e) {
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: false,
        title: 'Add failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        buttonText: 'Close',
      );
      return false;
    } finally {
      PremiumDialogs.hideLoading();
    }
  }

  Future<bool> updateCity({
    required String cityId,
    required String previousCityName,
    required String name,
    required String country,
    required String description,
    double? latitude,
    double? longitude,
  }) async {
    PremiumDialogs.showLoading(
      title: 'Updating city',
      subtitle: 'Applying latest city details...',
    );
    try {
      await _cityService.updateCity(
        cityId: cityId,
        name: name,
        country: country,
        description: description,
        latitude: latitude,
        longitude: longitude,
      );
      int impactedListings = 0;
      if (previousCityName.trim().toLowerCase() != name.trim().toLowerCase()) {
        impactedListings = await _adminListingService.renameListingsCity(
          oldCityName: previousCityName,
          newCityName: name,
        );
      }
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: true,
        title: 'City updated',
        message: impactedListings > 0
            ? '$name updated. $impactedListings listings were moved to the new city name.'
            : '$name updated successfully.',
        buttonText: 'Done',
      );
      return true;
    } catch (e) {
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: false,
        title: 'Update failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        buttonText: 'Close',
      );
      return false;
    } finally {
      PremiumDialogs.hideLoading();
    }
  }

  Future<void> deleteCity(CityModel city) async {
    if (city.id.trim().isEmpty) {
      await PremiumDialogs.showStatus(
        success: false,
        title: 'Delete failed',
        message: 'City ID is missing.',
        buttonText: 'Close',
      );
      return;
    }
    PremiumDialogs.showLoading(
      title: 'Removing city',
      subtitle: 'Deleting city from directory...',
    );
    try {
      final int deletedListings = await _adminListingService
          .deleteListingsByCity(city.name);
      await _cityService.deleteCity(city.id);
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: true,
        title: 'City removed',
        message: deletedListings > 0
            ? '${city.name} removed. $deletedListings related listings were also deleted.'
            : '${city.name} has been removed.',
        buttonText: 'Done',
      );
    } catch (e) {
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: false,
        title: 'Delete failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        buttonText: 'Close',
      );
    } finally {
      PremiumDialogs.hideLoading();
    }
  }

  void subscribeListings() {
    _listingsSubscription?.cancel();
    isListingsLoading.value = true;
    listingsError.value = '';
    _listingsSubscription = _adminListingService.watchListings().listen(
      (List<AdminListingModel> data) {
        listings.assignAll(data);
        isListingsLoading.value = false;
      },
      onError: (Object error) {
        listingsError.value = 'Unable to load listings.';
        isListingsLoading.value = false;
      },
    );
  }

  void subscribeReviews() {
    _reviewsSubscription?.cancel();
    isReviewsLoading.value = true;
    reviewsError.value = '';
    _reviewsSubscription = _adminReviewService.watchReviews().listen(
      (List<AdminReviewModel> data) {
        reviews.assignAll(data);
        isReviewsLoading.value = false;
      },
      onError: (Object error) {
        reviewsError.value = 'Unable to load reviews.';
        isReviewsLoading.value = false;
      },
    );
  }

  void subscribeCities() {
    _citiesSubscription?.cancel();
    isCitiesLoading.value = true;
    citiesError.value = '';
    _citiesSubscription = _cityService.watchCities().listen(
      (List<CityModel> data) {
        adminCities.assignAll(data);
        isCitiesLoading.value = false;
      },
      onError: (Object error) {
        citiesError.value = 'Unable to load cities.';
        isCitiesLoading.value = false;
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    _cityService;
    _cityService.bootstrapCitiesFromListingsIfMissing();
    _authService.setRole(UserRole.admin);
    subscribeListings();
    subscribeReviews();
    subscribeCities();
    loadAdminProfileAndSettings();
  }

  @override
  void onClose() {
    _listingsSubscription?.cancel();
    _reviewsSubscription?.cancel();
    _citiesSubscription?.cancel();
    listingSearchController.dispose();
    reviewSearchController.dispose();
    citySearchController.dispose();
    super.onClose();
  }
}

class DashboardActivityItem {
  const DashboardActivityItem({
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  final String title;
  final String subtitle;
  final DateTime? timestamp;
}

class _ModerationReasonOption {
  const _ModerationReasonOption({
    required this.code,
    required this.label,
    required this.description,
  });

  final String code;
  final String label;
  final String description;
}

class _ModerationDecision {
  const _ModerationDecision({required this.reasonCode, required this.note});

  final String reasonCode;
  final String note;
}
