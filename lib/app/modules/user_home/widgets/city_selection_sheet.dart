import 'package:city_guide_app/app/data/models/city_model.dart';
import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CitySelectionSheet extends StatelessWidget {
  const CitySelectionSheet({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.onCitySelected,
  });

  final List<CityModel> cities;
  final CityModel selectedCity;
  final ValueChanged<CityModel> onCitySelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg.w,
          AppSpacing.md.h,
          AppSpacing.lg.w,
          AppSpacing.lg.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Select City',
              style: AppTextStyles.title.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              'Current location is used as default. You can switch anytime.',
              style: AppTextStyles.body.copyWith(fontSize: 13.sp),
            ),
            SizedBox(height: AppSpacing.md.h),
            ...cities.map((CityModel city) {
              final bool active = city.name == selectedCity.name;
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
                child: InkWell(
                  onTap: () => onCitySelected(city),
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.md.w),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.accent.withValues(alpha: 0.14)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: active
                            ? AppColors.accent
                            : AppColors.inputBorder.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${city.name}, ${city.country}',
                                style: AppTextStyles.button.copyWith(fontSize: 14.sp),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                city.description,
                                style: AppTextStyles.body.copyWith(fontSize: 12.5.sp),
                              ),
                            ],
                          ),
                        ),
                        if (active)
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.inputFocused,
                            size: 18.sp,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
