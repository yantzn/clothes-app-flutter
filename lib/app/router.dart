import 'package:flutter/material.dart';

import '../features/ui/splash_page.dart';
import '../features/ui/home_page.dart';
import '../features/ui/weather_detail_page.dart';
import '../features/ui/clothes_detail_page.dart';
import '../features/ui/profile_view_page.dart';
import '../features/ui/profile_edit_page.dart';
import '../features/ui/settings_page.dart';

class AppRouter {
  static const splash = '/splash';
  static const home = '/';
  static const weatherDetail = '/weather/detail';
  static const clothesDetail = '/clothes/detail';
  static const profileView = '/profile/view';
  static const profileEdit = '/profile/edit';
  static const settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouter.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case AppRouter.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case AppRouter.weatherDetail:
        return MaterialPageRoute(builder: (_) => const WeatherDetailPage());
      case AppRouter.clothesDetail:
        return MaterialPageRoute(builder: (_) => const ClothesDetailPage());
      case AppRouter.profileView:
        return MaterialPageRoute(builder: (_) => const ProfileViewPage());
      case AppRouter.profileEdit:
        return MaterialPageRoute(builder: (_) => const ProfileEditPage());
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('ページが見つかりません'))),
        );
    }
  }
}
