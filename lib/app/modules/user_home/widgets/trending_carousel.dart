import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrendingCarousel extends StatelessWidget {
  const TrendingCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_TrendingItem> items = <_TrendingItem>[
      const _TrendingItem('Clifton Beach Walk', '4.8', '2.1 km'),
      const _TrendingItem('Frere Hall Heritage', '4.6', '3.8 km'),
      const _TrendingItem('Port Grand Night', '4.7', '5.2 km'),
    ];

    return SizedBox(
      height: 184.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => SizedBox(width: AppSpacing.sm.w),
        itemBuilder: (BuildContext context, int index) {
          final _TrendingItem item = items[index];
          return Container(
            width: 226.w,
            padding: EdgeInsets.all(AppSpacing.md.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.accent.withValues(alpha: 0.3),
                  AppColors.accent.withValues(alpha: 0.14),
                ],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs.w,
                    vertical: AppSpacing.xxs.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Trending',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.inputFocused,
                      fontSize: 10.5.sp,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  item.title,
                  style: AppTextStyles.button.copyWith(
                    fontSize: 15.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs.h),
                Row(
                  children: <Widget>[
                    Icon(Icons.star_rounded, color: AppColors.inputFocused, size: 15.sp),
                    SizedBox(width: 2.w),
                    Text(item.rating, style: AppTextStyles.body.copyWith(fontSize: 12.sp)),
                    SizedBox(width: AppSpacing.sm.w),
                    Icon(Icons.near_me_rounded, color: AppColors.inputFocused, size: 14.sp),
                    SizedBox(width: 2.w),
                    Text(item.distance, style: AppTextStyles.body.copyWith(fontSize: 12.sp)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TrendingItem {
  const _TrendingItem(this.title, this.rating, this.distance);

  final String title;
  final String rating;
  final String distance;
}
