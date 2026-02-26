import 'package:city_guide_app/app/modules/profile_edit/controllers/profile_edit_controller.dart';
import 'package:city_guide_app/app/shared/widgets/custom_text_field.dart';
import 'package:city_guide_app/app/shared/widgets/primary_button.dart';
import 'package:city_guide_app/core/constants/app_spacing.dart';
import 'package:city_guide_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProfileEditView extends GetView<ProfileEditController> {
  const ProfileEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Update your personal information',
                style: AppTextStyles.body,
              ),
              SizedBox(height: AppSpacing.xl.h),
              Obx(
                () => CustomTextField(
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person_outline_rounded,
                  controller: controller.nameController,
                  focusNode: controller.nameFocus,
                  textInputAction: TextInputAction.next,
                  errorText: controller.nameError.value,
                  onSubmitted: (_) => controller.emailFocus.requestFocus(),
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              Obx(
                () => CustomTextField(
                  label: 'Email',
                  hintText: 'name@email.com',
                  prefixIcon: Icons.mail_outline_rounded,
                  controller: controller.emailController,
                  focusNode: controller.emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  errorText: controller.emailError.value,
                  onSubmitted: (_) => controller.phoneFocus.requestFocus(),
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              Obx(
                () => CustomTextField(
                  label: 'Contact Number',
                  hintText: '+92 300 1234567',
                  prefixIcon: Icons.call_outlined,
                  controller: controller.phoneController,
                  focusNode: controller.phoneFocus,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  errorText: controller.phoneError.value,
                  onSubmitted: (_) => controller.saveProfile(),
                ),
              ),
              SizedBox(height: AppSpacing.xl.h),
              Obx(
                () => PrimaryButton(
                  text: 'Save Changes',
                  isLoading: controller.isSaving.value,
                  onPressed: controller.saveProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
