import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({
    super.key,
    required this.onExploreTap,
    required this.onPlanTap,
    required this.onSavedTap,
  });

  final VoidCallback onExploreTap;
  final VoidCallback onPlanTap;
  final VoidCallback onSavedTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _ActionChip(
            icon: Icons.travel_explore_rounded,
            label: 'Explore',
            onTap: onExploreTap,
          ),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          child: _ActionChip(
            icon: Icons.event_note_rounded,
            label: 'Plan',
            onTap: onPlanTap,
          ),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          child: _ActionChip(
            icon: Icons.bookmark_rounded,
            label: 'Saved',
            onTap: onSavedTap,
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Ink(
          height: 52.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.accent.withValues(alpha: 0.22),
                AppColors.accent.withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(7.r),
                ),
                child: Icon(icon, size: 14.sp, color: AppColors.inputFocused),
              ),
              SizedBox(width: AppSpacing.xs.w),
              Text(
                label,
                style: AppTextStyles.button.copyWith(
                  color: AppColors.inputFocused,
                  fontSize: 12.6.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
