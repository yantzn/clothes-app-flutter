import 'package:flutter/material.dart';

// ---- Onboarding ----
import '../features/onboarding/terms_page.dart';
import '../features/onboarding/register_user_info_page.dart';
import '../features/onboarding/register_family_page.dart';
import '../features/onboarding/confirm_register_page.dart';

// ---- Main UI ----
import '../features/ui/splash_page.dart';
import '../features/ui/home_page.dart';
import '../features/ui/weather_detail_page.dart';
import '../features/ui/clothes_detail_page.dart';
import '../features/ui/profile_view_page.dart';
import '../features/ui/profile_edit_page.dart';
import '../features/ui/settings_page.dart';

class AppRouter {
  // ---- 初期表示 ----
  static const splash = '/splash';

  // ---- オンボーディング（初回登録） ----
  static const terms = '/onboarding/terms';
  static const registerUserInfo = '/onboarding/register/user';
  static const registerFamily = '/onboarding/register/family';
  static const confirmRegister = '/onboarding/register/confirm';

  // ---- メイン画面 ----
  static const home = '/';
  static const weatherDetail = '/weather/detail';
  static const clothesDetail = '/clothes/detail';

  // ---- プロフィール ----
  static const profileView = '/profile/view';
  static const profileEdit = '/profile/edit';

  // ---- 設定 ----
  static const settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings routesettings) {
    switch (routesettings.name) {
      // ---------------------------------------------
      // Splash
      // ---------------------------------------------
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      // ---------------------------------------------
      // Onboarding（利用規約 → ユーザ情報 → 家族 → 最終確認）
      // ---------------------------------------------
      case terms:
        return MaterialPageRoute(builder: (_) => const TermsPage());

      case registerUserInfo:
        return MaterialPageRoute(builder: (_) => const RegisterUserInfoPage());

      case registerFamily:
        return MaterialPageRoute(builder: (_) => const RegisterFamilyPage());

      case confirmRegister:
        return MaterialPageRoute(builder: (_) => const ConfirmRegisterPage());

      // ---------------------------------------------
      // Main
      // ---------------------------------------------
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case weatherDetail:
        return MaterialPageRoute(builder: (_) => const WeatherDetailPage());

      case clothesDetail:
        return MaterialPageRoute(builder: (_) => const ClothesDetailPage());

      // ---------------------------------------------
      // Profile
      // ---------------------------------------------
      case profileView:
        return MaterialPageRoute(builder: (_) => const ProfileViewPage());

      case profileEdit:
        return MaterialPageRoute(builder: (_) => const ProfileEditPage());

      // ---------------------------------------------
      // Settings
      // ---------------------------------------------
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());

      // ---------------------------------------------
      // Not Found
      // ---------------------------------------------
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('ページが見つかりません'))),
        );
    }
  }
}
