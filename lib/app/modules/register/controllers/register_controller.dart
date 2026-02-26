import 'package:city_guide_app/app/data/services/auth_service.dart';
import 'package:city_guide_app/app/shared/widgets/premium_dialogs.dart';
import 'package:city_guide_app/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  RegisterController(this._authService);

  final AuthService _authService;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final fullNameFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isLoading = false.obs;
  final passwordStrength = 0.0.obs;

  final fullNameError = RxnString();
  final emailError = RxnString();
  final passwordError = RxnString();
  final confirmPasswordError = RxnString();

  void onPasswordChanged(String value) {
    passwordStrength.value = _calculateStrength(value);
  }

  double _calculateStrength(String value) {
    if (value.isEmpty) return 0;

    double score = 0;
    if (value.length >= 8) score += 0.35;
    if (RegExp(r'[A-Z]').hasMatch(value)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(value)) score += 0.2;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score += 0.25;

    return score.clamp(0, 1);
  }

  bool _validate() {
    fullNameError.value = null;
    emailError.value = null;
    passwordError.value = null;
    confirmPasswordError.value = null;

    final String fullName = fullNameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;

    if (fullName.length < 2) {
      fullNameError.value = 'Enter your full name';
    }
    if (email.isEmpty) {
      emailError.value = 'Email is required';
    } else if (!GetUtils.isEmail(email)) {
      emailError.value = 'Enter a valid email';
    }
    if (password.length < 8) {
      passwordError.value = 'Use at least 8 characters';
    }
    if (confirmPassword != password) {
      confirmPasswordError.value = 'Passwords do not match';
    }

    return fullNameError.value == null &&
        emailError.value == null &&
        passwordError.value == null &&
        confirmPasswordError.value == null;
  }

  Future<void> onRegisterTap() async {
    if (!_validate()) {
      return;
    }

    isLoading.value = true;
    PremiumDialogs.showLoading(
      title: 'Setting up your account',
      subtitle: 'Securing profile and preferences...',
    );
    try {
      await _authService.registerUser(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      PremiumDialogs.hideLoading();
      final bool confirmed = await PremiumDialogs.showStatus(
        success: true,
        title: 'Registration successful',
        message: 'Your account is ready. Please log in to continue.',
        buttonText: 'Continue',
        barrierDismissible: false,
      );
      if (confirmed) {
        fullNameController.clear();
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      PremiumDialogs.hideLoading();
      await PremiumDialogs.showStatus(
        success: false,
        title: 'Registration failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        buttonText: 'Try Again',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goBackToLogin() {
    Get.back<void>();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.onClose();
  }
}
