import 'dart:math' as math;

import 'package:city_guide_app/app/modules/splash/controllers/splash_controller.dart';
import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_durations.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_strings.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => AnimatedOpacity(
          opacity: controller.sceneOpacity.value,
          duration: const Duration(milliseconds: AppDurations.fadeOutMs),
          curve: Curves.easeInOutCubic,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.splashTop,
                  AppColors.splashMiddle,
                  AppColors.splashBottom,
                ],
                stops: <double>[0, 0.55, 1],
              ),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: -90.h,
                  right: -70.w,
                  child: Container(
                    width: 260.w,
                    height: 260.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[
                          AppColors.splashGlow.withValues(alpha: 0.4),
                          AppColors.splashGlow.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80.h,
                  left: -60.w,
                  child: Container(
                    width: 220.w,
                    height: 220.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[
                          AppColors.accent.withValues(alpha: 0.18),
                          AppColors.accent.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 140.h,
                  left: -30.w,
                  child: Container(
                    width: 92.w,
                    height: 92.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.26),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Obx(
                    () => AnimatedScale(
                      scale: controller.logoScale.value,
                      curve: Curves.easeInOutCubic,
                      duration: const Duration(
                        milliseconds: AppDurations.logoFadeScaleMs,
                      ),
                      child: AnimatedOpacity(
                        opacity: controller.logoOpacity.value,
                        curve: Curves.easeInOutCubic,
                        duration: const Duration(
                          milliseconds: AppDurations.logoFadeScaleMs,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _BrandMark(pulse: controller.pulseValue.value),
                            SizedBox(height: AppSpacing.lg.h),
                            Text(
                              AppStrings.appName,
                              style: AppTextStyles.splashBrand,
                            ),
                            SizedBox(height: AppSpacing.xs.h),
                            Text(
                              AppStrings.splashTagline,
                              style: AppTextStyles.splashTagline,
                            ),
                            SizedBox(height: AppSpacing.xxl.h),
                            AnimatedOpacity(
                              opacity: controller.showLoader.value ? 1 : 0,
                              duration: const Duration(milliseconds: 550),
                              curve: Curves.easeInOut,
                              child: _BrandedLoader(
                                pulse: controller.pulseValue.value,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    final double glow = 0.2 + (0.8 * pulse);

    return Container(
      width: 108.w,
      height: 108.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.34),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.09 + (0.16 * glow)),
            blurRadius: 22 + (14 * glow),
            spreadRadius: 1 + (1.2 * glow),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'EX',
          style: AppTextStyles.splashMonogram,
        ),
      ),
    );
  }
}

class _BrandedLoader extends StatelessWidget {
  const _BrandedLoader({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List<Widget>.generate(3, (int index) {
          final double phase = (pulse * 2 * math.pi) + (index * (math.pi / 2.8));
          final double wave = (math.sin(phase) + 1) / 2;
          final double opacity = 0.28 + (wave * 0.72);
          final double size = (6.5 + (wave * 3.5)).w;

          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: opacity),
            ),
          );
        }),
      ),
    );
  }
}
