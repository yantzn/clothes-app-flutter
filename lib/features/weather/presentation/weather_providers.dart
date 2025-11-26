import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/weather.dart';
import '../domain/repositories/weather_repository.dart';
import '../data/mock_weather_repository.dart';

/// Repository（DI）
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return MockWeatherRepository();
});

/// 今日の天気（AsyncNotifier / autoDispose）
final todayWeatherProvider =
    AsyncNotifierProvider.autoDispose<TodayWeatherNotifier, TodayWeather>(
      TodayWeatherNotifier.new,
    );

class TodayWeatherNotifier extends AsyncNotifier<TodayWeather> {
  @override
  Future<TodayWeather> build() async {
    final repo = ref.read(weatherRepositoryProvider);
    return repo.fetchTodayWeather("船橋");
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(weatherRepositoryProvider);
      return repo.fetchTodayWeather("船橋");
    });
  }
}
