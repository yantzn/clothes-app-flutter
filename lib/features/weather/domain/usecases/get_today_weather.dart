import '../entities/weather.dart';
import '../repositories/weather_repository.dart';

/// 「今日の天気」を取得するユースケース
///
/// Presentation 層 → UseCase → Repository → DataSource
class GetTodayWeather {
  final WeatherRepository repository;

  const GetTodayWeather(this.repository);

  Future<TodayWeather> call(String region) {
    return repository.fetchTodayWeather(region);
  }
}
