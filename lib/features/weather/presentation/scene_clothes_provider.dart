// features/clothes/presentation/providers/scene_clothes_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sceneClothesProvider = Provider<Map<String, List<String>>>((ref) {
  return {
    "おでかけ": ["長袖Tシャツ", "薄手パーカー"],
    "室内": ["薄手Tシャツ", "トレーナー"],
    "園・学校": ["長袖Tシャツ", "薄手アウター"],
  };
});
