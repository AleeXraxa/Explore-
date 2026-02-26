import 'package:city_guide_app/app/shared/widgets/auth_particle_background.dart';
import 'package:city_guide_app/app/shared/widgets/delayed_reveal.dart';
import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_radius.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_strings.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthPageShell extends StatelessWidget {
  const AuthPageShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    this.footer,
    this.showBack = false,
    this.onBackTap,
  });

  final String title;
  final String subtitle;
  final Widget body;
  final Widget? footer;
  final bool showBack;
  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          const AuthParticleBackground(),
          SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg.w,
                    AppSpacing.md.h,
                    AppSpacing.lg.w,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          if (showBack)
                            _BackButton(onTap: onBackTap)
                          else
                            SizedBox(width: 40.w),
                          Expanded(
                            child: Center(
                              child: const _PremiumWordmarkHeader(),
                            ),
                          ),
                          SizedBox(width: 40.w),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xl.h),
                      DelayedReveal(
                        delay: const Duration(milliseconds: 120),
                        duration: const Duration(milliseconds: 480),
                        child: Text(title, style: AppTextStyles.authHeading),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      DelayedReveal(
                        delay: const Duration(milliseconds: 170),
                        duration: const Duration(milliseconds: 500),
                        child: Text(subtitle, style: AppTextStyles.authSubtitle),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                        topRight: Radius.circular(30.r),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.inputBorder.withValues(alpha: 0.75),
                        ),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: DelayedReveal(
                      delay: const Duration(milliseconds: 110),
                      duration: const Duration(milliseconds: 500),
                      offset: const Offset(0, 0.06),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.lg.w,
                          AppSpacing.xl.h,
                          AppSpacing.lg.w,
                          AppSpacing.lg.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            body,
                            if (footer != null) ...<Widget>[
                              SizedBox(height: AppSpacing.lg.h),
                              footer!,
                            ],
                          ],
                        ),
                      ),
                    ),
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

class _BackButton extends StatelessWidget {
  const _BackButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md.r),
        side: const BorderSide(color: AppColors.inputBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _PremiumWordmarkHeader extends StatelessWidget {
  const _PremiumWordmarkHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          AppStrings.appName.toUpperCase(),
          style: AppTextStyles.title.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          AppStrings.appTagline,
          style: AppTextStyles.body.copyWith(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
            color: AppColors.textSecondary.withValues(alpha: 0.95),
          ),
        ),
        SizedBox(height: AppSpacing.xs.h),
        Container(
          width: 94.w,
          height: 2.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99.r),
            gradient: LinearGradient(
              colors: <Color>[
                AppColors.splashGold.withValues(alpha: 0),
                AppColors.splashGold.withValues(alpha: 0.6),
                AppColors.splashGold.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
