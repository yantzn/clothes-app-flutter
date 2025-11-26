import '../entities/weather.dart';

/// 天気情報取得のための抽象リポジトリ
abstract class WeatherRepository {
  /// 指定された [region] の「今日の天気」を取得する
  Future<TodayWeather> fetchTodayWeather(String region);
}
