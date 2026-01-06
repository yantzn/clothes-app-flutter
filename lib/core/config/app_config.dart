import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  /// 環境変数から API ベースURLを取得します（必須）。
  /// `AppConfig.load()` 実行後に利用してください。
  static String get apiBaseUrl {
    final value = dotenv.env['API_BASE_URL'];
    if (value == null || value.isEmpty) {
      throw StateError(
        'API_BASE_URL is not set. Ensure the appropriate .env file is loaded.',
      );
    }
    return value;
  }

  static Future<void> load() async {
    final env = const String.fromEnvironment(
      'ENV',
      defaultValue: 'development',
    );
    final fileName = switch (env) {
      'production' => '.env.production',
      'staging' => '.env.staging',
      _ => '.env.development',
    };

    try {
      await dotenv.load(fileName: fileName);
      final fromEnv = dotenv.env['API_BASE_URL'];
      if (fromEnv == null || fromEnv.isEmpty) {
        throw StateError('API_BASE_URL is not set in $fileName');
      }
    } catch (e) {
      // 必須値のため、読み込み失敗や未設定時は例外を投げる
      throw StateError('Failed to load environment configuration: $e');
    }
  }
}
