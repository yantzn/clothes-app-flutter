import 'dart:async';
import '../domain/entities/clothes_suggestion.dart';
import '../domain/repositories/clothes_repository.dart';

class MockClothesRepository implements ClothesRepository {
  @override
  Future<ClothesSuggestion> fetchTodayClothes(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return const ClothesSuggestion(
      summary: "やや肌寒い気温では、長袖Tシャツと薄手パーカーなどで体温調節を行います。",
      layers: ["長袖Tシャツ", "薄手パーカー"],
      notes: [
        "国立成育医療研究センターによると、気温差に応じた重ね着は児童でも重要で、特に朝夕の寒暖差には脱ぎ着しやすい服装が適しています。",
        "風が強い日は体感温度が下がるため、薄手パーカーでの防風対策が推奨されます。",
      ],
      references: ["https://www.ncchd.go.jp/"],
      temperature: TemperatureInfo(
        value: 15.49,
        feelsLike: 14.53,
        category: "cool",
      ),
      products: [
        Product(
          name:
              "【LIMITED SALE 最大18%OFF】【送料無料】綿100％ デビラボ BIGシルエット プリント袖リブ 長袖Tシャツ",
          url:
              "https://hb.afl.rakuten.co.jp/hgc/g00qnh8l.s67kod0f.g00qnh8l.s67kpf25/?pc=https%3A%2F%2Fitem.rakuten.co.jp%2Fdevirockstore%2F10001221%2F&m=http%3A%2F%2Fm.rakuten.co.jp%2Fdevirockstore%2Fi%2F10002801%2F",
          image:
              "https://thumbnail.image.rakuten.co.jp/@0_mall/devirockstore/cabinet/itempage/25aw/1udl19038/1udl19038-01.jpg?_ex=128x128",
          price: 898,
          shop: "devirock 楽天市場店",
        ),
        Product(
          name: "ゆうパケ送料無料 キッズ Tシャツ 長袖 綿100％ ロンT 子供服 男の子 女の子",
          url:
              "https://hb.afl.rakuten.co.jp/hgc/g00rcl9l.s67ko552.g00rcl9l.s67kp4b4/?pc=https%3A%2F%2Fitem.rakuten.co.jp%2Fchildren-tsuushin%2F26278709%2F",
          image:
              "https://thumbnail.image.rakuten.co.jp/@0_mall/children-tsuushin/cabinet/2025autumn/14251381.jpg?_ex=128x128",
          price: 854,
          shop: "chil2 楽天市場店",
        ),
        Product(
          name: "名入れ パーカー アメカジ パーカーおしゃれ",
          url:
              "https://hb.afl.rakuten.co.jp/hgc/g00s3ddl.s67koad7.g00s3ddl.s67kpc9f/?pc=https%3A%2F%2Fitem.rakuten.co.jp%2Fclover-gj%2Fcl-print-amekaji-p%2F",
          image:
              "https://thumbnail.image.rakuten.co.jp/@0_mall/clover-gj/cabinet/06528286/07788331/or-ak-p-1.jpg?_ex=128x128",
          price: 2800,
          shop: "ORICLO",
        ),
      ],
    );
  }
}
