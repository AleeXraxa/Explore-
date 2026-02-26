import 'dart:ui';

import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PremiumDialogs {
  PremiumDialogs._();

  static OverlayEntry? _loadingEntry;
  static bool _dismissLoadingOnShow = false;

  static void showLoading({
    String title = 'Creating account',
    String subtitle = 'Please wait a moment...',
  }) {
    if (_loadingEntry != null) return;

    final BuildContext? context = Get.overlayContext;
    if (context == null) {
      return;
    }

    if (_dismissLoadingOnShow) {
      _dismissLoadingOnShow = false;
      return;
    }

    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _loadingEntry = OverlayEntry(
      builder: (BuildContext context) {
        return _PremiumDialogBackdrop(
          child: _LoadingBox(
            title: title,
            subtitle: subtitle,
          ),
        );
      },
    );
    overlay.insert(_loadingEntry!);
  }

  static void hideLoading() {
    if (_loadingEntry == null) {
      _dismissLoadingOnShow = true;
      return;
    }

    if (Get.isDialogOpen ?? false) {
      _dismissLoadingOnShow = false;
    }
    _loadingEntry?.remove();
    _loadingEntry = null;
    _dismissLoadingOnShow = false;
  }

  static Future<bool> showStatus({
    required bool success,
    required String title,
    required String message,
    String buttonText = 'OK',
    bool barrierDismissible = true,
  }) async {
    final BuildContext? context = Get.overlayContext;
    if (context == null) return false;

    final bool? result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'status',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) => _PremiumDialogBackdrop(
        child: _StatusBox(
          success: success,
          title: title,
          message: message,
          buttonText: buttonText,
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
    );
    return result ?? false;
  }
}

class _PremiumDialogBackdrop extends StatelessWidget {
  const _PremiumDialogBackdrop({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ),
          ),
          Center(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 285.w,
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.inputBorder.withValues(alpha: 0.9)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 24.w,
            height: 24.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.inputFocused,
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          Text(
            title,
            style: AppTextStyles.button.copyWith(fontSize: 15.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xs.h),
          Text(
            subtitle,
            style: AppTextStyles.body.copyWith(fontSize: 12.8.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({
    required this.success,
    required this.title,
    required this.message,
    required this.buttonText,
  });

  final bool success;
  final String title;
  final String message;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    final Color accent = success ? const Color(0xFF1F9D72) : AppColors.error;

    return Container(
      width: 300.w,
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.inputBorder.withValues(alpha: 0.9)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              success ? Icons.check_rounded : Icons.close_rounded,
              color: accent,
              size: 22.sp,
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          Text(
            title,
            style: AppTextStyles.button.copyWith(fontSize: 15.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xs.h),
          Text(
            message,
            style: AppTextStyles.body.copyWith(fontSize: 12.8.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Get.back<bool>(result: true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
