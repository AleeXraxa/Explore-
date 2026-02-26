import 'dart:async';

import 'package:city_guide_app/app/routes/app_routes.dart';
import 'package:city_guide_app/core/constants/app_durations.dart';
import 'package:flutter/animation.dart';
import 'package:get/get.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final RxDouble sceneOpacity = 1.0.obs;
  final RxDouble logoOpacity = 0.0.obs;
  final RxDouble logoScale = 0.94.obs;
  final RxDouble pulseValue = 0.0.obs;
  final RxBool showLoader = false.obs;

  late final AnimationController pulseController;
  final List<Timer> _timers = <Timer>[];

  @override
  void onInit() {
    super.onInit();
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDurations.pulseMs),
    );
    pulseController.addListener(() {
      pulseValue.value = pulseController.value;
    });

    _runAnimationAndNavigate();
  }

  void _runAnimationAndNavigate() {
    _timers.add(
      Timer(
        const Duration(milliseconds: AppDurations.logoFadeScaleDelayMs),
        () {
          logoOpacity.value = 1;
          logoScale.value = 1;
        },
      ),
    );

    _timers.add(
      Timer(
        const Duration(milliseconds: AppDurations.glowStartMs),
        () => pulseController.repeat(reverse: true),
      ),
    );

    _timers.add(
      Timer(
        const Duration(milliseconds: AppDurations.loaderAppearMs),
        () => showLoader.value = true,
      ),
    );

    _timers.add(
      Timer(
        const Duration(milliseconds: AppDurations.fadeOutStartMs),
        () => sceneOpacity.value = 0,
      ),
    );

    _timers.add(
      Timer(
        const Duration(milliseconds: AppDurations.splashTotalMs),
        () => Get.offNamed(AppRoutes.login),
      ),
    );
  }

  @override
  void onClose() {
    for (final Timer timer in _timers) {
      timer.cancel();
    }
    pulseController.dispose();
    super.onClose();
  }
}
