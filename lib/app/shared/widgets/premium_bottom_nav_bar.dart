import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavItemData {
  const NavItemData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class PremiumBottomNavBar extends StatelessWidget {
  const PremiumBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<NavItemData> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final double itemCount = items.length.toDouble();

    return SafeArea(
      minimum: EdgeInsets.fromLTRB(
        AppSpacing.md.w,
        0,
        AppSpacing.md.w,
        AppSpacing.md.h,
      ),
      child: Container(
        height: 70.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.inputBorder.withValues(alpha: 0.9),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double slotWidth = constraints.maxWidth / itemCount;
            final double indicatorWidth = slotWidth - 12.w;
            final double left = (slotWidth * currentIndex) + 6.w;

            return Stack(
              children: <Widget>[
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOutCubic,
                  left: left,
                  top: 0,
                  width: indicatorWidth,
                  height: 4.h,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99.r),
                      color: AppColors.accent,
                    ),
                  ),
                ),
                Row(
                  children: List<Widget>.generate(items.length, (int index) {
                    final NavItemData item = items[index];
                    final bool active = currentIndex == index;

                    return Expanded(
                      child: InkWell(
                        onTap: () => onTap(index),
                        borderRadius: BorderRadius.circular(14.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              AnimatedScale(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeInOut,
                                scale: active ? 1.08 : 1,
                                child: Icon(
                                  item.icon,
                                  size: 21.sp,
                                  color: active
                                      ? AppColors.inputFocused
                                      : AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              SizedBox(
                                height: 13.h,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeInOut,
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 11.6.sp,
                                      height: 1,
                                      fontWeight: active
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: active
                                          ? AppColors.inputFocused
                                          : AppColors.textSecondary,
                                    ),
                                    child: Text(
                                      item.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
