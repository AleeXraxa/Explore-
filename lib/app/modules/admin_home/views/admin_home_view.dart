import 'dart:async';
import 'dart:convert';

import 'package:city_guide_app/app/data/models/admin_listing_model.dart';
import 'package:city_guide_app/app/data/models/admin_review_model.dart';
import 'package:city_guide_app/app/data/models/city_model.dart';
import 'package:city_guide_app/app/modules/admin_home/controllers/admin_home_controller.dart';
import 'package:city_guide_app/app/routes/app_routes.dart';
import 'package:city_guide_app/app/shared/widgets/premium_bottom_nav_bar.dart';
import 'package:city_guide_app/app/shared/widgets/custom_text_field.dart';
import 'package:city_guide_app/app/shared/widgets/primary_button.dart';
import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class AdminHomeView extends GetView<AdminHomeController> {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    const List<NavItemData> navItems = <NavItemData>[
      NavItemData(label: 'Dashboard', icon: Icons.dashboard_rounded),
      NavItemData(label: 'Listings', icon: Icons.storefront_rounded),
      NavItemData(label: 'Reviews', icon: Icons.reviews_rounded),
      NavItemData(label: 'Profile', icon: Icons.admin_panel_settings_rounded),
    ];

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.selectedTabIndex.value,
          children: <Widget>[
            _DashboardTab(controller: controller),
            _ListingsTab(controller: controller),
            _ReviewsTab(controller: controller),
            _ProfileTab(controller: controller),
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

class _LocationSuggestion {
  const _LocationSuggestion({
    required this.title,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
  });

  final String title;
  final String subtitle;
  final double latitude;
  final double longitude;
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({required this.controller});

  final AdminHomeController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _DashboardHeader(controller: controller),
            SizedBox(height: AppSpacing.lg.h),
            Text(
              'Today at a glance',
              style: AppTextStyles.button.copyWith(fontSize: 15.sp),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Obx(
              () => Row(
                children: <Widget>[
                  Expanded(
                    child: _MetricCard(
                      title: 'Pending',
                      value: controller.pendingListingsCount.toString(),
                      icon: Icons.pending_actions_rounded,
                      tone: _MetricTone.warning,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: _MetricCard(
                      title: 'Live Listings',
                      value: controller.approvedListingsCount.toString(),
                      icon: Icons.storefront_rounded,
                      tone: _MetricTone.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Obx(
              () => Row(
                children: <Widget>[
                  Expanded(
                    child: _MetricCard(
                      title: 'Flagged Reviews',
                      value: controller.flaggedReviewsCount.toString(),
                      icon: Icons.flag_rounded,
                      tone: _MetricTone.danger,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: _MetricCard(
                      title: 'Resolved',
                      value: controller.resolvedReviewsCount.toString(),
                      icon: Icons.task_alt_rounded,
                      tone: _MetricTone.success,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            Text(
              'Quick actions',
              style: AppTextStyles.button.copyWith(fontSize: 15.sp),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Obx(
              () => _AdminCard(
                icon: Icons.approval_rounded,
                title: 'Review Pending Listings',
                subtitle:
                    '${controller.pendingListingsCount} listings waiting moderation.',
              ),
            ),
            const _AdminCard(
              icon: Icons.campaign_rounded,
              title: 'Broadcast Notice',
              subtitle: 'Send updates and announcements to all users.',
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(
              'Recent activity',
              style: AppTextStyles.button.copyWith(fontSize: 15.sp),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Obx(() {
              final List<DashboardActivityItem> activities =
                  controller.dashboardRecentActivities;
              if (activities.isEmpty) {
                return _ActivityTile(
                  title: 'No activity yet',
                  subtitle: 'Recent moderation actions will appear here.',
                );
              }
              return Column(
                children: activities
                    .map(
                      (DashboardActivityItem item) => _ActivityTile(
                        title: item.title,
                        subtitle: item.subtitle,
                      ),
                    )
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

enum _MetricTone { primary, success, warning, danger }

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.controller});

  final AdminHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.accent.withValues(alpha: 0.2),
            AppColors.accent.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.34)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.15),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AppColors.inputFocused,
                  size: 25.sp,
                ),
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      controller.title,
                      style: AppTextStyles.title.copyWith(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      controller.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12.8.sp,
                        color: AppColors.textPrimary.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm.w,
                  vertical: AppSpacing.xs.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.76),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.24),
                  ),
                ),
                child: Text(
                  'Today',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inputFocused,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          Obx(
            () => Row(
              children: <Widget>[
                Expanded(
                  child: _HeaderPill(
                    icon: Icons.verified_rounded,
                    label: controller.dashboardSystemLabel,
                  ),
                ),
                _HeaderPillGap(),
                Expanded(
                  child: _HeaderPill(
                    icon: Icons.pending_actions_rounded,
                    label: controller.dashboardQueueLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPillGap extends StatelessWidget {
  const _HeaderPillGap();

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: AppSpacing.xs);
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w,
        vertical: AppSpacing.xs.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 14.sp, color: AppColors.inputFocused),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 11.8.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.tone,
  });

  final String title;
  final String value;
  final IconData icon;
  final _MetricTone tone;

  @override
  Widget build(BuildContext context) {
    final ({Color bg, Color fg}) palette = switch (tone) {
      _MetricTone.primary => (
        bg: AppColors.accent.withValues(alpha: 0.14),
        fg: AppColors.inputFocused,
      ),
      _MetricTone.success => (
        bg: const Color(0xFF1F9D72).withValues(alpha: 0.14),
        fg: const Color(0xFF1F9D72),
      ),
      _MetricTone.warning => (
        bg: const Color(0xFFC98B2D).withValues(alpha: 0.15),
        fg: const Color(0xFFC98B2D),
      ),
      _MetricTone.danger => (
        bg: AppColors.error.withValues(alpha: 0.12),
        fg: AppColors.error,
      ),
    };

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.inputBorder.withValues(alpha: 0.75),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: palette.bg,
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(icon, size: 16.sp, color: palette.fg),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(title, style: AppTextStyles.body.copyWith(fontSize: 12.5.sp)),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.inputBorder.withValues(alpha: 0.75),
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: AppTextStyles.button.copyWith(fontSize: 13.8.sp),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.body.copyWith(fontSize: 12.4.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingsTab extends StatelessWidget {
  const _ListingsTab({required this.controller});

  final AdminHomeController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Listings Moderation',
                        style: AppTextStyles.title.copyWith(
                          fontSize: 27.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Text(
                        'Search, filter, and approve city listings in real time.',
                        style: AppTextStyles.body.copyWith(fontSize: 13.sp),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext sheetContext) =>
                              ListingFormSheet(controller: controller),
                        );
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Listing'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.inputFocused,
                        visualDensity: const VisualDensity(
                          horizontal: -1,
                          vertical: -1,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs.h),
                    OutlinedButton.icon(
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext sheetContext) =>
                              _CityManagementSheet(controller: controller),
                        );
                      },
                      icon: const Icon(Icons.location_city_rounded),
                      label: const Text('Cities'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md.h),
            _ListingsSummaryRow(controller: controller),
            SizedBox(height: AppSpacing.md.h),
            _ListingsSearchField(controller: controller),
            SizedBox(height: AppSpacing.sm.h),
            _ListingsFiltersRow(controller: controller),
            SizedBox(height: AppSpacing.md.h),
            Expanded(
              child: Obx(() {
                if (controller.isListingsLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.listingsError.value.isNotEmpty) {
                  return _ListingsErrorState(controller: controller);
                }

                final List<AdminListingModel> visibleListings =
                    controller.filteredListings;

                if (visibleListings.isEmpty) {
                  return _EmptyListingsState(controller: controller);
                }

                return ListView.separated(
                  itemCount: visibleListings.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      SizedBox(height: AppSpacing.sm.h),
                  itemBuilder: (BuildContext context, int index) {
                    final AdminListingModel listing = visibleListings[index];
                    return _ListingCard(
                      listing: listing,
                      onViewDetails: () {
                        CityModel? city;
                        for (final CityModel item in controller.adminCities) {
                          if (item.name.trim().toLowerCase() ==
                              listing.city.trim().toLowerCase()) {
                            city = item;
                            break;
                          }
                        }
                        Get.toNamed(
                          AppRoutes.placeDetails,
                          arguments: <String, dynamic>{
                            'listingId': listing.id,
                            'title': listing.name,
                            'category': listing.category,
                            'rating': listing.displayRating.toStringAsFixed(1),
                            'ratingsCount': listing.ratingsCount,
                            'distance': listing.address,
                            'highlight': listing.openingHours,
                            'website': listing.website,
                            'imageUrl': listing.imageUrl,
                            'description': listing.description,
                            'contactInfo': listing.contactInfo,
                            'openingHours': listing.openingHours,
                            'address': listing.address,
                            'latitude': listing.latitude != 0
                                ? listing.latitude
                                : (city?.latitude ?? 0),
                            'longitude': listing.longitude != 0
                                ? listing.longitude
                                : (city?.longitude ?? 0),
                            'readOnly': true,
                          },
                        );
                      },
                      onEdit: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext sheetContext) =>
                              ListingFormSheet(
                                controller: controller,
                                initial: listing,
                              ),
                        );
                      },
                      onApprove: listing.isPending
                          ? () => controller.approveListing(listing)
                          : null,
                      onReject: listing.isPending
                          ? () => controller.rejectListing(listing)
                          : null,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingsSummaryRow extends StatelessWidget {
  const _ListingsSummaryRow({required this.controller});

  final AdminHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: <Widget>[
          Expanded(
            child: _SummaryPill(
              label: 'Total',
              value: controller.totalListingsCount.toString(),
              color: AppColors.inputFocused,
            ),
          ),
          SizedBox(width: AppSpacing.xs.w),
          Expanded(
            child: _SummaryPill(
              label: 'Pending',
              value: controller.pendingListingsCount.toString(),
              color: const Color(0xFFC98B2D),
            ),
          ),
          SizedBox(width: AppSpacing.xs.w),
          Expanded(
            child: _SummaryPill(
              label: 'Approved',
              value: controller.approvedListingsCount.toString(),
              color: const Color(0xFF1F9D72),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 11.4.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingsSearchField extends StatelessWidget {
  const _ListingsSearchField({required this.controller});

  final AdminHomeController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.listingSearchController,
      onChanged: controller.onListingSearchChanged,
      style: AppTextStyles.fieldText.copyWith(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: 'Search by listing, city, or category',
        hintStyle: AppTextStyles.body.copyWith(fontSize: 13.sp),
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.sm.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13.r),
          borderSide: BorderSide(
            color: AppColors.inputBorder.withValues(alpha: 0.9),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13.r),
          borderSide: BorderSide(
            color: AppColors.inputBorder.withValues(alpha: 0.9),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13.r),
          borderSide: const BorderSide(color: AppColors.inputFocused),
        ),
      ),
    );
  }
}

class _ListingsFiltersRow extends StatelessWidget {
  const _ListingsFiltersRow({required this.controller});

  final AdminHomeController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34.h,
      child: Obx(() {
        final String currentFilter = controller.listingStatusFilter.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.listingFilters.length,
          separatorBuilder: (BuildContext context, int index) =>
              SizedBox(width: AppSpacing.xs.w),
          itemBuilder: (BuildContext context, int index) {
            final String value = controller.listingFilters[index];
            final bool selected = currentFilter == value;
            return ChoiceChip(
              label: Text(value.capitalizeFirst ?? value),
              selected: selected,
              onSelected: (bool selected) =>
                  controller.onListingFilterChanged(value),
              labelStyle: AppTextStyles.body.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: selected
                    ? AppColors.inputFocused
                    : AppColors.textSecondary,
                height: 1.1,
              ),
              side: BorderSide(
                color: selected
                    ? AppColors.inputFocused.withValues(alpha: 0.28)
                    : AppColors.inputBorder.withValues(alpha: 0.8),
              ),
              selectedColor: AppColors.accent.withValues(alpha: 0.14),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              showCheckmark: false,
              visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
            );
          },
        );
      }),
    );
  }
}

class _ListingsErrorState extends StatelessWidget {
  const _ListingsErrorState({required this.controller});

  final AdminHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 24.sp,
          ),
          SizedBox(height: AppSpacing.xs.h),
          Text(
            controller.listingsError.value,
            style: AppTextStyles.body.copyWith(
              fontSize: 13.sp,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          FilledButton(
            onPressed: controller.subscribeListings,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyListingsState extends StatelessWidget {
  const _EmptyListingsState({required this.controller});

  final AdminHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.storefront_outlined,
            color: AppColors.textSecondary,
            size: 26.sp,
          ),
          SizedBox(height: AppSpacing.xs.h),
          Text(
            'No listings found',
            style: AppTextStyles.button.copyWith(fontSize: 14.sp),
          ),
          SizedBox(height: 2.h),
          Text(
            'Try another filter or search query.',
            style: AppTextStyles.body.copyWith(fontSize: 12.6.sp),
          ),
          SizedBox(height: AppSpacing.sm.h),
          FilledButton.icon(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext sheetContext) =>
                    ListingFormSheet(controller: controller),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Listing'),
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.listing,
    required this.onViewDetails,
    required this.onEdit,
    this.onApprove,
    this.onReject,
  });

  final AdminListingModel listing;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final ({Color bg, Color fg}) statusPalette = _statusPalette(listing.status);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.inputBorder.withValues(alpha: 0.82),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ListingImage(imageUrl: listing.imageUrl),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      listing.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.button.copyWith(fontSize: 14.6.sp),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${listing.city} • ${listing.category}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(fontSize: 12.4.sp),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusPalette.bg,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  listing.status.capitalizeFirst ?? listing.status,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 11.4.sp,
                    fontWeight: FontWeight.w700,
                    color: statusPalette.fg,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            listing.description.isEmpty
                ? 'No description available'
                : listing.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(fontSize: 12.8.sp),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Row(
            children: <Widget>[
              Icon(
                Icons.star_rounded,
                size: 16.sp,
                color: const Color(0xFFC98B2D),
              ),
              SizedBox(width: 4.w),
              Text(
                listing.displayRating.toStringAsFixed(1),
                style: AppTextStyles.body.copyWith(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                '(${listing.ratingsCount})',
                style: AppTextStyles.body.copyWith(fontSize: 11.6.sp),
              ),
              const Spacer(),
              TextButton(
                onPressed: onViewDetails,
                child: const Text('View details'),
              ),
              TextButton(onPressed: onEdit, child: const Text('Edit')),
            ],
          ),
          if (listing.isPending) ...<Widget>[
            SizedBox(height: AppSpacing.xs.h),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                SizedBox(width: AppSpacing.xs.w),
                Expanded(
                  child: FilledButton(
                    onPressed: onApprove,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1F9D72),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ListingImage extends StatelessWidget {
  const _ListingImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 64.w,
        height: 64.w,
        color: AppColors.accent.withValues(alpha: 0.12),
        child: imageUrl.isEmpty
            ? Icon(
                Icons.image_outlined,
                color: AppColors.inputFocused,
                size: 20.sp,
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) => Icon(
                      Icons.broken_image_rounded,
                      color: AppColors.textSecondary,
                      size: 20.sp,
                    ),
              ),
      ),
    );
  }
}

class ListingFormSheet extends StatefulWidget {
  const ListingFormSheet({super.key, required this.controller, this.initial});

  final AdminHomeController controller;
  final AdminListingModel? initial;

  @override
  State<ListingFormSheet> createState() => _ListingFormSheetState();
}

class _ListingFormSheetState extends State<ListingFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactController;
  late final TextEditingController _hoursController;
  late final TextEditingController _ratingController;

  late final FocusNode _nameFocus;
  late final FocusNode _categoryFocus;
  late final FocusNode _descriptionFocus;
  late final FocusNode _addressFocus;
  late final FocusNode _contactFocus;
  late final FocusNode _hoursFieldFocus;
  late final FocusNode _ratingFocus;

  String? _nameError;
  String? _cityError;
  String? _categoryError;
  String? _descriptionError;
  String? _addressError;
  String? _contactError;
  String? _hoursError;
  String? _ratingError;
  bool _isSubmitting = false;
  String? _selectedCityName;
  double _selectedLatitude = 0;
  double _selectedLongitude = 0;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final AdminListingModel? initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _selectedCityName = initial?.city;
    _categoryController = TextEditingController(text: initial?.category ?? '');
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );
    _addressController = TextEditingController(text: initial?.address ?? '');
    _contactController = TextEditingController(
      text: initial?.contactInfo ?? '',
    );
    _hoursController = TextEditingController(text: initial?.openingHours ?? '');
    _ratingController = TextEditingController(
      text: initial != null && initial.rating > 0
          ? initial.rating.toStringAsFixed(1)
          : '',
    );
    _selectedLatitude = initial?.latitude ?? 0;
    _selectedLongitude = initial?.longitude ?? 0;

    _nameFocus = FocusNode();
    _categoryFocus = FocusNode();
    _descriptionFocus = FocusNode();
    _addressFocus = FocusNode();
    _contactFocus = FocusNode();
    _hoursFieldFocus = FocusNode();
    _ratingFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _hoursController.dispose();
    _ratingController.dispose();
    _nameFocus.dispose();
    _categoryFocus.dispose();
    _descriptionFocus.dispose();
    _addressFocus.dispose();
    _contactFocus.dispose();
    _hoursFieldFocus.dispose();
    _ratingFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty
          ? 'Name is required'
          : null;
      _cityError =
          (_selectedCityName == null || _selectedCityName!.trim().isEmpty)
          ? 'City is required'
          : null;
      _categoryError = _categoryController.text.trim().isEmpty
          ? 'Category is required'
          : null;
      _descriptionError = _descriptionController.text.trim().isEmpty
          ? 'Description is required'
          : null;
      _addressError = _addressController.text.trim().isEmpty
          ? 'Address is required'
          : null;
      _contactError = _contactController.text.trim().isEmpty
          ? 'Contact is required'
          : null;
      _hoursError = _hoursController.text.trim().isEmpty
          ? 'Opening hours required'
          : null;
      _ratingError = null;
    });

    final String ratingRaw = _ratingController.text.trim();
    if (ratingRaw.isNotEmpty) {
      final double? rating = double.tryParse(ratingRaw);
      if (rating == null || rating < 0 || rating > 5) {
        setState(() => _ratingError = 'Rating must be between 0 and 5');
      }
    }

    return _nameError == null &&
        _cityError == null &&
        _categoryError == null &&
        _descriptionError == null &&
        _addressError == null &&
        _contactError == null &&
        _hoursError == null &&
        _ratingError == null;
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_validate()) {
      return;
    }
    setState(() => _isSubmitting = true);

    final double rating = double.tryParse(_ratingController.text.trim()) ?? 0;
    final bool success = _isEdit
        ? await widget.controller.updateListing(
            listingId: widget.initial!.id,
            name: _nameController.text,
            city: _selectedCityName ?? '',
            category: _categoryController.text,
            description: _descriptionController.text,
            imageUrl: '',
            address: _addressController.text,
            contactInfo: _contactController.text,
            openingHours: _hoursController.text,
            website: '',
            latitude: _selectedLatitude,
            longitude: _selectedLongitude,
            rating: rating,
          )
        : await widget.controller.createListing(
            name: _nameController.text,
            city: _selectedCityName ?? '',
            category: _categoryController.text,
            description: _descriptionController.text,
            imageUrl: '',
            address: _addressController.text,
            contactInfo: _contactController.text,
            openingHours: _hoursController.text,
            website: '',
            latitude: _selectedLatitude,
            longitude: _selectedLongitude,
            rating: rating,
          );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _pickOpeningHours() async {
    final TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (start == null || !mounted) return;

    final TimeOfDay? end = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 22, minute: 0),
    );
    if (end == null || !mounted) return;

    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    _hoursController.text =
        '${localizations.formatTimeOfDay(start)} - ${localizations.formatTimeOfDay(end)}';
    setState(() => _hoursError = null);
  }

  Future<void> _openLocationPicker() async {
    CityModel? selectedCity;
    for (final CityModel city in widget.controller.adminCities) {
      if (city.name == _selectedCityName) {
        selectedCity = city;
        break;
      }
    }
    final double initialLat = _selectedLatitude != 0
        ? _selectedLatitude
        : (selectedCity?.latitude ?? 33.6844);
    final double initialLng = _selectedLongitude != 0
        ? _selectedLongitude
        : (selectedCity?.longitude ?? 73.0479);
    final TextEditingController searchController = TextEditingController();
    Timer? searchDebounce;
    bool isSearching = false;
    String? searchError;
    List<_LocationSuggestion> suggestions = <_LocationSuggestion>[];

    Future<void> performSearch(
      String query,
      StateSetter setSheetState,
      MapController mapController,
      void Function(LatLng) updateMarker,
    ) async {
      final String trimmed = query.trim();
      if (trimmed.isEmpty) {
        setSheetState(() {
          isSearching = false;
          searchError = null;
          suggestions = <_LocationSuggestion>[];
        });
        return;
      }

      setSheetState(() {
        isSearching = true;
        searchError = null;
      });

      try {
        final Uri uri = Uri.https(
          'nominatim.openstreetmap.org',
          '/search',
          <String, String>{
            'q': trimmed,
            'format': 'jsonv2',
            'addressdetails': '1',
            'limit': '8',
          },
        );
        final http.Response response = await http.get(
          uri,
          headers: <String, String>{
            'User-Agent': 'city_guide_app/1.0 (admin-location-search)',
            'Accept-Language': 'en',
          },
        );
        if (response.statusCode != 200) {
          setSheetState(() {
            isSearching = false;
            suggestions = <_LocationSuggestion>[];
            searchError = 'Unable to search this location.';
          });
          return;
        }

        final List<dynamic> payload =
            jsonDecode(response.body) as List<dynamic>;
        final List<_LocationSuggestion> result = payload
            .map((dynamic item) {
              final Map<String, dynamic> data = item as Map<String, dynamic>;
              final String displayName =
                  (data['display_name'] as String?)?.trim() ?? '';
              final List<String> parts = displayName.split(',');
              final String title = parts.isNotEmpty
                  ? parts.first.trim()
                  : (displayName.isEmpty ? 'Unnamed place' : displayName);
              final String subtitle = parts.length > 1
                  ? parts.skip(1).join(',').trim()
                  : 'Location result';
              final double? lat = double.tryParse(
                (data['lat'] ?? '').toString(),
              );
              final double? lon = double.tryParse(
                (data['lon'] ?? '').toString(),
              );
              if (lat == null || lon == null) return null;
              return _LocationSuggestion(
                title: title,
                subtitle: subtitle,
                latitude: lat,
                longitude: lon,
              );
            })
            .whereType<_LocationSuggestion>()
            .toList();

        setSheetState(() {
          isSearching = false;
          suggestions = result;
          searchError = result.isEmpty ? 'Location not found.' : null;
        });

        if (result.isNotEmpty) {
          final LatLng point = LatLng(
            result.first.latitude,
            result.first.longitude,
          );
          updateMarker(point);
          mapController.move(point, 14);
        }
      } catch (_) {
        setSheetState(() {
          isSearching = false;
          suggestions = <_LocationSuggestion>[];
          searchError = 'Unable to search this location.';
        });
      }
    }

    final LatLng? picked = await showModalBottomSheet<LatLng>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        LatLng marker = LatLng(initialLat, initialLng);
        final MapController mapController = MapController();
        return SizedBox(
          height: 0.72.sh,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setSheetState) {
              return Padding(
                padding: EdgeInsets.all(AppSpacing.md.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Select Listing Location',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs.h),
                    Text(
                      'Search and tap a result, or tap map to place marker.',
                      style: AppTextStyles.body.copyWith(fontSize: 12.5.sp),
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    TextField(
                      controller: searchController,
                      onChanged: (String value) {
                        searchDebounce?.cancel();
                        searchDebounce = Timer(
                          const Duration(milliseconds: 350),
                          () => performSearch(
                            value,
                            setSheetState,
                            mapController,
                            (LatLng point) {
                              setSheetState(() => marker = point);
                            },
                          ),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Search location',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: isSearching
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: Padding(
                                  padding: EdgeInsets.all(12.w),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : (searchController.text.trim().isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        searchController.clear();
                                        setSheetState(() {
                                          isSearching = false;
                                          searchError = null;
                                          suggestions = <_LocationSuggestion>[];
                                        });
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                    )
                                  : null),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    if (suggestions.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: AppSpacing.xs.h),
                        constraints: BoxConstraints(maxHeight: 180.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.inputBorder.withValues(alpha: 0.8),
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: suggestions.length,
                          separatorBuilder:
                              (BuildContext _, int itemIndex) => Divider(
                            height: 1,
                            color: AppColors.inputBorder.withValues(
                              alpha: 0.45,
                            ),
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final _LocationSuggestion suggestion =
                                suggestions[index];
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.location_on_outlined,
                                color: AppColors.inputFocused,
                                size: 18.sp,
                              ),
                              title: Text(
                                suggestion.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.8.sp,
                                ),
                              ),
                              subtitle: Text(
                                suggestion.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 11.6.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              onTap: () {
                                final LatLng point = LatLng(
                                  suggestion.latitude,
                                  suggestion.longitude,
                                );
                                setSheetState(() {
                                  marker = point;
                                  suggestions = <_LocationSuggestion>[];
                                  searchError = null;
                                  searchController.text = suggestion.title;
                                });
                                mapController.move(point, 15);
                              },
                            );
                          },
                        ),
                      ),
                    if (suggestions.isNotEmpty)
                      SizedBox(height: AppSpacing.xs.h),
                    if (searchError != null)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          searchError!,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 11.8.sp,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    SizedBox(height: AppSpacing.sm.h),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: FlutterMap(
                          mapController: mapController,
                          options: MapOptions(
                            initialCenter: marker,
                            initialZoom: 13,
                            onTap: (TapPosition tapPosition, LatLng point) {
                              setSheetState(() => marker = point);
                            },
                          ),
                          children: <Widget>[
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'city_guide_app',
                            ),
                            MarkerLayer(
                              markers: <Marker>[
                                Marker(
                                  point: marker,
                                  width: 42.w,
                                  height: 42.w,
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    color: AppColors.inputFocused,
                                    size: 34.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: AppSpacing.xs.w),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.of(context).pop(marker),
                            child: const Text('Use Location'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
    searchDebounce?.cancel();
    searchController.dispose();

    if (picked != null) {
      setState(() {
        _selectedLatitude = picked.latitude;
        _selectedLongitude = picked.longitude;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.92.sh),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.inputBorder,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md.h),
                Text(
                  _isEdit ? 'Edit listing' : 'Add new listing',
                  style: AppTextStyles.title.copyWith(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppSpacing.xs.h),
                Text(
                  _isEdit
                      ? 'Update listing details and keep data quality high.'
                      : 'Create a new listing for moderation and city discovery.',
                  style: AppTextStyles.body.copyWith(fontSize: 13.sp),
                ),
                SizedBox(height: AppSpacing.md.h),
                CustomTextField(
                  label: 'Listing Name',
                  hintText: 'Skyline Rooftop',
                  prefixIcon: Icons.storefront_outlined,
                  controller: _nameController,
                  focusNode: _nameFocus,
                  errorText: _nameError,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _categoryFocus.requestFocus(),
                ),
                SizedBox(height: AppSpacing.sm.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      initialValue:
                          (_selectedCityName != null &&
                              widget.controller.adminCities.any(
                                (CityModel city) =>
                                    city.name == _selectedCityName,
                              ))
                          ? _selectedCityName
                          : null,
                      items: widget.controller.adminCities
                          .map(
                            (CityModel city) => DropdownMenuItem<String>(
                              value: city.name,
                              child: Text('${city.name}, ${city.country}'),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCityName = value;
                          _cityError = null;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'City',
                        hintText: 'Select city',
                        prefixIcon: const Icon(Icons.location_city_outlined),
                        errorText: _cityError,
                      ),
                    ),
                    if (widget.controller.adminCities.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h, left: 2.w),
                        child: Text(
                          'No cities found. Add cities from City Management first.',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 11.5.sp,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    SizedBox(height: AppSpacing.sm.h),
                    CustomTextField(
                      label: 'Category',
                      hintText: 'Restaurant',
                      prefixIcon: Icons.category_outlined,
                      controller: _categoryController,
                      focusNode: _categoryFocus,
                      errorText: _categoryError,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _descriptionFocus.requestFocus(),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm.h),
                CustomTextField(
                  label: 'Description',
                  hintText: 'Briefly describe this listing',
                  prefixIcon: Icons.notes_rounded,
                  controller: _descriptionController,
                  focusNode: _descriptionFocus,
                  errorText: _descriptionError,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _addressFocus.requestFocus(),
                ),
                SizedBox(height: AppSpacing.sm.h),
                CustomTextField(
                  label: 'Address',
                  hintText: 'Street, area',
                  prefixIcon: Icons.pin_drop_outlined,
                  controller: _addressController,
                  focusNode: _addressFocus,
                  errorText: _addressError,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _contactFocus.requestFocus(),
                ),
                SizedBox(height: AppSpacing.sm.h),
                CustomTextField(
                  label: 'Contact Info',
                  hintText: '+92 300 0000000',
                  prefixIcon: Icons.call_outlined,
                  controller: _contactController,
                  focusNode: _contactFocus,
                  errorText: _contactError,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _ratingFocus.requestFocus(),
                ),
                SizedBox(height: AppSpacing.sm.h),
                InkWell(
                  onTap: _pickOpeningHours,
                  borderRadius: BorderRadius.circular(12.r),
                  child: IgnorePointer(
                    child: CustomTextField(
                      label: 'Opening Hours',
                      hintText: 'Tap to select time range',
                      prefixIcon: Icons.access_time_rounded,
                      controller: _hoursController,
                      focusNode: _hoursFieldFocus,
                      errorText: _hoursError,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSpacing.sm.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.inputBorder.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _selectedLatitude == 0 && _selectedLongitude == 0
                              ? 'No exact location selected'
                              : 'Location selected (${_selectedLatitude.toStringAsFixed(4)}, ${_selectedLongitude.toStringAsFixed(4)})',
                          style: AppTextStyles.body.copyWith(fontSize: 12.4.sp),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _openLocationPicker,
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Select on Map'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CustomTextField(
                        label: 'Rating',
                        hintText: '4.5',
                        prefixIcon: Icons.star_outline_rounded,
                        controller: _ratingController,
                        focusNode: _ratingFocus,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        errorText: _ratingError,
                        onSubmitted: (_) => _submit(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg.h),
                PrimaryButton(
                  text: _isEdit ? 'Save Changes' : 'Create Listing',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
                SizedBox(height: AppSpacing.sm.h),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CityManagementSheet extends StatelessWidget {
  const _CityManagementSheet({required this.controller});

  final AdminHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.9.sh),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 46.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.inputBorder,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md.h),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'City Management',
                          style: AppTextStyles.title.copyWith(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'Manage city data available for user selection.',
                          style: AppTextStyles.body.copyWith(fontSize: 13.sp),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext sheetContext) =>
                            _CityFormSheet(controller: controller),
                      );
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add'),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md.h),
              TextField(
                controller: controller.citySearchController,
                onChanged: controller.onCitySearchChanged,
                style: AppTextStyles.fieldText.copyWith(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Search city or country',
                  hintStyle: AppTextStyles.body.copyWith(fontSize: 13.sp),
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md.w,
                    vertical: AppSpacing.sm.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.r),
                    borderSide: BorderSide(
                      color: AppColors.inputBorder.withValues(alpha: 0.9),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.r),
                    borderSide: BorderSide(
                      color: AppColors.inputBorder.withValues(alpha: 0.9),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.r),
                    borderSide: const BorderSide(color: AppColors.inputFocused),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md.h),
              Expanded(
                child: Obx(() {
                  if (controller.isCitiesLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.citiesError.value.isNotEmpty) {
                    return Center(
                      child: Text(
                        controller.citiesError.value,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    );
                  }
                  final Map<String, int> listingCounts = <String, int>{};
                  final Map<String, String> listingLabels = <String, String>{};
                  for (final listing in controller.listings) {
                    final String cityName = listing.city.trim();
                    if (cityName.isEmpty) continue;
                    final String key = cityName.toLowerCase();
                    listingCounts[key] = (listingCounts[key] ?? 0) + 1;
                    listingLabels[key] = cityName;
                  }

                  final Map<String, CityModel> cityByKey = <String, CityModel>{
                    for (final CityModel city in controller.adminCities)
                      city.name.trim().toLowerCase(): city,
                  };

                  final Set<String> mergedKeys = <String>{
                    ...cityByKey.keys,
                    ...listingCounts.keys,
                  };

                  final String query = controller.citySearchQuery.value
                      .trim()
                      .toLowerCase();
                  final List<_MergedCityItem> cities =
                      mergedKeys
                          .map((key) {
                            final CityModel? city = cityByKey[key];
                            final String name =
                                city?.name ??
                                (listingLabels[key] ?? 'Unknown City');
                            final int count = listingCounts[key] ?? 0;
                            return _MergedCityItem(
                              city: city,
                              displayName: name,
                              listingCount: count,
                            );
                          })
                          .where((_MergedCityItem item) {
                            if (query.isEmpty) return true;
                            final String country =
                                item.city?.country.toLowerCase() ?? '';
                            return item.displayName.toLowerCase().contains(
                                  query,
                                ) ||
                                country.contains(query);
                          })
                          .toList()
                        ..sort(
                          (_MergedCityItem a, _MergedCityItem b) =>
                              b.listingCount.compareTo(a.listingCount),
                        );

                  if (cities.isEmpty) {
                    return Center(
                      child: Text(
                        'No cities found.',
                        style: AppTextStyles.body,
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: cities.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        SizedBox(height: AppSpacing.sm.h),
                    itemBuilder: (BuildContext context, int index) {
                      final _MergedCityItem item = cities[index];
                      final CityModel? city = item.city;
                      return Container(
                        padding: EdgeInsets.all(AppSpacing.md.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: AppColors.inputBorder.withValues(
                              alpha: 0.78,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.location_city_rounded,
                                color: AppColors.inputFocused,
                                size: 18.sp,
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item.displayName,
                                    style: AppTextStyles.button.copyWith(
                                      fontSize: 14.5.sp,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    city?.country ?? 'From listings',
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 12.5.sp,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    city?.description ??
                                        'This city appears in listings but is not configured in city directory yet.',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 12.2.sp,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        999.r,
                                      ),
                                    ),
                                    child: Text(
                                      '${item.listingCount} listings',
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 11.2.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.inputFocused,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: <Widget>[
                                if (city != null) ...<Widget>[
                                  IconButton(
                                    onPressed: () {
                                      showModalBottomSheet<void>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (BuildContext sheetContext) =>
                                            _CityFormSheet(
                                              controller: controller,
                                              initial: city,
                                            ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      size: 18.sp,
                                    ),
                                    color: AppColors.inputFocused,
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      final bool shouldDelete =
                                          await showDialog<bool>(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                AlertDialog(
                                                  title: const Text(
                                                    'Delete city?',
                                                  ),
                                                  content: Text(
                                                    'Remove ${city.name} from available cities?',
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    FilledButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        'Delete',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          ) ??
                                          false;
                                      if (shouldDelete) {
                                        await controller.deleteCity(city);
                                      }
                                    },
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18.sp,
                                    ),
                                    color: AppColors.error,
                                  ),
                                ] else ...<Widget>[
                                  TextButton(
                                    onPressed: () {
                                      showModalBottomSheet<void>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (BuildContext sheetContext) =>
                                            _CityFormSheet(
                                              controller: controller,
                                              prefillName: item.displayName,
                                              prefillCountry: 'Pakistan',
                                            ),
                                      );
                                    },
                                    child: const Text('Add'),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MergedCityItem {
  const _MergedCityItem({
    required this.city,
    required this.displayName,
    required this.listingCount,
  });

  final CityModel? city;
  final String displayName;
  final int listingCount;
}

class _CityFormSheet extends StatefulWidget {
  const _CityFormSheet({
    required this.controller,
    this.initial,
    this.prefillName,
    this.prefillCountry,
  });

  final AdminHomeController controller;
  final CityModel? initial;
  final String? prefillName;
  final String? prefillCountry;

  @override
  State<_CityFormSheet> createState() => _CityFormSheetState();
}

class _CityFormSheetState extends State<_CityFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _countryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final FocusNode _nameFocus;
  late final FocusNode _countryFocus;
  late final FocusNode _descriptionFocus;
  late final FocusNode _latitudeFocus;
  late final FocusNode _longitudeFocus;

  String? _nameError;
  String? _countryError;
  String? _descriptionError;
  String? _latitudeError;
  String? _longitudeError;
  bool _isSubmitting = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final CityModel? initial = widget.initial;
    _nameController = TextEditingController(
      text: initial?.name ?? (widget.prefillName ?? ''),
    );
    _countryController = TextEditingController(
      text: initial?.country ?? (widget.prefillCountry ?? ''),
    );
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );
    _latitudeController = TextEditingController(
      text: initial != null ? initial.latitude.toString() : '',
    );
    _longitudeController = TextEditingController(
      text: initial != null ? initial.longitude.toString() : '',
    );
    _nameFocus = FocusNode();
    _countryFocus = FocusNode();
    _descriptionFocus = FocusNode();
    _latitudeFocus = FocusNode();
    _longitudeFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _nameFocus.dispose();
    _countryFocus.dispose();
    _descriptionFocus.dispose();
    _latitudeFocus.dispose();
    _longitudeFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty
          ? 'City name required'
          : null;
      _countryError = _countryController.text.trim().isEmpty
          ? 'Country required'
          : null;
      _descriptionError = _descriptionController.text.trim().isEmpty
          ? 'Description required'
          : null;
      _latitudeError = null;
      _longitudeError = null;
    });

    final String latRaw = _latitudeController.text.trim();
    final String lngRaw = _longitudeController.text.trim();
    final bool hasLat = latRaw.isNotEmpty;
    final bool hasLng = lngRaw.isNotEmpty;
    final double? lat = hasLat ? double.tryParse(latRaw) : null;
    final double? lng = hasLng ? double.tryParse(lngRaw) : null;

    if (hasLat != hasLng) {
      setState(() {
        _latitudeError = 'Enter both latitude and longitude';
        _longitudeError = 'Enter both latitude and longitude';
      });
    } else if (hasLat && hasLng) {
      if (lat == null || lat < -90 || lat > 90) {
        setState(() => _latitudeError = 'Latitude must be between -90 and 90');
      }
      if (lng == null || lng < -180 || lng > 180) {
        setState(
          () => _longitudeError = 'Longitude must be between -180 and 180',
        );
      }
    }

    return _nameError == null &&
        _countryError == null &&
        _descriptionError == null &&
        _latitudeError == null &&
        _longitudeError == null;
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_validate()) return;
    setState(() => _isSubmitting = true);

    final String latRaw = _latitudeController.text.trim();
    final String lngRaw = _longitudeController.text.trim();
    final double? latitude = latRaw.isEmpty ? null : double.tryParse(latRaw);
    final double? longitude = lngRaw.isEmpty ? null : double.tryParse(lngRaw);

    final bool success = _isEdit
        ? await widget.controller.updateCity(
            cityId: widget.initial!.id,
            previousCityName: widget.initial!.name,
            name: _nameController.text,
            country: _countryController.text,
            description: _descriptionController.text,
            latitude: latitude,
            longitude: longitude,
          )
        : await widget.controller.createCity(
            name: _nameController.text,
            country: _countryController.text,
            description: _descriptionController.text,
            latitude: latitude,
            longitude: longitude,
          );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.9.sh),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 46.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.inputBorder,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md.h),
              Text(
                _isEdit ? 'Edit City' : 'Add City',
                style: AppTextStyles.title.copyWith(
                  fontSize: 23.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              CustomTextField(
                label: 'City Name',
                hintText: 'Lahore',
                prefixIcon: Icons.location_city_outlined,
                controller: _nameController,
                focusNode: _nameFocus,
                errorText: _nameError,
              ),
              SizedBox(height: AppSpacing.sm.h),
              CustomTextField(
                label: 'Country',
                hintText: 'Pakistan',
                prefixIcon: Icons.public_rounded,
                controller: _countryController,
                focusNode: _countryFocus,
                errorText: _countryError,
              ),
              SizedBox(height: AppSpacing.sm.h),
              CustomTextField(
                label: 'Description',
                hintText: 'City overview',
                prefixIcon: Icons.notes_rounded,
                controller: _descriptionController,
                focusNode: _descriptionFocus,
                errorText: _descriptionError,
              ),
              SizedBox(height: AppSpacing.sm.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm.w,
                  vertical: AppSpacing.xs.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  'Latitude and longitude are optional. If left empty, the app will apply smart defaults.',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 11.8.sp,
                    color: AppColors.inputFocused,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomTextField(
                      label: 'Latitude',
                      hintText: '31.5204',
                      prefixIcon: Icons.my_location_rounded,
                      controller: _latitudeController,
                      focusNode: _latitudeFocus,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      errorText: _latitudeError,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs.w),
                  Expanded(
                    child: CustomTextField(
                      label: 'Longitude',
                      hintText: '74.3587',
                      prefixIcon: Icons.explore_outlined,
                      controller: _longitudeController,
                      focusNode: _longitudeFocus,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      errorText: _longitudeError,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg.h),
              PrimaryButton(
                text: _isEdit ? 'Save Changes' : 'Create City',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

({Color bg, Color fg}) _statusPalette(String status) {
  switch (status) {
    case 'approved':
      return (
        bg: const Color(0xFF1F9D72).withValues(alpha: 0.14),
        fg: const Color(0xFF1F9D72),
      );
    case 'rejected':
      return (bg: AppColors.error.withValues(alpha: 0.12), fg: AppColors.error);
    default:
      return (
        bg: const Color(0xFFC98B2D).withValues(alpha: 0.15),
        fg: const Color(0xFFC98B2D),
      );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({required this.controller});

  final AdminHomeController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Reviews Moderation',
              style: AppTextStyles.title.copyWith(
                fontSize: 27.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              'Monitor feedback quality, hide abuse, and keep trust signals clean.',
              style: AppTextStyles.body.copyWith(fontSize: 13.sp),
            ),
            SizedBox(height: AppSpacing.md.h),
            _ReviewsSummaryRow(controller: controller),
            SizedBox(height: AppSpacing.md.h),
            _ReviewsSearchField(controller: controller),
            SizedBox(height: AppSpacing.sm.h),
            _ReviewsFiltersRow(controller: controller),
            SizedBox(height: AppSpacing.md.h),
            Expanded(
              child: Obx(() {
                if (controller.isReviewsLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.reviewsError.value.isNotEmpty) {
                  return Center(
                    child: Text(
                      controller.reviewsError.value,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  );
                }

                final List<AdminReviewModel> items = controller.filteredReviews;
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'No reviews found for current filters.',
                      style: AppTextStyles.body,
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      SizedBox(height: AppSpacing.sm.h),
                  itemBuilder: (BuildContext context, int index) {
                    final AdminReviewModel review = items[index];
                    return _ReviewCard(review: review, controller: controller);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsSummaryRow extends StatelessWidget {
  const _ReviewsSummaryRow({required this.controller});

  final AdminHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: <Widget>[
          Expanded(
            child: _SummaryPill(
              label: 'Total',
              value: controller.totalReviewsCount.toString(),
              color: AppColors.inputFocused,
            ),
          ),
          SizedBox(width: AppSpacing.xs.w),
          Expanded(
            child: _SummaryPill(
              label: 'Flagged',
              value: controller.flaggedReviewsCount.toString(),
              color: const Color(0xFFC98B2D),
            ),
          ),
          SizedBox(width: AppSpacing.xs.w),
          Expanded(
            child: _SummaryPill(
              label: 'Hidden',
              value: controller.hiddenReviewsCount.toString(),
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsSearchField extends StatelessWidget {
  const _ReviewsSearchField({required this.controller});

  final AdminHomeController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.reviewSearchController,
      onChanged: controller.onReviewSearchChanged,
      style: AppTextStyles.fieldText.copyWith(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: 'Search by user, listing, or comment',
        hintStyle: AppTextStyles.body.copyWith(fontSize: 13.sp),
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.sm.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13.r),
          borderSide: BorderSide(
            color: AppColors.inputBorder.withValues(alpha: 0.9),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13.r),
          borderSide: BorderSide(
            color: AppColors.inputBorder.withValues(alpha: 0.9),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13.r),
          borderSide: const BorderSide(color: AppColors.inputFocused),
        ),
      ),
    );
  }
}

class _ReviewsFiltersRow extends StatelessWidget {
  const _ReviewsFiltersRow({required this.controller});

  final AdminHomeController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34.h,
      child: Obx(() {
        final String activeFilter = controller.reviewStatusFilter.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.reviewFilters.length,
          separatorBuilder: (BuildContext context, int index) =>
              SizedBox(width: AppSpacing.xs.w),
          itemBuilder: (BuildContext context, int index) {
            final String value = controller.reviewFilters[index];
            final bool selected = activeFilter == value;
            return ChoiceChip(
              label: Text(value.capitalizeFirst ?? value),
              selected: selected,
              onSelected: (bool value) => controller.onReviewFilterChanged(
                controller.reviewFilters[index],
              ),
              labelStyle: AppTextStyles.body.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: selected
                    ? AppColors.inputFocused
                    : AppColors.textSecondary,
                height: 1.1,
              ),
              side: BorderSide(
                color: selected
                    ? AppColors.inputFocused.withValues(alpha: 0.28)
                    : AppColors.inputBorder.withValues(alpha: 0.8),
              ),
              selectedColor: AppColors.accent.withValues(alpha: 0.14),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              showCheckmark: false,
              visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
            );
          },
        );
      }),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.controller});

  final AdminReviewModel review;
  final AdminHomeController controller;

  @override
  Widget build(BuildContext context) {
    final ({Color bg, Color fg}) statusColors = _reviewStatusPalette(
      review.status,
    );

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.inputBorder.withValues(alpha: 0.82),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  review.userName,
                  style: AppTextStyles.button.copyWith(fontSize: 14.4.sp),
                ),
              ),
              if (review.isFlagged)
                Container(
                  margin: EdgeInsets.only(right: AppSpacing.xs.w),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC98B2D).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    'Flagged',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFC98B2D),
                    ),
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusColors.bg,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  review.status.capitalizeFirst ?? review.status,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: statusColors.fg,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            review.listingName,
            style: AppTextStyles.body.copyWith(
              fontSize: 12.4.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            review.comment.isEmpty
                ? 'No review text provided.'
                : review.comment,
            style: AppTextStyles.body.copyWith(
              fontSize: 12.8.sp,
              color: AppColors.textPrimary.withValues(alpha: 0.88),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          if (review.moderationReasonCode.isNotEmpty ||
              review.latestModerationEvent != null) ...<Widget>[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xs.w,
                vertical: AppSpacing.xs.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (review.moderationReasonCode.isNotEmpty)
                    Text(
                      'Reason: ${_prettyReasonCode(review.moderationReasonCode)}',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 11.8.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inputFocused,
                      ),
                    ),
                  if (review.moderationNote.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        review.moderationNote,
                        style: AppTextStyles.body.copyWith(fontSize: 11.5.sp),
                      ),
                    ),
                  if (review.latestModerationEvent != null)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        'Last action: ${review.latestModerationEvent!.action.capitalizeFirst ?? review.latestModerationEvent!.action} • ${_timeAgo(review.latestModerationEvent!.at)}',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 11.2.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
          ],
          Row(
            children: <Widget>[
              Icon(
                Icons.star_rounded,
                color: const Color(0xFFC98B2D),
                size: 16.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                review.rating.toStringAsFixed(1),
                style: AppTextStyles.body.copyWith(
                  fontSize: 12.3.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Icon(
                Icons.thumb_up_alt_outlined,
                size: 14.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 4.w),
              Text(
                review.likesCount.toString(),
                style: AppTextStyles.body.copyWith(fontSize: 12.2.sp),
              ),
              const Spacer(),
              if (!review.isRemoved)
                TextButton(
                  onPressed: review.isHidden
                      ? () => controller.restoreReview(review)
                      : () => controller.hideReview(review),
                  child: Text(review.isHidden ? 'Restore' : 'Hide'),
                ),
              TextButton(
                onPressed: review.isRemoved
                    ? null
                    : () => controller.removeReview(review),
                child: const Text('Remove'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _prettyReasonCode(String value) {
  if (value.trim().isEmpty) return 'Not specified';
  return value
      .trim()
      .split('_')
      .where((String token) => token.isNotEmpty)
      .map((String token) => token[0].toUpperCase() + token.substring(1))
      .join(' ');
}

String _timeAgo(DateTime? timestamp) {
  if (timestamp == null) return 'just now';
  final Duration diff = DateTime.now().difference(timestamp);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  return '${diff.inDays} d ago';
}

({Color bg, Color fg}) _reviewStatusPalette(String status) {
  switch (status) {
    case 'hidden':
      return (
        bg: const Color(0xFFC98B2D).withValues(alpha: 0.15),
        fg: const Color(0xFFC98B2D),
      );
    case 'removed':
      return (bg: AppColors.error.withValues(alpha: 0.12), fg: AppColors.error);
    default:
      return (
        bg: const Color(0xFF1F9D72).withValues(alpha: 0.14),
        fg: const Color(0xFF1F9D72),
      );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.controller});

  final AdminHomeController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Admin Profile',
              style: AppTextStyles.title.copyWith(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              'Control role and access preferences.',
              style: AppTextStyles.body,
            ),
            SizedBox(height: AppSpacing.lg.h),
            Obx(
              () => controller.isAdminProfileLoading.value
                  ? const LinearProgressIndicator(minHeight: 2)
                  : Container(
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
                                  controller.profileName,
                                  style: AppTextStyles.title.copyWith(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  controller.profileEmail,
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 13.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  controller.profilePhone,
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 12.5.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            Text(
              'Platform Snapshot',
              style: AppTextStyles.button.copyWith(fontSize: 15.sp),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Obx(
              () => Row(
                children: <Widget>[
                  Expanded(
                    child: _SummaryPill(
                      label: 'Listings',
                      value: controller.totalListingsCount.toString(),
                      color: AppColors.inputFocused,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs.w),
                  Expanded(
                    child: _SummaryPill(
                      label: 'Reviews',
                      value: controller.totalReviewsCount.toString(),
                      color: const Color(0xFF1F9D72),
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs.w),
                  Expanded(
                    child: _SummaryPill(
                      label: 'Cities',
                      value: controller.activeCitiesCount.toString(),
                      color: const Color(0xFFC98B2D),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            Text(
              'Moderation Settings',
              style: AppTextStyles.button.copyWith(fontSize: 15.sp),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Obx(
              () => _AdminPreferenceTile(
                title: 'Strict Moderation',
                subtitle: 'Enable stricter review and content checks.',
                value: controller.strictModerationEnabled.value,
                onChanged: controller.setStrictModeration,
              ),
            ),
            Obx(
              () => _AdminPreferenceTile(
                title: 'Auto-hide Flagged',
                subtitle: 'Automatically hide heavily flagged reviews.',
                value: controller.autoHideFlaggedEnabled.value,
                onChanged: controller.setAutoHideFlagged,
              ),
            ),
            Obx(
              () => _AdminPreferenceTile(
                title: 'Realtime Alerts',
                subtitle: 'Receive immediate moderation queue alerts.',
                value: controller.realTimeAlertsEnabled.value,
                onChanged: controller.setRealTimeAlerts,
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
            _AdminCard(
              icon: Icons.logout_rounded,
              title: 'Sign out',
              subtitle: 'Return to login screen and end admin session.',
              trailing: TextButton(
                onPressed: () => Get.offAllNamed(AppRoutes.login),
                child: const Text('Log out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminPreferenceTile extends StatelessWidget {
  const _AdminPreferenceTile({
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

class _AdminCard extends StatelessWidget {
  const _AdminCard({
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
        child: Padding(
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
