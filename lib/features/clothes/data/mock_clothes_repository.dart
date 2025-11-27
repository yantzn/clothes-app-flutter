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
      temperature: TemperatureInfo(
        value: 18.5,
        feelsLike: 17.8,
        category: "cool",
      ),
      summary: "薄手の長袖と軽めの羽織りがちょうど良い気温です。",
      layers: ["長袖Tシャツ", "薄手パーカー", "ロングパンツ"],
      notes: ["風が強い場合は薄手の羽織りを追加すると安心です"],
      references: ["https://www.ncchd.go.jp/"],

      /// ⭐ モックの楽天商品リスト
      products: [
        RakutenProduct(
          name: "キッズ 長袖Tシャツ（男の子・女の子）",
          price: 1290,
          shop: "子ども服のABC",
          imageUrl:
              "https://thumbnail.image.rakuten.co.jp/@0_mall/example01.jpg",
          url: "https://item.rakuten.co.jp/example01",
        ),
        RakutenProduct(
          name: "薄手パーカー（春・秋用）",
          price: 1990,
          shop: "KIDS STYLE SHOP",
          imageUrl:
              "https://thumbnail.image.rakuten.co.jp/@0_mall/example02.jpg",
          url: "https://item.rakuten.co.jp/example02",
        ),
        RakutenProduct(
          name: "キッズ ロングパンツ 110cm〜130cm",
          price: 1780,
          shop: "HAPPY KIDS MARKET",
          imageUrl:
              "https://thumbnail.image.rakuten.co.jp/@0_mall/example03.jpg",
          url: "https://item.rakuten.co.jp/example03",
        ),
      ],
    );
  }
}
