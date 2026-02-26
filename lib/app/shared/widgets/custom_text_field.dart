import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_radius.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    required this.focusNode,
    this.errorText,
    this.enabled = true,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
  });

  final String label;
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final bool enabled;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocusChange);
      widget.focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = widget.focusNode.hasFocus;
    final bool hasError = widget.errorText != null;
    final Color borderColor = hasError
        ? AppColors.error
        : isFocused
            ? AppColors.inputFocused
            : AppColors.inputBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md.r),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.white,
            Colors.white.withValues(alpha: 0.98),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
          if (isFocused && !hasError)
            BoxShadow(
              color: AppColors.inputFocused.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        obscureText: widget.isPassword && widget.obscureText,
        cursorColor: AppColors.inputFocused,
        style: AppTextStyles.fieldText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hintText,
          errorText: widget.errorText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: AppTextStyles.fieldLabel.copyWith(
            color: hasError
                ? AppColors.error
                : isFocused
                    ? AppColors.inputFocused
                    : AppColors.textSecondary,
          ),
          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.8),
          ),
          prefixIcon: Icon(
            widget.prefixIcon,
            size: 20.sp,
            color: hasError
                ? AppColors.error
                : isFocused
                    ? AppColors.inputFocused
                    : AppColors.textSecondary,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  splashRadius: 18.r,
                  onPressed: widget.onToggleVisibility,
                  icon: Icon(
                    widget.obscureText ? Icons.visibility_off : Icons.visibility,
                    size: 20.sp,
                    color: isFocused
                        ? AppColors.inputFocused
                        : AppColors.textSecondary,
                  ),
                )
              : null,
          filled: true,
          fillColor: widget.enabled ? AppColors.surface : AppColors.inputDisabled,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.md.h,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md.r),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md.r),
            borderSide: BorderSide(color: borderColor, width: 1.4),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md.r),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md.r),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md.r),
            borderSide: const BorderSide(color: AppColors.error, width: 1.4),
          ),
        ),
      ),
    );
  }
}
