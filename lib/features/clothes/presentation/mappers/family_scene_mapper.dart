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
    String displayLabel = label;
    List<String> items = const [];
    String comment = '';

    if (async != null) {
      async.when(
        data: (c) {
          displayLabel = canonicalNickname(c);
          items = List<String>.from(c.layers ?? const []);
          comment = c.summary ?? '';
        },
        loading: () {
          comment = '読み込み中…';
        },
        error: (_, __) {
          comment = '服装データを取得できませんでした';
        },
      );
    }

    return SceneClothes(
      scene: displayLabel,
      comment: comment,
      items: items,
      medicalNote: null,
    );
  }).toList();
}

/// 提案に含まれるID/年齢層から表示用のニックネームへ正規化
String canonicalNickname(ClothesSuggestion c) {
  final id = (c.userId ?? '').toLowerCase();
  if (id.contains('dad')) return 'パパ';
  if (id.contains('daughter')) return '娘';
  if (id.contains('son')) return '息子';
  if (id.contains('tarou') || id.contains('self')) return 'たろう';

  switch ((c.ageGroup ?? '').toLowerCase()) {
    case 'child':
      return 'こども';
    case 'adult':
      return 'おとな';
    default:
      return '家族';
  }
}
