import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get headline => GoogleFonts.playfairDisplay(
        fontSize: 34.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.2,
      );

  static TextStyle get title => GoogleFonts.inter(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
      );

  static TextStyle get splashMonogram => GoogleFonts.inter(
        fontSize: 26.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.accent,
        letterSpacing: 1.2,
      );

  static TextStyle get splashBrand => GoogleFonts.playfairDisplay(
        fontSize: 41.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.splashTextPrimary,
        letterSpacing: 0.2,
      );

  static TextStyle get splashTagline => GoogleFonts.inter(
        fontSize: 13.5.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.splashTextSecondary,
        letterSpacing: 0.32,
      );

  static TextStyle get authHeading => GoogleFonts.playfairDisplay(
        fontSize: 34.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get authSubtitle => GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.55,
      );

  static TextStyle get fieldLabel => GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get fieldText => GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get link => GoogleFonts.inter(
        fontSize: 13.5.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.inputFocused,
      );
}
