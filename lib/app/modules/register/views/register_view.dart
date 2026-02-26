import 'package:city_guide_app/app/modules/register/controllers/register_controller.dart';
import 'package:city_guide_app/app/shared/widgets/auth_page_shell.dart';
import 'package:city_guide_app/app/shared/widgets/custom_text_field.dart';
import 'package:city_guide_app/app/shared/widgets/delayed_reveal.dart';
import 'package:city_guide_app/app/shared/widgets/primary_button.dart';
import 'package:city_guide_app/core/constants/app_colors.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_strings.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      title: AppStrings.registerTitle,
      subtitle: AppStrings.registerSubtitle,
      showBack: true,
      onBackTap: controller.goBackToLogin,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DelayedReveal(
            delay: const Duration(milliseconds: 130),
            child: Obx(
              () => CustomTextField(
                label: AppStrings.fullNameLabel,
                hintText: 'Alee Khan',
                prefixIcon: Icons.person_outline_rounded,
                controller: controller.fullNameController,
                focusNode: controller.fullNameFocus,
                textInputAction: TextInputAction.next,
                errorText: controller.fullNameError.value,
                onSubmitted: (_) => controller.emailFocus.requestFocus(),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg.h),
          DelayedReveal(
            delay: const Duration(milliseconds: 180),
            child: Obx(
              () => CustomTextField(
                label: AppStrings.emailLabel,
                hintText: 'name@email.com',
                prefixIcon: Icons.mail_outline_rounded,
                controller: controller.emailController,
                focusNode: controller.emailFocus,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                errorText: controller.emailError.value,
                onSubmitted: (_) => controller.passwordFocus.requestFocus(),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg.h),
          DelayedReveal(
            delay: const Duration(milliseconds: 230),
            child: Obx(
              () => CustomTextField(
                label: AppStrings.passwordLabel,
                hintText: 'Create a secure password',
                prefixIcon: Icons.lock_outline_rounded,
                controller: controller.passwordController,
                focusNode: controller.passwordFocus,
                isPassword: true,
                obscureText: controller.isPasswordHidden.value,
                errorText: controller.passwordError.value,
                textInputAction: TextInputAction.next,
                onToggleVisibility: () => controller.isPasswordHidden.toggle(),
                onChanged: controller.onPasswordChanged,
                onSubmitted: (_) => controller.confirmPasswordFocus.requestFocus(),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          DelayedReveal(
            delay: const Duration(milliseconds: 270),
            child: Obx(
              () => _StrengthIndicator(
                strength: controller.passwordStrength.value,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg.h),
          DelayedReveal(
            delay: const Duration(milliseconds: 310),
            child: Obx(
              () => CustomTextField(
                label: AppStrings.confirmPasswordLabel,
                hintText: 'Re-enter password',
                prefixIcon: Icons.verified_user_outlined,
                controller: controller.confirmPasswordController,
                focusNode: controller.confirmPasswordFocus,
                isPassword: true,
                obscureText: controller.isConfirmPasswordHidden.value,
                errorText: controller.confirmPasswordError.value,
                onToggleVisibility: () => controller.isConfirmPasswordHidden.toggle(),
                onSubmitted: (_) => controller.onRegisterTap(),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xl.h),
          DelayedReveal(
            delay: const Duration(milliseconds: 360),
            child: Obx(
              () => PrimaryButton(
                text: AppStrings.register,
                isLoading: controller.isLoading.value,
                onPressed: controller.onRegisterTap,
              ),
            ),
          ),
        ],
      ),
      footer: DelayedReveal(
        delay: const Duration(milliseconds: 410),
        child: Center(
          child: TextButton(
            onPressed: controller.goBackToLogin,
            child: Text(AppStrings.haveAccount, style: AppTextStyles.link),
          ),
        ),
      ),
    );
  }
}

class _StrengthIndicator extends StatelessWidget {
  const _StrengthIndicator({required this.strength});

  final double strength;

  @override
  Widget build(BuildContext context) {
    final bool weak = strength <= 0.35;
    final bool medium = strength > 0.35 && strength <= 0.7;
    final Color barColor = weak
        ? AppColors.error
        : medium
            ? const Color(0xFFC98B2D)
            : const Color(0xFF2D8A57);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(99.r),
          child: LinearProgressIndicator(
            minHeight: 6.h,
            value: strength,
            color: barColor,
            backgroundColor: AppColors.inputBorder.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: AppSpacing.xs.h),
        Text(
          'Password strength',
          style: AppTextStyles.body.copyWith(fontSize: 12.sp),
        ),
      ],
    );
  }
}
