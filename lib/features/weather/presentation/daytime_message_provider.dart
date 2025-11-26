import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'weather_providers.dart';

/// 時間帯別メッセージモデル
class DaytimeMessage {
  final String morning;
  final String afternoon;
  final String evening;
  final String night;
  final String tomorrowMorning;

  DaytimeMessage({
    required this.morning,
    required this.afternoon,
    required this.evening,
    required this.night,
    required this.tomorrowMorning,
  });
}

/// Provider
final daytimeMessageProvider = Provider<DaytimeMessage>((ref) {
  final weather = ref.watch(todayWeatherProvider).value;

  if (weather == null) {
    return DaytimeMessage(
      morning: "天気情報を読み込み中です。",
      afternoon: "",
      evening: "",
      night: "",
      tomorrowMorning: "",
    );
  }

  final temp = weather.value;
  final feels = weather.feelsLike;
  final wind = weather.windSpeed;

  // -----------------------------
  // 朝のメッセージ
  // -----------------------------
  final morning = _buildMorningMessage(temp, feels, wind);

  // -----------------------------
  // 昼のメッセージ
  // -----------------------------
  final afternoon = _buildAfternoonMessage(temp, feels);

  // -----------------------------
  // 夕方のメッセージ
  // -----------------------------
  final evening = _buildEveningMessage(temp);

  // -----------------------------
  // 夜のメッセージ
  // -----------------------------
  final night = _buildNightMessage(feels);

  // -----------------------------
  // 明日の朝
  // （現状は同じデータで仮の文言）
  // -----------------------------
  final tomorrowMorning = "明日の朝も冷え込みが予想されます。上着の準備をしておきましょう。";

  return DaytimeMessage(
    morning: morning,
    afternoon: afternoon,
    evening: evening,
    night: night,
    tomorrowMorning: tomorrowMorning,
  );
});

//
// ---------------------------------------------------------
// メッセージ生成（個別関数）
// ---------------------------------------------------------

String _buildMorningMessage(double t, double feels, double wind) {
  if (feels < 5) return "今朝はしっかり冷え込んでいます。暖かい上着でお出かけください。";
  if (feels < 10) return "今朝は肌寒いです。薄手パーカーなどの羽織りがあると安心です。";
  if (feels < 18) return "今朝は過ごしやすい気温です。長袖Tシャツで快適に過ごせそうです。";
  return "今朝は暖かめです。薄着でも問題ありません。";
}

String _buildAfternoonMessage(double t, double feels) {
  if (t >= 25) return "昼は暑くなります。水分補給を忘れず、薄着で快適に過ごしましょう。";
  if (t >= 20) return "昼は暖かく、過ごしやすい気温です。半袖 or 薄手の長袖がおすすめ。";
  if (t >= 15) return "昼は適温です。薄手の長袖やライトパーカーで十分です。";
  return "昼も肌寒い見込みです。外出には羽織り物があると安心です。";
}

String _buildEveningMessage(double t) {
  if (t <= 10) return "夕方は冷え込みます。帰り道の防寒をしっかりしてください。";
  if (t <= 15) return "夕方は少し寒く感じるかもしれません。軽い上着があると良いです。";
  return "夕方も比較的暖かい予想です。薄手の服装で問題ありません。";
}

String _buildNightMessage(double feels) {
  if (feels < 8) return "夜は冷え込みが強まります。厚手の上着が必須です。";
  if (feels < 15) return "夜は少し冷えます。軽めの防寒対策をしておきましょう。";
  return "夜も暖かめの予報です。薄手でも十分過ごせます。";
}
