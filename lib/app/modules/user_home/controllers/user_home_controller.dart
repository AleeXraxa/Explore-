import 'package:city_guide_app/app/data/models/city_model.dart';
import 'package:city_guide_app/app/data/models/user_role.dart';
import 'package:city_guide_app/app/data/services/auth_service.dart';
import 'package:city_guide_app/app/data/services/city_service.dart';
import 'package:city_guide_app/app/routes/app_routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class UserHomeController extends GetxController {
  UserHomeController(this._cityService, this._authService);

  final CityService _cityService;
  final AuthService _authService;
  final RxInt selectedTabIndex = 0.obs;
  final RxString selectedExploreCategory = 'All'.obs;
  final RxString selectedSavedCategory = 'All'.obs;
  final RxBool pushAlertsEnabled = true.obs;
  final RxBool locationAccessEnabled = true.obs;
  final RxBool personalizedSuggestionsEnabled = true.obs;
  final RxString selectedTravelMode = 'Balanced'.obs;
  final RxString profileName = 'Alee'.obs;
  final RxString profileEmail = 'alee@explora.app'.obs;
  final RxString profilePhone = '+92 300 1234567'.obs;
  final RxBool isDetectingCity = false.obs;
  late final List<CityModel> cities;
  late final Rx<CityModel> selectedCity;

  String get title => 'Explore Your City';
  String get subtitle => 'Discover places, build plans, and save favorites.';
  String get userName => profileName.value;
  String get email => profileEmail.value;
  String get phone => profilePhone.value;
  String get cityName => selectedCity.value.name;
  String get cityDescription => selectedCity.value.description;
  List<String> get exploreCategories => const <String>[
    'All',
    'Food',
    'Culture',
    'Nature',
    'Nightlife',
  ];
  List<String> get savedCategories => const <String>[
    'All',
    'Favorites',
    'Recent',
    'Plans',
  ];

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

  void selectCity(CityModel city) {
    selectedCity.value = city;
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

  void goToAdminView() {
    _authService.setRole(UserRole.admin);
    Get.offAllNamed(AppRoutes.adminHome);
  }

  Future<void> detectCurrentCityFromLocation() async {
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
    cities = _cityService.getAvailableCities();
    selectedCity = _cityService.getDefaultCity().obs;
    _authService.setRole(UserRole.user);
  }

  @override
  void onReady() {
    super.onReady();
    detectCurrentCityFromLocation();
  }
}
