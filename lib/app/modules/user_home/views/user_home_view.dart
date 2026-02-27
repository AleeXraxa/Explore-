import 'package:city_guide_app/app/data/models/admin_listing_model.dart';
import 'package:city_guide_app/app/modules/user_home/controllers/user_home_controller.dart';
import 'package:city_guide_app/app/modules/user_home/widgets/category_grid.dart';
import 'package:city_guide_app/app/modules/user_home/widgets/city_selection_sheet.dart';
import 'package:city_guide_app/app/modules/user_home/widgets/home_header.dart';
import 'package:city_guide_app/app/modules/user_home/widgets/home_search_bar.dart';
import 'package:city_guide_app/app/modules/user_home/widgets/home_section_title.dart';
import 'package:city_guide_app/app/modules/user_home/widgets/quick_actions_row.dart';
import 'package:city_guide_app/app/shared/widgets/delayed_reveal.dart';
import 'package:city_guide_app/app/shared/widgets/premium_bottom_nav_bar.dart';
import 'package:city_guide_app/app/routes/app_routes.dart';
import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class UserHomeView extends GetView<UserHomeController> {
  const UserHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    const List<NavItemData> navItems = <NavItemData>[
      NavItemData(label: 'Home', icon: Icons.home_rounded),
      NavItemData(label: 'Explore', icon: Icons.travel_explore_rounded),
      NavItemData(label: 'Saved', icon: Icons.bookmark_rounded),
      NavItemData(label: 'Profile', icon: Icons.person_rounded),
    ];

    return Scaffold(
      body: Obx(
        () => Stack(
          children: <Widget>[
            IndexedStack(
              index: controller.selectedTabIndex.value,
              children: <Widget>[
                _HomeTab(controller: controller),
                _ExploreTab(controller: controller),
                _SavedTab(controller: controller),
                _ProfileTab(controller: controller),
              ],
            ),
            if (controller.isCitySwitchLoading.value)
              const _CitySwitchLoadingOverlay(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => PremiumBottomNavBar(
          currentIndex: controller.selectedTabIndex.value,
          items: navItems,
          onTap: controller.onTabChanged,
        ),
      ),
    );
  }
}

class _CitySwitchLoadingOverlay extends StatelessWidget {
  const _CitySwitchLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.white.withValues(alpha: 0.8),
          child: Center(
            child: Container(
              width: 210.w,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md.w,
                vertical: AppSpacing.md.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.inputBorder.withValues(alpha: 0.8),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 26.w,
                    height: 26.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.inputFocused,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    'Switching city',
                    style: AppTextStyles.button.copyWith(fontSize: 14.sp),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Loading listings for your selection...',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.controller});

  final UserHomeController controller;

  @override
  Widget build(BuildContext context) {
    void showCityPicker() {
      controller.setCitySearchQuery('');
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (BuildContext context) {
          return Obx(
            () => CitySelectionSheet(
              cities: controller.filteredCities,
              selectedCity: controller.selectedCity.value,
              onSearchChanged: controller.setCitySearchQuery,
              onCitySelected: (city) {
                controller.selectCity(city);
                Get.back<void>();
              },
            ),
          );
        },
      ).whenComplete(() => controller.setCitySearchQuery(''));
    }

    return SafeArea(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -80.h,
            right: -70.w,
            child: Container(
              width: 240.w,
              height: 240.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    AppColors.accent.withValues(alpha: 0.12),
                    AppColors.accent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Obx(
                  () => HomeHeader(
                    userName: controller.userName,
                    cityName: controller.cityName,
                    isLoadingCity: controller.isDetectingCity.value,
                    onCityTap: showCityPicker,
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),
                const DelayedReveal(
                  delay: Duration(milliseconds: 80),
                  child: HomeSearchBar(),
                ),
                SizedBox(height: AppSpacing.md.h),
                DelayedReveal(
                  delay: const Duration(milliseconds: 130),
                  child: QuickActionsRow(
                    onExploreTap: controller.openExplore,
                    onPlanTap: controller.openPlanner,
                    onSavedTap: controller.openSaved,
                  ),
                ),
                SizedBox(height: AppSpacing.xl.h),
                Obx(() {
                  final List<AdminListingModel> cityListings =
                      controller.cityApprovedListings;
                  final List<AdminListingModel> trending = cityListings
                      .take(3)
                      .toList();
                  final List<AdminListingModel> recommended = cityListings
                      .skip(3)
                      .take(3)
                      .toList();

                  if (cityListings.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppSpacing.lg.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.inputBorder.withValues(alpha: 0.8),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.location_city_rounded,
                            size: 30.sp,
                            color: AppColors.inputFocused,
                          ),
                          SizedBox(height: AppSpacing.sm.h),
                          Text(
                            'No listings in ${controller.cityName} yet',
                            style: AppTextStyles.button.copyWith(
                              fontSize: 14.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.xs.h),
                          Text(
                            'Switch city or check back after new listings are approved.',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 12.5.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const DelayedReveal(
                        delay: Duration(milliseconds: 170),
                        child: HomeSectionTitle(title: 'Trending in your city'),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      ...trending.map(
                        (AdminListingModel item) => _HomeCityListingCard(
                          item: item,
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.placeDetails,
                              arguments: <String, dynamic>{
                                'listingId': item.id,
                                'title': item.name,
                                'category': item.category,
                                'rating': item.displayRating.toStringAsFixed(1),
                                'ratingsCount': item.ratingsCount,
                                'distance': item.address,
                                'highlight': item.openingHours,
                                'website': item.website,
                                'imageUrl': item.imageUrl,
                                'description': item.description,
                                'contactInfo': item.contactInfo,
                                'openingHours': item.openingHours,
                                'address': item.address,
                                'latitude': item.latitude != 0
                                    ? item.latitude
                                    : controller.selectedCity.value.latitude,
                                'longitude': item.longitude != 0
                                    ? item.longitude
                                    : controller.selectedCity.value.longitude,
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      const DelayedReveal(
                        delay: Duration(milliseconds: 240),
                        child: HomeSectionTitle(title: 'Top categories'),
                      ),
                      const DelayedReveal(
                        delay: Duration(milliseconds: 270),
                        child: CategoryGrid(),
                      ),
                      if (recommended.isNotEmpty) ...<Widget>[
                        SizedBox(height: AppSpacing.lg.h),
                        const DelayedReveal(
                          delay: Duration(milliseconds: 370),
                          child: HomeSectionTitle(title: 'Recommended for you'),
                        ),
                        SizedBox(height: AppSpacing.sm.h),
                        ...recommended.map(
                          (AdminListingModel item) => _HomeCityListingCard(
                            item: item,
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.placeDetails,
                                arguments: <String, dynamic>{
                                  'listingId': item.id,
                                  'title': item.name,
                                  'category': item.category,
                                  'rating': item.displayRating.toStringAsFixed(
                                    1,
                                  ),
                                  'ratingsCount': item.ratingsCount,
                                  'distance': item.address,
                                  'highlight': item.openingHours,
                                  'website': item.website,
                                  'imageUrl': item.imageUrl,
                                  'description': item.description,
                                  'contactInfo': item.contactInfo,
                                  'openingHours': item.openingHours,
                                  'address': item.address,
                                  'latitude': item.latitude != 0
                                      ? item.latitude
                                      : controller.selectedCity.value.latitude,
                                  'longitude': item.longitude != 0
                                      ? item.longitude
                                      : controller.selectedCity.value.longitude,
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCityListingCard extends StatelessWidget {
  const _HomeCityListingCard({required this.item, required this.onTap});

  final AdminListingModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: AppColors.inputBorder.withValues(alpha: 0.8),
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.button.copyWith(fontSize: 14.5.sp),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      item.category,
                      style: AppTextStyles.body.copyWith(fontSize: 12.5.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.star_rounded,
                        size: 14.sp,
                        color: AppColors.inputFocused,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        item.displayRating.toStringAsFixed(1),
                        style: AppTextStyles.body.copyWith(fontSize: 12.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreTab extends StatelessWidget {
  const _ExploreTab({required this.controller});

  final UserHomeController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -90.h,
            left: -60.w,
            child: Container(
              width: 230.w,
              height: 230.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    AppColors.accent.withValues(alpha: 0.1),
                    AppColors.accent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Obx(() {
            final String selected = controller.selectedExploreCategory.value;
            final List<AdminListingModel> filtered = selected == 'All'
                ? controller.filteredExploreListings
                : controller.filteredExploreListings
                      .where(
                        (AdminListingModel p) =>
                            p.category.toLowerCase() == selected.toLowerCase(),
                      )
                      .toList();

            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Explore',
                    style: AppTextStyles.title.copyWith(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  Text(
                    'Search, filter, and discover places in ${controller.cityName}.',
                    style: AppTextStyles.body,
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  InkWell(
                    onTap: () {
                      controller.setCitySearchQuery('');
                      showModalBottomSheet<void>(
                        context: context,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20.r),
                          ),
                        ),
                        builder: (BuildContext context) => CitySelectionSheet(
                          cities: controller.filteredCities,
                          selectedCity: controller.selectedCity.value,
                          onSearchChanged: controller.setCitySearchQuery,
                          onCitySelected: (city) {
                            controller.selectCity(city);
                            Get.back<void>();
                          },
                        ),
                      ).whenComplete(() => controller.setCitySearchQuery(''));
                    },
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs.w,
                        vertical: AppSpacing.xxs.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.location_on_rounded,
                            size: 15.sp,
                            color: AppColors.inputFocused,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            controller.cityName,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.inputFocused,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  TextField(
                    onChanged: controller.setExploreQuery,
                    decoration: InputDecoration(
                      hintText: 'Search places, categories, keywords...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(
                          color: AppColors.inputBorder.withValues(alpha: 0.8),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(
                          color: AppColors.inputBorder.withValues(alpha: 0.8),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(
                          color: AppColors.inputFocused,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Obx(
                    () => Row(
                      children: <Widget>[
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: controller.exploreSort.value,
                            decoration: InputDecoration(
                              labelText: 'Sort',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            items:
                                const <String>[
                                  'Top Rated',
                                  'Most Reviewed',
                                  'A-Z',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                            onChanged: (String? value) {
                              if (value != null) {
                                controller.setExploreSort(value);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: AppSpacing.xs.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Min Rating: ${controller.minExploreRating.value.toStringAsFixed(1)}',
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 12.sp,
                                ),
                              ),
                              Slider(
                                value: controller.minExploreRating.value,
                                min: 0,
                                max: 5,
                                divisions: 10,
                                onChanged: controller.setMinExploreRating,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  SizedBox(
                    height: 42.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.exploreCategories.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: AppSpacing.xs.w),
                      itemBuilder: (BuildContext context, int index) {
                        final String item = controller.exploreCategories[index];
                        final bool active = selected == item;

                        return InkWell(
                          onTap: () => controller.selectExploreCategory(item),
                          borderRadius: BorderRadius.circular(12.r),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md.w,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.accent.withValues(alpha: 0.16)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: active
                                    ? AppColors.accent
                                    : AppColors.inputBorder.withValues(
                                        alpha: 0.75,
                                      ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                item,
                                style: AppTextStyles.button.copyWith(
                                  fontSize: 12.5.sp,
                                  color: active
                                      ? AppColors.inputFocused
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  ...filtered.map(
                    (AdminListingModel item) => _ExplorePlaceCard(
                      place: item,
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.placeDetails,
                          arguments: <String, dynamic>{
                            'listingId': item.id,
                            'title': item.name,
                            'category': item.category,
                            'rating': item.displayRating.toStringAsFixed(1),
                            'ratingsCount': item.ratingsCount,
                            'distance': item.address,
                            'highlight': item.openingHours,
                            'website': item.website,
                            'imageUrl': item.imageUrl,
                            'description': item.description,
                            'contactInfo': item.contactInfo,
                            'openingHours': item.openingHours,
                            'address': item.address,
                            'latitude': item.latitude != 0
                                ? item.latitude
                                : controller.selectedCity.value.latitude,
                            'longitude': item.longitude != 0
                                ? item.longitude
                                : controller.selectedCity.value.longitude,
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ExplorePlaceCard extends StatelessWidget {
  const _ExplorePlaceCard({required this.place, required this.onTap});

  final AdminListingModel place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.inputBorder.withValues(alpha: 0.8),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Container(
                height: 120.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      AppColors.accent.withValues(alpha: 0.28),
                      AppColors.accent.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: EdgeInsets.all(AppSpacing.sm.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs.w,
                      vertical: AppSpacing.xxs.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      place.openingHours,
                      style: AppTextStyles.button.copyWith(
                        fontSize: 10.5.sp,
                        color: AppColors.inputFocused,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppSpacing.md.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            place.name,
                            style: AppTextStyles.button.copyWith(
                              fontSize: 15.sp,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs.h),
                          Text(
                            place.category,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 12.5.sp,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs.h),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.star_rounded,
                                size: 15.sp,
                                color: AppColors.inputFocused,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                place.displayRating.toStringAsFixed(1),
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '(${place.ratingsCount})',
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 11.5.sp,
                                ),
                              ),
                              SizedBox(width: AppSpacing.sm.w),
                              Icon(
                                Icons.near_me_rounded,
                                size: 14.sp,
                                color: AppColors.inputFocused,
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  place.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedTab extends StatelessWidget {
  const _SavedTab({required this.controller});

  final UserHomeController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -70.h,
            right: -60.w,
            child: Container(
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    AppColors.accent.withValues(alpha: 0.08),
                    AppColors.accent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Obx(() {
            final String selected = controller.selectedSavedCategory.value;
            final List<AdminListingModel> source =
                controller.cityApprovedListings;
            final List<AdminListingModel> filtered = selected == 'All'
                ? source
                : source
                      .where(
                        (AdminListingModel p) =>
                            p.category.toLowerCase() == selected.toLowerCase(),
                      )
                      .toList();

            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Saved',
                    style: AppTextStyles.title.copyWith(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  Text(
                    'Your bookmarked places and ready-to-go plans.',
                    style: AppTextStyles.body,
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  SizedBox(
                    height: 42.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.savedCategories.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: AppSpacing.xs.w),
                      itemBuilder: (BuildContext context, int index) {
                        final String item = controller.savedCategories[index];
                        final bool active = selected == item;

                        return InkWell(
                          onTap: () => controller.selectSavedCategory(item),
                          borderRadius: BorderRadius.circular(12.r),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md.w,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.accent.withValues(alpha: 0.16)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: active
                                    ? AppColors.accent
                                    : AppColors.inputBorder.withValues(
                                        alpha: 0.75,
                                      ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                item,
                                style: AppTextStyles.button.copyWith(
                                  fontSize: 12.5.sp,
                                  color: active
                                      ? AppColors.inputFocused
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: AppColors.inputBorder.withValues(alpha: 0.75),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.bookmarks_rounded,
                          color: AppColors.inputFocused,
                          size: 20.sp,
                        ),
                        SizedBox(width: AppSpacing.sm.w),
                        Text(
                          '${filtered.length} places saved',
                          style: AppTextStyles.button.copyWith(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  if (filtered.isEmpty)
                    _SavedEmptyState(onExploreTap: controller.openExplore)
                  else
                    ...filtered.map(
                      (AdminListingModel place) => _SavedPlaceCard(
                        place: place,
                        onOpen: () {
                          Get.toNamed(
                            AppRoutes.placeDetails,
                            arguments: <String, dynamic>{
                              'listingId': place.id,
                              'title': place.name,
                              'category': place.category,
                              'rating': place.displayRating.toStringAsFixed(1),
                              'ratingsCount': place.ratingsCount,
                              'distance': place.address,
                              'highlight': place.openingHours,
                              'website': place.website,
                              'imageUrl': place.imageUrl,
                              'description': place.description,
                              'contactInfo': place.contactInfo,
                              'openingHours': place.openingHours,
                              'address': place.address,
                              'latitude': place.latitude != 0
                                  ? place.latitude
                                  : controller.selectedCity.value.latitude,
                              'longitude': place.longitude != 0
                                  ? place.longitude
                                  : controller.selectedCity.value.longitude,
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SavedPlaceCard extends StatelessWidget {
  const _SavedPlaceCard({required this.place, required this.onOpen});

  final AdminListingModel place;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.inputBorder.withValues(alpha: 0.8),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.bookmark_rounded,
                  color: AppColors.inputFocused,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      place.name,
                      style: AppTextStyles.button.copyWith(fontSize: 15.sp),
                    ),
                    SizedBox(height: AppSpacing.xxs.h),
                    Text(
                      place.openingHours,
                      style: AppTextStyles.body.copyWith(fontSize: 12.8.sp),
                    ),
                    SizedBox(height: AppSpacing.xs.h),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.star_rounded,
                          size: 14.sp,
                          color: AppColors.inputFocused,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          place.displayRating.toStringAsFixed(1),
                          style: AppTextStyles.body.copyWith(fontSize: 12.sp),
                        ),
                        SizedBox(width: AppSpacing.sm.w),
                        Icon(
                          Icons.near_me_rounded,
                          size: 13.sp,
                          color: AppColors.inputFocused,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          place.address,
                          style: AppTextStyles.body.copyWith(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  IconButton(
                    onPressed: onOpen,
                    icon: Icon(Icons.open_in_new_rounded, size: 18.sp),
                    color: AppColors.inputFocused,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.delete_outline_rounded, size: 18.sp),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedEmptyState extends StatelessWidget {
  const _SavedEmptyState({required this.onExploreTap});

  final VoidCallback onExploreTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.inputBorder.withValues(alpha: 0.8)),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.bookmark_border_rounded,
            size: 34.sp,
            color: AppColors.inputFocused,
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            'No saved places yet',
            style: AppTextStyles.button.copyWith(fontSize: 15.sp),
          ),
          SizedBox(height: AppSpacing.xs.h),
          Text(
            'No approved listings for this city yet. Try another city or check Explore.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(fontSize: 13.sp),
          ),
          SizedBox(height: AppSpacing.md.h),
          TextButton(
            onPressed: onExploreTap,
            child: const Text('Go to Explore'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.controller});

  final UserHomeController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Profile',
              style: AppTextStyles.title.copyWith(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              'Manage account preferences and role settings.',
              style: AppTextStyles.body,
            ),
            SizedBox(height: AppSpacing.lg.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    AppColors.accent.withValues(alpha: 0.2),
                    AppColors.accent.withValues(alpha: 0.08),
                  ],
                ),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 54.w,
                    height: 54.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.84),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Center(
                      child: Text(
                        'AK',
                        style: AppTextStyles.button.copyWith(
                          fontSize: 16.sp,
                          color: AppColors.inputFocused,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          controller.userName,
                          style: AppTextStyles.title.copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          controller.email,
                          style: AppTextStyles.body.copyWith(fontSize: 13.sp),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          controller.phone,
                          style: AppTextStyles.body.copyWith(fontSize: 12.5.sp),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: controller.openProfileEdit,
                    icon: Icon(Icons.edit_outlined, size: 19.sp),
                    color: AppColors.inputFocused,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            Text(
              'Preferences',
              style: AppTextStyles.button.copyWith(fontSize: 15.sp),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Obx(
              () => _PreferenceTile(
                title: 'Push Alerts',
                subtitle: 'Receive updates for saved places and events.',
                value: controller.pushAlertsEnabled.value,
                onChanged: controller.setPushAlerts,
              ),
            ),
            Obx(
              () => _PreferenceTile(
                title: 'Location Access',
                subtitle: 'Enable accurate nearby recommendations.',
                value: controller.locationAccessEnabled.value,
                onChanged: controller.setLocationAccess,
              ),
            ),
            Obx(
              () => _PreferenceTile(
                title: 'Personalized Suggestions',
                subtitle: 'Tailor suggestions based on your activity.',
                value: controller.personalizedSuggestionsEnabled.value,
                onChanged: controller.setPersonalizedSuggestions,
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(
              'Travel Mode',
              style: AppTextStyles.button.copyWith(fontSize: 15.sp),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Obx(
              () => Row(
                children: <Widget>[
                  _ModeChip(
                    label: 'Relaxed',
                    active: controller.selectedTravelMode.value == 'Relaxed',
                    onTap: () => controller.selectTravelMode('Relaxed'),
                  ),
                  SizedBox(width: AppSpacing.xs.w),
                  _ModeChip(
                    label: 'Balanced',
                    active: controller.selectedTravelMode.value == 'Balanced',
                    onTap: () => controller.selectTravelMode('Balanced'),
                  ),
                  SizedBox(width: AppSpacing.xs.w),
                  _ModeChip(
                    label: 'Fast',
                    active: controller.selectedTravelMode.value == 'Fast',
                    onTap: () => controller.selectTravelMode('Fast'),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            _UserCard(
              icon: Icons.verified_user_rounded,
              title: 'Current Role',
              subtitle: 'User access is active.',
            ),
            _UserCard(
              icon: Icons.logout_rounded,
              title: 'Sign out',
              subtitle: 'Return to login screen.',
              trailing: TextButton(
                onPressed: controller.logout,
                child: const Text('Log out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.sm.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.inputBorder.withValues(alpha: 0.78),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: AppTextStyles.button),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.body.copyWith(fontSize: 12.5.sp),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.accent,
              activeTrackColor: AppColors.accent.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          height: 40.h,
          decoration: BoxDecoration(
            color: active
                ? AppColors.accent.withValues(alpha: 0.16)
                : Colors.white,
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(
              color: active
                  ? AppColors.accent
                  : AppColors.inputBorder.withValues(alpha: 0.75),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.button.copyWith(
                fontSize: 12.8.sp,
                color: active
                    ? AppColors.inputFocused
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md.h),
      child: Card(
        child: Container(
          constraints: BoxConstraints(minHeight: 92.h),
          padding: EdgeInsets.all(AppSpacing.md.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: AppColors.inputFocused),
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: AppTextStyles.button),
                    SizedBox(height: 4.h),
                    Text(subtitle, style: AppTextStyles.body),
                  ],
                ),
              ),
              if (trailing case final Widget t) t,
            ],
          ),
        ),
      ),
    );
  }
}
