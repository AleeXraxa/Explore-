import 'package:city_guide_app/app/data/models/user_role.dart';
import 'package:city_guide_app/app/data/services/auth_service.dart';
import 'package:city_guide_app/app/routes/app_routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AdminGuardMiddleware extends GetMiddleware {
  AdminGuardMiddleware() : super(priority: 1);

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(AuthService(), permanent: true);
    }
    final AuthService auth = Get.find<AuthService>();

    if (!auth.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }

    if (auth.currentRole.value != UserRole.admin) {
      return const RouteSettings(name: AppRoutes.userHome);
    }

    return null;
  }
}
