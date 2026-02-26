import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthParticleBackground extends StatelessWidget {
  const AuthParticleBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -80.h,
            left: -40.w,
            child: _Particle(
              size: 220.w,
              color: AppColors.splashGold.withValues(alpha: 0.09),
            ),
          ),
          Positioned(
            top: 140.h,
            right: -30.w,
            child: _Particle(
              size: 120.w,
              color: AppColors.inputFocused.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            bottom: 180.h,
            left: -20.w,
            child: _Particle(
              size: 90.w,
              color: AppColors.splashGold.withValues(alpha: 0.07),
            ),
          ),
          Positioned(
            bottom: -70.h,
            right: -50.w,
            child: _Particle(
              size: 210.w,
              color: AppColors.inputFocused.withValues(alpha: 0.05),
            ),
          ),
        ],
      ),
    );
  }
}

class _Particle extends StatelessWidget {
  const _Particle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
