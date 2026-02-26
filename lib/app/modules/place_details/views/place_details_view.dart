import 'package:city_guide_app/app/modules/place_details/controllers/place_details_controller.dart';
import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PlaceDetailsView extends GetView<PlaceDetailsController> {
  const PlaceDetailsView({super.key});

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
                  Icon(Icons.star_rounded, size: 16.sp, color: AppColors.inputFocused),
                  SizedBox(width: 3.w),
                  Text(controller.rating, style: AppTextStyles.body),
                  SizedBox(width: AppSpacing.md.w),
                  Icon(Icons.near_me_rounded, size: 15.sp, color: AppColors.inputFocused),
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
                  border: Border.all(color: AppColors.inputBorder.withValues(alpha: 0.8)),
                ),
                child: Text(
                  'A curated destination with premium local experiences, ideal for daytime and evening visits.',
                  style: AppTextStyles.body,
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              SizedBox(
                width: double.infinity,
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
                  child: Text('Add to Plan', style: AppTextStyles.button.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
