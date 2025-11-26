import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../clothes/domain/entities/clothes_suggestion.dart';
import '../../clothes/domain/repositories/clothes_repository.dart';
import '../../clothes/data/mock_clothes_repository.dart';

/// Repository（DI）
final clothesRepositoryProvider = Provider<ClothesRepository>((ref) {
  return MockClothesRepository();
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
