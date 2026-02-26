import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.userName,
    required this.cityName,
    required this.onCityTap,
    this.isLoadingCity = false,
  });

  final String userName;
  final String cityName;
  final VoidCallback onCityTap;
  final bool isLoadingCity;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Good morning, $userName',
                style: AppTextStyles.title.copyWith(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
              SizedBox(height: AppSpacing.xxs.h),
              InkWell(
                onTap: onCityTap,
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
                        size: 16.sp,
                        color: AppColors.inputFocused,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        cityName,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.inputFocused,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      if (isLoadingCity)
                        SizedBox(
                          width: 12.w,
                          height: 12.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.8,
                            color: AppColors.inputFocused,
                          ),
                        )
                      else
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16.sp,
                          color: AppColors.inputFocused,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.inputBorder.withValues(alpha: 0.8)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            size: 20.sp,
            color: AppColors.inputFocused,
          ),
        ),
      ],
    );
  }
}
