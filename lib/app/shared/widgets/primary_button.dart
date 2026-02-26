import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_radius.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.fullWidth = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final bool fullWidth;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  bool get _canPress => widget.enabled && !widget.isLoading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final Color background = _canPress
        ? (_pressed ? AppColors.buttonPrimaryPressed : AppColors.buttonPrimary)
        : AppColors.textSecondary.withValues(alpha: 0.45);

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      child: SizedBox(
        width: widget.fullWidth ? double.infinity : null,
        height: 54.h,
        child: Material(
          color: Colors.transparent,
          elevation: _canPress ? 0.5 : 0,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.md.r),
          child: InkWell(
            onTap: _canPress ? widget.onPressed : null,
            borderRadius: BorderRadius.circular(AppRadius.md.r),
            splashColor: Colors.white.withValues(alpha: 0.12),
            highlightColor: Colors.white.withValues(alpha: 0.03),
            onHighlightChanged: (bool value) => setState(() => _pressed = value),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    _canPress
                        ? background.withValues(alpha: 0.95)
                        : AppColors.textSecondary.withValues(alpha: 0.4),
                    _canPress
                        ? AppColors.inputFocused
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                  ],
                ),
                boxShadow: <BoxShadow>[
                  if (_canPress)
                    BoxShadow(
                      color: AppColors.inputFocused.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 9),
                    ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: widget.isLoading
                      ? SizedBox(
                          key: const ValueKey<String>('loader'),
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.1,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.text,
                          key: const ValueKey<String>('text'),
                          style: AppTextStyles.button.copyWith(color: Colors.white),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
