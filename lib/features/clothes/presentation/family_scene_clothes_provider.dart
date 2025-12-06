import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'clothes_providers.dart';
import '../domain/entities/clothes_suggestion.dart';

/// 家族（ニックネーム）ごとの今日の服装提案（API/モック）をまとめて返す Provider。
/// UI はこの Map から選択中のニックネームの AsyncValue を取り出して表示できます。
final familySuggestionsProvider =
    Provider<Map<String, AsyncValue<ClothesSuggestion>>>((ref) {
      final nicknamesAsync = ref.watch(familyNicknamesProvider);

      final Map<String, AsyncValue<ClothesSuggestion>> result = {};
      nicknamesAsync.when(
        data: (names) {
          for (final nickname in names) {
            result[nickname] = ref.watch(familyTodayClothesProvider(nickname));
          }
        },
        loading: () {},
        error: (_, __) {},
      );
      return result;
    });
