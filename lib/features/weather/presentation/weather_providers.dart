import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/weather.dart';
import '../../home/presentation/home_providers.dart';

/// 今日の天気（Home API 由来）
final todayWeatherProvider = FutureProvider<TodayWeather>((ref) async {
  return ref.watch(homeWeatherProvider.future);
});
