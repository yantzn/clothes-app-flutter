import 'dart:async';
import '../../weather/domain/entities/weather.dart';
import '../../weather/domain/repositories/weather_repository.dart';

class MockWeatherRepository implements WeatherRepository {
  @override
  Future<TodayWeather> fetchTodayWeather(String region) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return TodayWeather(
      region: region,
      value: 9.02,
      feelsLike: 9.02,
      humidity: 90,
      windSpeed: 1.24,
      category: "cold",
      condition: "cloudy",
    );
  }
}
