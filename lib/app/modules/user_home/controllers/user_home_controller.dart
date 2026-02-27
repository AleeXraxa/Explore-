import 'dart:async';

import 'package:city_guide_app/app/data/models/admin_listing_model.dart';
import 'package:city_guide_app/app/data/models/city_model.dart';
import 'package:city_guide_app/app/data/models/user_role.dart';
import 'package:city_guide_app/app/data/services/admin_listing_service.dart';
import 'package:city_guide_app/app/data/services/auth_service.dart';
import 'package:city_guide_app/app/data/services/city_service.dart';
import 'package:city_guide_app/app/routes/app_routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class UserHomeController extends GetxController {
  UserHomeController(
    this._cityService,
    this._authService,
    this._adminListingService,
  );

  final CityService _cityService;
  final AuthService _authService;
  final AdminListingService _adminListingService;
  final RxInt selectedTabIndex = 0.obs;
  final RxString selectedExploreCategory = 'All'.obs;
  final RxString selectedSavedCategory = 'All'.obs;
  final RxString exploreQuery = ''.obs;
  final RxDouble minExploreRating = 0.0.obs;
  final RxString exploreSort = 'Top Rated'.obs;
  final RxBool pushAlertsEnabled = true.obs;
  final RxBool locationAccessEnabled = true.obs;
  final RxBool personalizedSuggestionsEnabled = true.obs;
  final RxString selectedTravelMode = 'Balanced'.obs;
  final RxString profileName = 'Alee'.obs;
  final RxString profileEmail = 'alee@explora.app'.obs;
  final RxString profilePhone = '+92 300 1234567'.obs;
  final RxBool isDetectingCity = false.obs;
  final RxBool isCitySwitchLoading = false.obs;
  final RxList<CityModel> cities = <CityModel>[].obs;
  static const CityModel _emptyCity = CityModel(
    name: 'Select City',
    country: 'Your region',
    description: 'No cities available yet. Please check back soon.',
    latitude: 0,
    longitude: 0,
  );
  late final Rx<CityModel> selectedCity;
  final RxString citySearchQuery = ''.obs;
  final RxList<AdminListingModel> allListings = <AdminListingModel>[].obs;
  final Completer<void> _firstListingsLoadedCompleter = Completer<void>();
  StreamSubscription<List<CityModel>>? _citiesSubscription;
  StreamSubscription<List<AdminListingModel>>? _listingsSubscription;

  String get title => 'Explore Your City';
  String get subtitle => 'Discover places, build plans, and save favorites.';
  String get userName => profileName.value;
  String get email => profileEmail.value;
  String get phone => profilePhone.value;
  String get cityName => selectedCity.value.name;
  String get cityDescription => selectedCity.value.description;
  List<CityModel> get filteredCities {
    final String query = citySearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return cities;
    return cities.where((CityModel city) {
      final String name = city.name.toLowerCase();
      final String country = city.country.toLowerCase();
      return name.contains(query) || country.contains(query);
    }).toList();
  }

  List<String> get exploreCategories => const <String>[
    'All',
    'Food',
    'Culture',
    'Nature',
    'Nightlife',
  ];
  List<String> get savedCategories => const <String>[
    'All',
    'Food',
    'Culture',
    'Nature',
    'Nightlife',
  ];
  List<AdminListingModel> get cityApprovedListings =>
      allListings.where((AdminListingModel listing) {
        final String listingCity = listing.city.trim().toLowerCase();
        final String selectedCityName = selectedCity.value.name
            .trim()
            .toLowerCase();
        return listing.status == 'approved' && listingCity == selectedCityName;
      }).toList();

  List<AdminListingModel> get filteredExploreListings {
    final String selected = selectedExploreCategory.value;
    final String query = exploreQuery.value.trim().toLowerCase();
    final List<AdminListingModel> source = cityApprovedListings;
    final List<AdminListingModel> filtered = source
        .where(
          (AdminListingModel listing) {
            final bool categoryMatches = selected == 'All' ||
                listing.category.toLowerCase() == selected.toLowerCase();
            final bool queryMatches = query.isEmpty ||
                listing.name.toLowerCase().contains(query) ||
                listing.category.toLowerCase().contains(query) ||
                listing.description.toLowerCase().contains(query) ||
                listing.address.toLowerCase().contains(query);
            final bool ratingMatches =
                listing.displayRating >= minExploreRating.value;
            return categoryMatches && queryMatches && ratingMatches;
          },
        )
        .toList();

    if (exploreSort.value == 'Top Rated') {
      filtered.sort((a, b) => b.displayRating.compareTo(a.displayRating));
    } else if (exploreSort.value == 'Most Reviewed') {
      filtered.sort((a, b) => b.ratingsCount.compareTo(a.ratingsCount));
    } else if (exploreSort.value == 'A-Z') {
      filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return filtered;
  }

  void onTabChanged(int index) {
    selectedTabIndex.value = index;
  }

  void openExplore() => onTabChanged(1);

  void openSaved() => onTabChanged(2);

  void openPlanner() {
    Get.snackbar(
      'Planner coming next',
      'Planner module will be added in the next iteration.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void selectExploreCategory(String category) {
    selectedExploreCategory.value = category;
  }

  void setExploreQuery(String value) {
    exploreQuery.value = value;
  }

  void setMinExploreRating(double value) {
    minExploreRating.value = value;
  }

  void setExploreSort(String value) {
    exploreSort.value = value;
  }

  void selectSavedCategory(String category) {
    selectedSavedCategory.value = category;
  }

  void setPushAlerts(bool value) {
    pushAlertsEnabled.value = value;
  }

  void setLocationAccess(bool value) {
    locationAccessEnabled.value = value;
  }

  void setPersonalizedSuggestions(bool value) {
    personalizedSuggestionsEnabled.value = value;
  }

  void selectTravelMode(String mode) {
    selectedTravelMode.value = mode;
  }

  Future<void> selectCity(CityModel city) async {
    final String nextCity = city.name.trim().toLowerCase();
    final String currentCity = selectedCity.value.name.trim().toLowerCase();
    if (nextCity == currentCity) {
      citySearchQuery.value = '';
      return;
    }

    selectedCity.value = city;
    citySearchQuery.value = '';
    isCitySwitchLoading.value = true;
    try {
      await Future.wait(<Future<void>>[
        Future<void>.delayed(const Duration(seconds: 2)),
        _waitForListingsReady(),
      ]);
    } finally {
      isCitySwitchLoading.value = false;
    }
  }

  void setCitySearchQuery(String value) {
    citySearchQuery.value = value;
  }

  Future<void> _waitForListingsReady() async {
    if (_firstListingsLoadedCompleter.isCompleted) {
      return;
    }
    await _firstListingsLoadedCompleter.future.timeout(
      const Duration(seconds: 3),
      onTimeout: () {},
    );
  }

  void logout() {
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> openProfileEdit() async {
    final dynamic result = await Get.toNamed(
      AppRoutes.profileEdit,
      arguments: <String, dynamic>{
        'name': profileName.value,
        'email': profileEmail.value,
        'phone': profilePhone.value,
      },
    );

    if (result is Map<String, dynamic>) {
      profileName.value = (result['name'] as String?) ?? profileName.value;
      profileEmail.value = (result['email'] as String?) ?? profileEmail.value;
      profilePhone.value = (result['phone'] as String?) ?? profilePhone.value;
    }
  }

  Future<void> detectCurrentCityFromLocation() async {
    if (cities.isEmpty) return;
    isDetectingCity.value = true;
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      selectedCity.value = _cityService.getNearestCity(
        cities: cities,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      // Keep default selected city if location fails.
    } finally {
      isDetectingCity.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _cityService.bootstrapCitiesFromListingsIfMissing();
    selectedCity = _emptyCity.obs;
    _citiesSubscription = _cityService.watchCities().listen((
      List<CityModel> items,
    ) {
      cities.assignAll(items);
      if (items.isEmpty) {
        selectedCity.value = _emptyCity;
        return;
      }
      if (!items.any(
        (CityModel city) => city.name == selectedCity.value.name,
      )) {
        selectedCity.value = items.first;
      }
    });
    _listingsSubscription = _adminListingService.watchListings().listen((
      List<AdminListingModel> items,
    ) {
      allListings.assignAll(items);
      if (!_firstListingsLoadedCompleter.isCompleted) {
        _firstListingsLoadedCompleter.complete();
      }
    });
    _authService.setRole(UserRole.user);
  }

  @override
  void onReady() {
    super.onReady();
    detectCurrentCityFromLocation();
  }

  @override
  void onClose() {
    _citiesSubscription?.cancel();
    _listingsSubscription?.cancel();
    super.onClose();
  }
}
