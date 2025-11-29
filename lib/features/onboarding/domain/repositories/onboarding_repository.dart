import '../entities/register_request.dart';

/// オンボーディング（初回登録）でサーバに送信するための抽象リポジトリ
abstract class OnboardingRepository {
  /// ユーザ＋家族情報を登録し、サーバ側で userId を発行して返す
  Future<String> registerUser(RegisterRequest request);
}
