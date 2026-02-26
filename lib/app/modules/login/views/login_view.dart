import 'package:city_guide_app/app/modules/login/controllers/login_controller.dart';
import 'package:city_guide_app/app/shared/widgets/auth_page_shell.dart';
import 'package:city_guide_app/app/shared/widgets/custom_text_field.dart';
import 'package:city_guide_app/app/shared/widgets/delayed_reveal.dart';
import 'package:city_guide_app/app/shared/widgets/primary_button.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_strings.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      title: AppStrings.welcomeBack,
      subtitle: AppStrings.loginSubtitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DelayedReveal(
            delay: const Duration(milliseconds: 140),
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
            delay: const Duration(milliseconds: 190),
            child: Obx(
              () => CustomTextField(
                label: AppStrings.passwordLabel,
                hintText: 'Enter your password',
                prefixIcon: Icons.lock_outline_rounded,
                controller: controller.passwordController,
                focusNode: controller.passwordFocus,
                isPassword: true,
                obscureText: controller.isPasswordHidden.value,
                errorText: controller.passwordError.value,
                onToggleVisibility: () => controller.isPasswordHidden.toggle(),
                onSubmitted: (_) => controller.onLoginTap(),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          DelayedReveal(
            delay: const Duration(milliseconds: 240),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: controller.onForgotPasswordTap,
                child: Text(AppStrings.forgotPassword, style: AppTextStyles.link),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          DelayedReveal(
            delay: const Duration(milliseconds: 290),
            child: Obx(
              () => PrimaryButton(
                text: AppStrings.login,
                isLoading: controller.isLoading.value,
                onPressed: controller.onLoginTap,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xl.h),
          DelayedReveal(
            delay: const Duration(milliseconds: 340),
            child: Row(
              children: <Widget>[
                const Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
                  child: Text(AppStrings.or, style: AppTextStyles.body),
                ),
                const Expanded(child: Divider()),
              ],
            ),
          ),
        ],
      ),
      footer: DelayedReveal(
        delay: const Duration(milliseconds: 390),
        child: Center(
          child: TextButton(
            onPressed: controller.goToRegister,
            child: Text(AppStrings.dontHaveAccount, style: AppTextStyles.link),
          ),
        ),
      ),
    );
  }
}
