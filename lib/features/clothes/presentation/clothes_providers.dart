import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/clothes_suggestion.dart';
// Repository経由の取得は廃止し、Homeのスナップショットから派生
import 'package:clothes_app/features/home/presentation/home_providers.dart';
import 'package:clothes_app/features/home/domain/entities/home_today.dart'
    as hd;

// Repository経由の取得は行わないため、DIは不要

/// 家族（ニックネーム）向けの今日の服装提案
final familyTodayClothesProvider =
    FutureProvider.family<ClothesSuggestion, String>((ref, nickname) async {
      final hd.HomeToday home = await ref.watch(homeSnapshotProvider.future);
      final member = home.members.firstWhere(
        (m) => m.name == nickname,
        orElse: () => (home.members.isNotEmpty ? home.members.first : null)!,
      );
      return ClothesSuggestion(
        userId: '',
        ageGroup: member.ageGroup,
        temperature: TemperatureInfo(
          value: home.weather.value,
          feelsLike: home.weather.feelsLike,
          category: home.weather.category,
        ),
        summary: member.suggestion.summary,
        layers: member.suggestion.layers,
        notes: member.suggestion.notes,
        references: const [],
      );
    });

/// 自分（デフォルトユーザー）のニックネーム取得（API/モック）
final selfNicknameProvider = FutureProvider<String>((ref) async {
  final hd.HomeToday home = await ref.watch(homeSnapshotProvider.future);
  return home.members.isNotEmpty ? home.members.first.name : '';
});

/// 家族（表示用ニックネーム一覧）取得（API/モック）
final familyNicknamesProvider = FutureProvider<List<String>>((ref) async {
  final hd.HomeToday home = await ref.watch(homeSnapshotProvider.future);
  return home.members.map((m) => m.name).toList();
});

/// 今日の服装（AsyncNotifier / autoDispose）
final todayClothesProvider = FutureProvider<ClothesSuggestion>((ref) async {
  final hd.HomeToday home = await ref.watch(homeSnapshotProvider.future);
  final member = home.members.isNotEmpty ? home.members.first : null;
  final summary = member?.suggestion.summary ?? home.summary;
  final layers = member?.suggestion.layers ?? const [];
  return ClothesSuggestion(
    userId: '',
    ageGroup: member?.ageGroup ?? '',
    temperature: TemperatureInfo(
      value: home.weather.value,
      feelsLike: home.weather.feelsLike,
      category: home.weather.category,
    ),
    summary: summary,
    layers: layers,
    notes: member?.suggestion.notes ?? const [],
    references: const [],
  );
});
