import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clothes_app/features/clothes/domain/entities/clothes_suggestion.dart';
import 'package:clothes_app/features/clothes/presentation/scene_clothes_provider.dart';

/// 家族ごとの服装提案(AsyncValue)を、UI 表示用の SceneClothes に変換する純関数。
/// - UI からロジックを分離してテスト容易性を高める目的。
List<SceneClothes> mapFamilySuggestionsToScenes(
  List<String> labels,
  Map<String, AsyncValue<ClothesSuggestion>> suggestionsMap,
) {
  return labels.map((label) {
    final async = suggestionsMap[label];
    String displayLabel = label; // Homeのmember.nameをそのまま表示
    // ローディング時も前回値を維持してフリッカーを抑制
    List<String> items = async?.value?.layers ?? const [];
    String comment = async?.value?.summary ?? '';

    if (async != null) {
      async.when(
        data: (c) {
          // タブ名は Home レスポンスの name（labels）を優先
          items = List<String>.from(c.layers);
          comment = c.summary;
        },
        loading: () {
          // 直前値を維持（何もしない）
        },
        error: (err, st) {
          comment = '服装データを取得できませんでした';
        },
      );
    }

    return SceneClothes(
      scene: displayLabel,
      comment: comment,
      items: items,
      notes: async?.value?.notes,
      ageGroup: async?.value?.ageGroup,
    );
  }).toList();
}
