import 'dart:async';
import '../domain/entities/clothes_suggestion.dart';
import '../domain/repositories/clothes_repository.dart';

/// モックの服装データ
class MockClothesRepository implements ClothesRepository {
  @override
  Future<ClothesSuggestion> fetchTodayClothes(String locationId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 疑似通信遅延

    return const ClothesSuggestion(
      userId: "test-user-3",
      ageGroup: "child",
      temperature: TemperatureInfo(
        value: 18.5,
        feelsLike: 17.8,
        category: "cool",
      ),
      summary: "薄手の長袖と軽めの羽織りがちょうど良い気温です。",
      layers: ["長袖Tシャツ", "薄手パーカー", "ロングパンツ"],
      notes: ["風が強い場合は薄手の羽織りを追加すると安心です"],
      references: ["https://www.ncchd.go.jp/"],
    );
  }

  /// 家族（ニックネーム）向けの今日の服装提案（モック）
  @override
  Future<ClothesSuggestion> fetchFamilyTodayClothes(String nickname) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // ニックネームで軽く差別化（本来は年齢・性別等で補正）
    final lower = nickname.toLowerCase();
    if (lower.contains('たろう') || lower.contains('太郎')) {
      return const ClothesSuggestion(
        userId: 'mock-tarou',
        ageGroup: 'child',
        temperature: TemperatureInfo(
          value: 21.0,
          feelsLike: 20.5,
          category: 'mild',
        ),
        summary: '半袖＋薄手羽織で快適（たろう向け）',
        layers: ['半袖Tシャツ', '薄手パーカー', '動きやすいパンツ'],
        notes: ['汗をかきやすい場合はインナー追加も可'],
        references: ['https://www.ncchd.go.jp/'],
      );
    }
    if (lower.contains('パパ') || lower.contains('父') || lower.contains('dad')) {
      return const ClothesSuggestion(
        userId: 'mock-dad',
        ageGroup: 'adult',
        temperature: TemperatureInfo(
          value: 18.0,
          feelsLike: 17.0,
          category: 'cool',
        ),
        summary: '薄手の長袖＋軽めのジャケットがおすすめ（パパ向け）',
        layers: ['長袖シャツ', 'ライトジャケット', 'チノパン'],
        notes: ['朝晩は冷えるため羽織り推奨'],
        references: ['https://www.ncchd.go.jp/'],
      );
    }

    if (lower.contains('娘') ||
        lower.contains('girl') ||
        lower.contains('daughter')) {
      return const ClothesSuggestion(
        userId: 'mock-daughter',
        ageGroup: 'child',
        temperature: TemperatureInfo(
          value: 19.0,
          feelsLike: 18.0,
          category: 'cool',
        ),
        summary: '薄手の長袖＋スカートorパンツの軽めコーデ（娘向け）',
        layers: ['長袖Tシャツ', '薄手カーディガン', 'スカート'],
        notes: ['外遊びが多い日はパンツに変更'],
        references: ['https://www.ncchd.go.jp/'],
      );
    }

    if (lower.contains('息子') ||
        lower.contains('boy') ||
        lower.contains('son')) {
      return const ClothesSuggestion(
        userId: 'mock-son',
        ageGroup: 'child',
        temperature: TemperatureInfo(
          value: 20.0,
          feelsLike: 19.0,
          category: 'cool',
        ),
        summary: '動きやすい薄手トップス＋パンツ（息子向け）',
        layers: ['長袖Tシャツ', '薄手パーカー', 'ロングパンツ'],
        notes: ['汗対策にインナーを1枚追加も可'],
        references: ['https://www.ncchd.go.jp/'],
      );
    }

    // デフォルト（自分など）
    return const ClothesSuggestion(
      userId: 'mock-self',
      ageGroup: 'adult',
      temperature: TemperatureInfo(
        value: 18.5,
        feelsLike: 17.8,
        category: 'cool',
      ),
      summary: '薄手の長袖と軽めの羽織りがちょうど良い（自分向け）',
      layers: ['長袖Tシャツ', '薄手パーカー', 'ロングパンツ'],
      notes: ['風が強い日はジャケット追加'],
      references: ['https://www.ncchd.go.jp/'],
    );
  }

  @override
  Future<String> fetchSelfNickname() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return 'たろう';
  }

  @override
  Future<List<String>> fetchFamilyNicknames() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // API ではユーザー設定に紐づく家族一覧を返す想定
    // モックでは代表ロール＋自分を返す
    return const ['たろう', 'パパ', '娘', '息子'];
  }
}
