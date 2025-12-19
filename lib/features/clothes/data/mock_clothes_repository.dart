import 'dart:async';
import '../domain/entities/clothes_suggestion.dart';
import '../domain/entities/rakuten_product.dart';
import '../domain/repositories/clothes_repository.dart';

/// モックの服装データ
class MockClothesRepository implements ClothesRepository {
  @override
  Future<ClothesSuggestion> fetchTodayClothes(String locationId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 疑似通信遅延

    return const ClothesSuggestion(
      userId: "test-user-3",
      ageGroup: "child",
      temperature: const TemperatureInfo(
        value: 18.5,
        feelsLike: 17.8,
        category: "cool",
      ),
      summary: "薄手の長袖と軽めの羽織りがちょうど良い気温です。",
      layers: const ["長袖Tシャツ", "薄手パーカー", "ロングパンツ"],
      notes: const ["風が強い場合は薄手の羽織りを追加すると安心です"],
      references: const ["https://www.ncchd.go.jp/"],

      /// ⭐ モックの楽天商品リスト
      products: const [
        RakutenProduct(
          name: "キッズ 長袖Tシャツ（男の子・女の子）",
          price: 1290,
          shop: "子ども服のABC",
          imageUrl:
              "https://thumbnail.image.rakuten.co.jp/@0_mall/example01.jpg",
        ),
        RakutenProduct(
          name: "薄手パーカー（春・秋用）",
          price: 1990,
          shop: "KIDS STYLE SHOP",
          imageUrl:
              "https://thumbnail.image.rakuten.co.jp/@0_mall/example02.jpg",
        ),
        RakutenProduct(
          name: "キッズ ロングパンツ 110cm〜130cm",
          price: 1780,
          shop: "HAPPY KIDS MARKET",
          imageUrl:
              "https://thumbnail.image.rakuten.co.jp/@0_mall/example03.jpg",
        ),
      ],
    );
  }

  /// 家族（ニックネーム）向けの今日の服装提案（モック）
  @override
  Future<ClothesSuggestion> fetchFamilyTodayClothes(String nickname) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // ニックネームで軽く差別化（本来は年齢・性別等で補正）
    final lower = nickname.toLowerCase();
    if (lower.contains('たろう') || lower.contains('太郎')) {
      return ClothesSuggestion(
        userId: 'mock-tarou',
        ageGroup: 'child',
        temperature: const TemperatureInfo(
          value: 21.0,
          feelsLike: 20.5,
          category: 'mild',
        ),
        summary: '半袖＋薄手羽織で快適（たろう向け）',
        layers: const ['半袖Tシャツ', '薄手パーカー', '動きやすいパンツ'],
        notes: const ['汗をかきやすい場合はインナー追加も可'],
        references: const ['https://www.ncchd.go.jp/'],
        products: const [
          const RakutenProduct(
            name: 'キッズ 半袖Tシャツ',
            price: 990,
            shop: 'KIDS BASIC',
            imageUrl:
                'https://thumbnail.image.rakuten.co.jp/@0_mall/example13.jpg',
          ),
          const RakutenProduct(
            name: 'キッズ 薄手パーカー（ライト）',
            price: 1890,
            shop: 'HAPPY KIDS MARKET',
            imageUrl:
                'https://thumbnail.image.rakuten.co.jp/@0_mall/example14.jpg',
          ),
        ],
      );
    }
    if (lower.contains('パパ') || lower.contains('父') || lower.contains('dad')) {
      return ClothesSuggestion(
        userId: 'mock-dad',
        ageGroup: 'adult',
        temperature: const TemperatureInfo(
          value: 18.0,
          feelsLike: 17.0,
          category: 'cool',
        ),
        summary: '薄手の長袖＋軽めのジャケットがおすすめ（パパ向け）',
        layers: const ['長袖シャツ', 'ライトジャケット', 'チノパン'],
        notes: const ['朝晩は冷えるため羽織り推奨'],
        references: const ['https://www.ncchd.go.jp/'],
        products: const [
          const RakutenProduct(
            name: 'メンズ ライトジャケット',
            price: 3990,
            shop: 'MEN STYLE',
            imageUrl:
                'https://thumbnail.image.rakuten.co.jp/@0_mall/example10.jpg',
          ),
        ],
      );
    }

    if (lower.contains('娘') ||
        lower.contains('girl') ||
        lower.contains('daughter')) {
      return ClothesSuggestion(
        userId: 'mock-daughter',
        ageGroup: 'child',
        temperature: const TemperatureInfo(
          value: 19.0,
          feelsLike: 18.0,
          category: 'cool',
        ),
        summary: '薄手の長袖＋スカートorパンツの軽めコーデ（娘向け）',
        layers: const ['長袖Tシャツ', '薄手カーディガン', 'スカート'],
        notes: const ['外遊びが多い日はパンツに変更'],
        references: const ['https://www.ncchd.go.jp/'],
        products: const [
          const RakutenProduct(
            name: 'キッズ カーディガン',
            price: 2190,
            shop: 'KIDS STYLE SHOP',
            imageUrl:
                'https://thumbnail.image.rakuten.co.jp/@0_mall/example11.jpg',
          ),
        ],
      );
    }

    if (lower.contains('息子') ||
        lower.contains('boy') ||
        lower.contains('son')) {
      return ClothesSuggestion(
        userId: 'mock-son',
        ageGroup: 'child',
        temperature: const TemperatureInfo(
          value: 20.0,
          feelsLike: 19.0,
          category: 'cool',
        ),
        summary: '動きやすい薄手トップス＋パンツ（息子向け）',
        layers: const ['長袖Tシャツ', '薄手パーカー', 'ロングパンツ'],
        notes: const ['汗対策にインナーを1枚追加も可'],
        references: const ['https://www.ncchd.go.jp/'],
        products: const [
          const RakutenProduct(
            name: 'キッズ 薄手パーカー',
            price: 1990,
            shop: 'HAPPY KIDS MARKET',
            imageUrl:
                'https://thumbnail.image.rakuten.co.jp/@0_mall/example12.jpg',
          ),
        ],
      );
    }

    // デフォルト（自分など）
    return ClothesSuggestion(
      userId: 'mock-self',
      ageGroup: 'adult',
      temperature: const TemperatureInfo(
        value: 18.5,
        feelsLike: 17.8,
        category: 'cool',
      ),
      summary: '薄手の長袖と軽めの羽織りがちょうど良い（自分向け）',
      layers: const ['長袖Tシャツ', '薄手パーカー', 'ロングパンツ'],
      notes: const ['風が強い日はジャケット追加'],
      references: const ['https://www.ncchd.go.jp/'],
      products: const [
        const RakutenProduct(
          name: 'ユニセックス 長袖Tシャツ',
          price: 1290,
          shop: 'BASIC STORE',
          imageUrl:
              'https://thumbnail.image.rakuten.co.jp/@0_mall/example01.jpg',
        ),
      ],
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
