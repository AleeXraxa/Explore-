import 'package:city_guide_app/app/data/models/user_role.dart';
import 'package:city_guide_app/app/data/services/auth_service.dart';
import 'package:city_guide_app/app/routes/app_routes.dart';
import 'package:city_guide_app/app/shared/widgets/premium_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  LoginController(this._authService);

  final AuthService _authService;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;
  final emailError = RxnString();
  final passwordError = RxnString();

  bool _validate() {
    emailError.value = null;
    passwordError.value = null;

    final String email = emailController.text.trim();
    final String password = passwordController.text;

    if (email.isEmpty) {
      emailError.value = 'Email is required';
    } else if (!GetUtils.isEmail(email)) {
      emailError.value = 'Enter a valid email';
    }

    if (password.isEmpty) {
      passwordError.value = 'Password is required';
    } else if (password.length < 6) {
      passwordError.value = 'Minimum 6 characters';
    }

    return emailError.value == null && passwordError.value == null;
  }

  Future<void> onLoginTap() async {
    if (!_validate()) {
      return;
    }

    isLoading.value = true;
    PremiumDialogs.showLoading(
      title: 'Signing you in',
      subtitle: 'Checking account and role access...',
    );
    try {
      final UserRole role = await _authService.loginUser(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      PremiumDialogs.hideLoading();
      final bool confirmed = await PremiumDialogs.showStatus(
        success: true,
        title: 'Login successful',
        message: 'Welcome back. Redirecting to your dashboard.',
        buttonText: 'Continue',
        barrierDismissible: false,
      );
      if (!confirmed) return;

      Get.offAllNamed(
        role == UserRole.admin ? AppRoutes.adminHome : AppRoutes.userHome,
      );
    } catch (e) {
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: false,
        title: 'Login failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        buttonText: 'Close',
      );
      PremiumDialogs.hideLoading();
    } finally {
      isLoading.value = false;
    }
  }

  void onForgotPasswordTap() {
    Get.snackbar(
      'Not available yet',
      'Password recovery will be connected in backend phase.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
