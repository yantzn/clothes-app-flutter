import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/clothes_suggestion.dart';
import '../domain/repositories/clothes_repository.dart';
import '../data/mock_clothes_repository.dart';

/// Repository（DI）
final clothesRepositoryProvider = Provider<ClothesRepository>((ref) {
  return MockClothesRepository();
});

/// 家族（ニックネーム）向けの今日の服装提案
final familyTodayClothesProvider =
    FutureProvider.family<ClothesSuggestion, String>((ref, nickname) async {
      final repo = ref.read(clothesRepositoryProvider);
      return repo.fetchFamilyTodayClothes(nickname);
    });

/// 自分（デフォルトユーザー）のニックネーム取得（API/モック）
final selfNicknameProvider = FutureProvider<String>((ref) async {
  final repo = ref.read(clothesRepositoryProvider);
  return repo.fetchSelfNickname();
});

/// 家族（表示用ニックネーム一覧）取得（API/モック）
final familyNicknamesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.read(clothesRepositoryProvider);
  return repo.fetchFamilyNicknames();
});

/// 今日の服装（AsyncNotifier / autoDispose）
final todayClothesProvider =
    AsyncNotifierProvider.autoDispose<TodayClothesNotifier, ClothesSuggestion>(
      TodayClothesNotifier.new,
    );

class TodayClothesNotifier extends AsyncNotifier<ClothesSuggestion> {
  @override
  Future<ClothesSuggestion> build() async {
    final repo = ref.read(clothesRepositoryProvider);
    return repo.fetchTodayClothes("test-user-3");
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(clothesRepositoryProvider);
      return repo.fetchTodayClothes("test-user-3");
    });
  }
}
