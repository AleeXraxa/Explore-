import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const List<_CategoryItem> categories = <_CategoryItem>[
      _CategoryItem('Food', Icons.restaurant_rounded),
      _CategoryItem('Culture', Icons.account_balance_rounded),
      _CategoryItem('Nature', Icons.park_rounded),
      _CategoryItem('Nightlife', Icons.nights_stay_rounded),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSpacing.sm.h,
        crossAxisSpacing: AppSpacing.sm.w,
        mainAxisExtent: 92.h,
      ),
      itemBuilder: (BuildContext context, int index) {
        final _CategoryItem item = categories[index];
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.white,
                AppColors.accent.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.inputBorder.withValues(alpha: 0.7)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(item.icon, color: AppColors.inputFocused, size: 17.sp),
              ),
              SizedBox(height: AppSpacing.xs.h),
              Text(
                item.title,
                style: AppTextStyles.body.copyWith(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryItem {
  const _CategoryItem(this.title, this.icon);

  final String title;
  final IconData icon;
}
