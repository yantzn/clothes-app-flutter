class TemperatureInfo {
  final double value;
  final double feelsLike;
  final String category;

  const TemperatureInfo({
    required this.value,
    required this.feelsLike,
    required this.category,
  });
}

class Product {
  final String name;
  final String url;
  final String image;
  final int price;
  final String shop;

  const Product({
    required this.name,
    required this.url,
    required this.image,
    required this.price,
    required this.shop,
  });
}

class ClothesSuggestion {
  /// 例:
  /// 「やや肌寒い気温では、長袖Tシャツと薄手パーカーなどで体温調節を行います。」
  final String summary;

  /// 重ね着の構成（例: ["長袖Tシャツ", "薄手パーカー"]）
  final List<String> layers;

  /// 注意点や補足メモ
  final List<String> notes;

  /// 参考リンク（URL）
  final List<String> references;

  /// 気温情報
  final TemperatureInfo temperature;

  /// 楽天などの関連商品
  final List<Product> products;

  const ClothesSuggestion({
    required this.summary,
    required this.layers,
    required this.notes,
    required this.references,
    required this.temperature,
    required this.products,
  });
}
