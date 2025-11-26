/// 今日の天気情報（アプリ内部で使うドメインモデル）
class TodayWeather {
  final String region; // 例: "船橋"
  final double value; // 気温
  final double feelsLike; // 体感温度
  final int humidity; // 湿度 (%)
  final double windSpeed; // 風速 (m/s)
  final String category; // "cold" / "cool" / "warm" など
  final String condition; // 'sunny', 'cloudy', 'rain', 'snow' など

  const TodayWeather({
    required this.region,
    required this.value,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.category,
    required this.condition,
  });
}
