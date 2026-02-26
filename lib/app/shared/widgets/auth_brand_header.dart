import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_radius.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_strings.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 54.w,
              height: 54.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md.r),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    AppColors.buttonPrimary,
                    AppColors.inputFocused,
                  ],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.inputFocused.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'CG',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.splashGold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md.w),
            Text(
              AppStrings.appName,
              style: AppTextStyles.title.copyWith(
                fontSize: 25.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.25,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xl.h),
        Text(title, style: AppTextStyles.authHeading),
        SizedBox(height: AppSpacing.xs.h),
        Text(subtitle, style: AppTextStyles.authSubtitle),
      ],
    );
  }
}
