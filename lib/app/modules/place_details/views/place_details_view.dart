import 'package:city_guide_app/app/modules/place_details/controllers/place_details_controller.dart';
import 'package:city_guide_app/app/data/models/admin_review_model.dart';
import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailsView extends GetView<PlaceDetailsController> {
  const PlaceDetailsView({super.key});

  Future<void> _openReviewSheet(BuildContext context) async {
    if (controller.hasUserReviewed) return;
    final TextEditingController commentController = TextEditingController();
    double stars = 4;
    bool isSubmitting = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg.w,
            AppSpacing.lg.h,
            AppSpacing.lg.w,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg.h,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Write a review',
                    style: AppTextStyles.title.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    'Rate your experience',
                    style: AppTextStyles.body.copyWith(fontSize: 13.sp),
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  Row(
                    children: List<Widget>.generate(5, (int index) {
                      final int value = index + 1;
                      return IconButton(
                        onPressed: () =>
                            setState(() => stars = value.toDouble()),
                        icon: Icon(
                          stars >= value
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: AppColors.inputFocused,
                          size: 24.sp,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  TextField(
                    controller: commentController,
                    minLines: 3,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Share your experience',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setState(() => isSubmitting = true);
                              final bool success = await controller
                                  .submitReview(
                                    stars: stars,
                                    comment: commentController.text,
                                  );
                              if (!context.mounted) return;
                              setState(() => isSubmitting = false);
                              if (success) {
                                Navigator.of(context).pop();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: isSubmitting
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Submit Review'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    commentController.dispose();
  }

  Future<void> _openWebsite() async {
    if (controller.website.trim().isEmpty) return;
    final String raw = controller.website.trim();
    final Uri uri = Uri.parse(
      raw.startsWith('http://') || raw.startsWith('https://')
          ? raw
          : 'https://$raw',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openDirections() async {
    if (controller.latitude == 0 && controller.longitude == 0) return;
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${controller.latitude},${controller.longitude}',
    );
    await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  SizedBox(width: AppSpacing.xs.w),
                  Expanded(
                    child: Text(
                      'Place Details',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md.h),
              Container(
                height: 210.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      AppColors.accent.withValues(alpha: 0.32),
                      AppColors.accent.withValues(alpha: 0.12),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: EdgeInsets.all(AppSpacing.md.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs.w,
                      vertical: AppSpacing.xxs.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      controller.highlight,
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.inputFocused,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              SizedBox(
                height: 86.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (BuildContext context, int index) =>
                      SizedBox(width: AppSpacing.xs.w),
                  itemBuilder: (BuildContext context, int index) {
                    final bool hasImage = controller.imageUrl.trim().isNotEmpty;
                    return Container(
                      width: 120.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        gradient: LinearGradient(
                          colors: <Color>[
                            AppColors.accent.withValues(alpha: 0.22),
                            AppColors.accent.withValues(alpha: 0.09),
                          ],
                        ),
                        image:
                            hasImage &&
                                index == 0 &&
                                controller.imageUrl.startsWith('http')
                            ? DecorationImage(
                                image: NetworkImage(controller.imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              Text(
                controller.title,
                style: AppTextStyles.title.copyWith(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: AppSpacing.xs.h),
              Text(
                controller.category,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.inputFocused,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.md.h),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.star_rounded,
                    size: 16.sp,
                    color: AppColors.inputFocused,
                  ),
                  SizedBox(width: 3.w),
                  Text(controller.rating, style: AppTextStyles.body),
                  SizedBox(width: 4.w),
                  Text(
                    '(${controller.ratingsCount})',
                    style: AppTextStyles.body.copyWith(fontSize: 12.sp),
                  ),
                  SizedBox(width: AppSpacing.md.w),
                  Icon(
                    Icons.near_me_rounded,
                    size: 15.sp,
                    color: AppColors.inputFocused,
                  ),
                  SizedBox(width: 3.w),
                  Text(controller.distance, style: AppTextStyles.body),
                ],
              ),
              SizedBox(height: AppSpacing.lg.h),
              Container(
                padding: EdgeInsets.all(AppSpacing.md.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.inputBorder.withValues(alpha: 0.8),
                  ),
                ),
                child: Text(
                  controller.description.isNotEmpty
                      ? controller.description
                      : 'A curated destination with premium local experiences, ideal for daytime and evening visits.',
                  style: AppTextStyles.body,
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              Container(
                padding: EdgeInsets.all(AppSpacing.md.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.inputBorder.withValues(alpha: 0.8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _InfoLine(
                      icon: Icons.pin_drop_outlined,
                      text: controller.address,
                    ),
                    _InfoLine(
                      icon: Icons.call_outlined,
                      text: controller.contactInfo,
                    ),
                    _InfoLine(
                      icon: Icons.access_time_rounded,
                      text: controller.openingHours,
                    ),
                    if (controller.website.trim().isNotEmpty)
                      InkWell(
                        onTap: _openWebsite,
                        child: Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            controller.website,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.inputFocused,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.md.h),
              if (!(controller.latitude == 0 && controller.longitude == 0))
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: AppColors.inputBorder.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(14.r),
                        ),
                        child: SizedBox(
                          height: 190.h,
                          width: double.infinity,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                controller.latitude,
                                controller.longitude,
                              ),
                              initialZoom: 13,
                              interactionOptions: const InteractionOptions(
                                flags:
                                    InteractiveFlag.pinchZoom |
                                    InteractiveFlag.drag |
                                    InteractiveFlag.doubleTapZoom,
                              ),
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
                                    point: LatLng(
                                      controller.latitude,
                                      controller.longitude,
                                    ),
                                    width: 44.w,
                                    height: 44.w,
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
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: _openDirections,
                          icon: const Icon(Icons.directions_rounded),
                          label: const Text('Get Directions'),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: AppSpacing.md.h),
              Text(
                'User reviews',
                style: AppTextStyles.title.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              Obx(() {
                if (controller.isReviewsLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.reviewsError.value.isNotEmpty) {
                  return Text(
                    controller.reviewsError.value,
                    style: AppTextStyles.body.copyWith(color: AppColors.error),
                  );
                }
                if (controller.reviews.isEmpty) {
                  return Text(
                    'No reviews yet. Be the first to review.',
                    style: AppTextStyles.body,
                  );
                }

                return Column(
                  children: controller.reviews.take(6).map((
                    AdminReviewModel review,
                  ) {
                    return Container(
                      margin: EdgeInsets.only(bottom: AppSpacing.sm.h),
                      padding: EdgeInsets.all(AppSpacing.sm.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.inputBorder.withValues(alpha: 0.8),
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
                                  style: AppTextStyles.button.copyWith(
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.star_rounded,
                                size: 14.sp,
                                color: AppColors.inputFocused,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                review.rating.toStringAsFixed(1),
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            review.comment,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 12.5.sp,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: controller.hasUserLikedReview(review)
                                  ? null
                                  : () => controller.likeReview(review),
                              icon: Icon(
                                controller.hasUserLikedReview(review)
                                    ? Icons.thumb_up_alt_rounded
                                    : Icons.thumb_up_alt_outlined,
                              ),
                              label: Text('Helpful (${review.likesCount})'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }),
              if (!controller.readOnly) ...<Widget>[
                SizedBox(height: AppSpacing.lg.h),
                Obx(
                  () => Row(
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: Text(
                              'Add to Plan',
                              style: AppTextStyles.button.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.xs.w),
                      Expanded(
                        child: SizedBox(
                          height: 52.h,
                          child: OutlinedButton(
                            onPressed: controller.hasUserReviewed
                                ? null
                                : () => _openReviewSheet(context),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: Text(
                              controller.hasUserReviewed
                                  ? 'Review Submitted'
                                  : 'Write Review',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16.sp, color: AppColors.inputFocused),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(fontSize: 12.7.sp),
            ),
          ),
        ],
      ),
    );
  }
}
