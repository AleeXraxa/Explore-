import 'package:city_guide_app/app/modules/admin_home/bindings/admin_home_binding.dart';
import 'package:city_guide_app/app/modules/admin_home/views/admin_home_view.dart';
import 'package:city_guide_app/app/modules/login/bindings/login_binding.dart';
import 'package:city_guide_app/app/modules/login/views/login_view.dart';
import 'package:city_guide_app/app/modules/place_details/bindings/place_details_binding.dart';
import 'package:city_guide_app/app/modules/place_details/views/place_details_view.dart';
import 'package:city_guide_app/app/modules/profile_edit/bindings/profile_edit_binding.dart';
import 'package:city_guide_app/app/modules/profile_edit/views/profile_edit_view.dart';
import 'package:city_guide_app/app/modules/register/bindings/register_binding.dart';
import 'package:city_guide_app/app/modules/register/views/register_view.dart';
import 'package:city_guide_app/app/modules/splash/bindings/splash_binding.dart';
import 'package:city_guide_app/app/modules/splash/views/splash_view.dart';
import 'package:city_guide_app/app/modules/user_home/bindings/user_home_binding.dart';
import 'package:city_guide_app/app/modules/user_home/views/user_home_view.dart';
import 'package:city_guide_app/app/routes/app_routes.dart';
import 'package:city_guide_app/app/routes/middlewares/admin_guard_middleware.dart';
import 'package:get/get.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: SplashView.new,
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.login,
      page: LoginView.new,
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 420),
    ),
    GetPage(
      name: AppRoutes.register,
      page: RegisterView.new,
      binding: RegisterBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 460),
    ),
    GetPage(
      name: AppRoutes.adminHome,
      page: AdminHomeView.new,
      binding: AdminHomeBinding(),
      middlewares: <GetMiddleware>[AdminGuardMiddleware()],
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 380),
    ),
    GetPage(
      name: AppRoutes.userHome,
      page: UserHomeView.new,
      binding: UserHomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 380),
    ),
    GetPage(
      name: AppRoutes.placeDetails,
      page: PlaceDetailsView.new,
      binding: PlaceDetailsBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 360),
    ),
    GetPage(
      name: AppRoutes.profileEdit,
      page: ProfileEditView.new,
      binding: ProfileEditBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 340),
    ),
  ];
}
