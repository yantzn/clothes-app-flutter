import '../entities/clothes_suggestion.dart';

/// 今日の服装提案を取得するための抽象リポジトリ
///
/// data 層で API / mock / キャッシュ などに差し替える
abstract class ClothesRepository {
  /// [userId] をもとに今日の服装提案を取得する
  Future<ClothesSuggestion> fetchTodayClothes(String userId);

  /// ニックネーム（家族）をもとに今日の服装提案を取得する
  /// API 前提のため、data 層で差し替え可能にしておく
  Future<ClothesSuggestion> fetchFamilyTodayClothes(String nickname);

  /// 自分（デフォルトユーザー）のニックネームを取得する（API/モック）
  Future<String> fetchSelfNickname();

  /// 家族（表示用ニックネーム一覧）を取得する（API/モック）
  Future<List<String>> fetchFamilyNicknames();
}
