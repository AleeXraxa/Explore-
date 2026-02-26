import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileEditController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final nameFocus = FocusNode();
  final emailFocus = FocusNode();
  final phoneFocus = FocusNode();

  final isSaving = false.obs;
  final nameError = RxnString();
  final emailError = RxnString();
  final phoneError = RxnString();

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args =
        (Get.arguments as Map<String, dynamic>?) ?? <String, dynamic>{};
    nameController.text = (args['name'] as String?) ?? '';
    emailController.text = (args['email'] as String?) ?? '';
    phoneController.text = (args['phone'] as String?) ?? '';
  }

  bool _validate() {
    nameError.value = null;
    emailError.value = null;
    phoneError.value = null;

    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String phone = phoneController.text.trim();

    if (name.length < 2) {
      nameError.value = 'Please enter valid name';
    }
    if (!GetUtils.isEmail(email)) {
      emailError.value = 'Please enter valid email';
    }
    if (phone.length < 7) {
      phoneError.value = 'Please enter valid contact number';
    }

    return nameError.value == null &&
        emailError.value == null &&
        phoneError.value == null;
  }

  Future<void> saveProfile() async {
    if (!_validate()) return;

    isSaving.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 450));
    isSaving.value = false;

    Get.back<Map<String, dynamic>>(
      result: <String, dynamic>{
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
      },
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    nameFocus.dispose();
    emailFocus.dispose();
    phoneFocus.dispose();
    super.onClose();
  }
}
