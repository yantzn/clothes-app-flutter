import '../entities/clothes_suggestion.dart';

/// 今日の服装提案を取得するための抽象リポジトリ
///
/// data 層で API / mock / キャッシュ などに差し替える
abstract class ClothesRepository {
  /// [userId] をもとに今日の服装提案を取得する
  Future<ClothesSuggestion> fetchTodayClothes(String userId);
}
