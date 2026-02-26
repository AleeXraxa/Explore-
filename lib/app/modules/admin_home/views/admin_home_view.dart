import 'package:city_guide_app/app/modules/admin_home/controllers/admin_home_controller.dart';
import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AdminHomeView extends GetView<AdminHomeController> {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      controller.title,
                      style: AppTextStyles.title.copyWith(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: controller.goToUserView,
                    child: const Text('Switch to User'),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs.h),
              Text(controller.subtitle, style: AppTextStyles.body),
              SizedBox(height: AppSpacing.lg.h),
              const _AdminCard(
                icon: Icons.approval_rounded,
                title: 'Content Moderation',
                subtitle: 'Review pending city submissions and listing updates.',
              ),
              const _AdminCard(
                icon: Icons.groups_rounded,
                title: 'User Management',
                subtitle: 'Manage user status, reports, and role permissions.',
              ),
              const _AdminCard(
                icon: Icons.analytics_rounded,
                title: 'Platform Analytics',
                subtitle: 'Monitor usage trends across neighborhoods and cities.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md.h),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: AppColors.inputFocused),
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: AppTextStyles.button),
                    SizedBox(height: 4.h),
                    Text(subtitle, style: AppTextStyles.body),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
