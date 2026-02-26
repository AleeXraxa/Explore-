import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TodayPlanCard extends StatelessWidget {
  const TodayPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 98.h),
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white,
            AppColors.accent.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.inputBorder.withValues(alpha: 0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.route_rounded, color: AppColors.inputFocused, size: 22.sp),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Today\'s Mini Itinerary',
                  style: AppTextStyles.button.copyWith(fontSize: 15.sp),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Museum -> Lunch -> Sunset Walk',
                  style: AppTextStyles.body.copyWith(fontSize: 13.sp),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xs.w,
              vertical: AppSpacing.xxs.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  'Open',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 10.8.sp,
                    color: AppColors.inputFocused,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11.sp,
                  color: AppColors.inputFocused,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
