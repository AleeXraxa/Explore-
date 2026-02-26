import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecommendationList extends StatelessWidget {
  const RecommendationList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_RecommendationItem> items = <_RecommendationItem>[
      const _RecommendationItem(
        'Mazar-e-Quaid',
        'Historic landmark with guided tours',
      ),
      const _RecommendationItem(
        'Burns Road Food Street',
        'Top-rated local cuisine and street food',
      ),
      const _RecommendationItem(
        'Do Darya Waterfront',
        'Evening dining with sea views',
      ),
    ];

    return Column(
      children: items.map((_RecommendationItem item) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
          child: Container(
            constraints: BoxConstraints(minHeight: 96.h),
            padding: EdgeInsets.all(AppSpacing.md.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.inputBorder.withValues(alpha: 0.75)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
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
                  child: Icon(Icons.place_rounded, color: AppColors.inputFocused, size: 20.sp),
                ),
                SizedBox(width: AppSpacing.md.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(item.title, style: AppTextStyles.button),
                      SizedBox(height: 3.h),
                      Text(
                        item.subtitle,
                        style: AppTextStyles.body.copyWith(fontSize: 13.sp),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs.w,
                          vertical: AppSpacing.xxs.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Recommended',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 10.5.sp,
                            color: AppColors.inputFocused,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18.sp,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RecommendationItem {
  const _RecommendationItem(this.title, this.subtitle);

  final String title;
  final String subtitle;
}
