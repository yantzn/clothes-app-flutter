/// 楽天商品データモデル
///
/// API レスポンス例：
/// {
///   "name": "キッズ パーカー",
///   "price": 1980,
///   "shop": "こども服Shop",
///   "imageUrl": "https://image.rakuten.co.jp/example.jpg",
///   "url": "https://item.rakuten.co.jp/example",
/// }
///
class RakutenProduct {
  /// 商品名
  final String name;

  /// 価格（数値）
  final int price;

  /// 店舗名
  final String shop;

  /// 商品画像 URL
  final String imageUrl;

  /// 商品ページ URL
  final String url;

  const RakutenProduct({
    required this.name,
    required this.price,
    required this.shop,
    required this.imageUrl,
    required this.url,
  });

  /// API → モデル
  factory RakutenProduct.fromJson(Map<String, dynamic> json) {
    return RakutenProduct(
      name: json['name']?.toString() ?? '',
      price: _parsePrice(json['price']),
      shop: json['shop']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }

  /// モデル → JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'shop': shop,
      'imageUrl': imageUrl,
      'url': url,
    };
  }

  /// 価格が文字列 or 数値のどちらでも受け入れるようにする
  static int _parsePrice(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) {
      final parsed = int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), ''));
      return parsed ?? 0;
    }
    return 0;
  }

  /// copyWith（必要なら）
  RakutenProduct copyWith({
    String? name,
    int? price,
    String? shop,
    String? imageUrl,
    String? url,
  }) {
    return RakutenProduct(
      name: name ?? this.name,
      price: price ?? this.price,
      shop: shop ?? this.shop,
      imageUrl: imageUrl ?? this.imageUrl,
      url: url ?? this.url,
    );
  }
}
