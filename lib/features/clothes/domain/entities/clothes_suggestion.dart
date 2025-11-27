import 'rakuten_product.dart';

/// 子どもの「今日の服装」提案ドメインモデル.
///
/// バックエンド API から返る JSON（例）
///
/// {
///   "userId": "test-user-3",
///   "ageGroup": "child",
///   "temperature": {
///     "value": 15.49,
///     "feelsLike": 14.53,
///     "category": "cool"
///   },
///   "suggestion": {
///     "summary": "やや肌寒い気温では、長袖Tシャツと薄手パーカーなどで体温調節を行います。",
///     "layers": [ "長袖Tシャツ", "薄手パーカー" ],
///     "notes": [ "〜メモ〜", ... ],
///     "references": [ "https://www.ncchd.go.jp/" ]
///   },
///   "products": [ { ...楽天商品... }, ... ]
/// }
///
class ClothesSuggestion {
  /// ユーザーID（今回は "test-user-3" など）
  final String userId;

  /// 年齢区分（"baby" / "child" / "junior" など想定）
  final String ageGroup;

  /// 気温情報
  final TemperatureInfo temperature;

  /// 要約文（画面の「サマリ」表示に利用）
  final String summary;

  /// レイヤー構成（長袖Tシャツ / 薄手パーカー 等）
  final List<String> layers;

  /// メモ・注意点（子育て情報や体感温度に関する補足など）
  final List<String> notes;

  /// 参考リンク（成育医療センターなど）
  final List<String> references;

  /// 楽天の商品リスト（アフェリエイト表示用）
  final List<RakutenProduct> products;

  const ClothesSuggestion({
    required this.userId,
    required this.ageGroup,
    required this.temperature,
    required this.summary,
    required this.layers,
    required this.notes,
    required this.references,
    required this.products,
  });

  /// copyWith はフォーム編集や一部更新に便利
  ClothesSuggestion copyWith({
    String? userId,
    String? ageGroup,
    TemperatureInfo? temperature,
    String? summary,
    List<String>? layers,
    List<String>? notes,
    List<String>? references,
    List<RakutenProduct>? products,
  }) {
    return ClothesSuggestion(
      userId: userId ?? this.userId,
      ageGroup: ageGroup ?? this.ageGroup,
      temperature: temperature ?? this.temperature,
      summary: summary ?? this.summary,
      layers: layers ?? this.layers,
      notes: notes ?? this.notes,
      references: references ?? this.references,
      products: products ?? this.products,
    );
  }

  /// API からの生 JSON からドメインモデルへ変換
  factory ClothesSuggestion.fromJson(Map<String, dynamic> json) {
    final tempJson = json['temperature'] as Map<String, dynamic>? ?? {};
    final sugJson = json['suggestion'] as Map<String, dynamic>? ?? {};
    final productsJson = json['products'] as List<dynamic>? ?? const [];

    return ClothesSuggestion(
      userId: json['userId'] as String? ?? '',
      ageGroup: json['ageGroup'] as String? ?? '',
      temperature: TemperatureInfo.fromJson(tempJson),
      summary: sugJson['summary'] as String? ?? '',
      layers: (sugJson['layers'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      notes: (sugJson['notes'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      references: (sugJson['references'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      products: productsJson
          .map(
            (p) => RakutenProduct.fromJson(
              p is Map<String, dynamic> ? p : Map<String, dynamic>.from(p),
            ),
          )
          .toList(),
    );
  }

  /// JSON へ変換（必要なら保存やログ用に）
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'ageGroup': ageGroup,
      'temperature': temperature.toJson(),
      'suggestion': {
        'summary': summary,
        'layers': layers,
        'notes': notes,
        'references': references,
      },
      'products': products.map((p) => p.toJson()).toList(),
    };
  }
}

/// 気温まわりの情報サブモデル.
///
/// - value: 実際の気温
/// - feelsLike: 体感温度
/// - category: "cold" / "cool" / "warm" などの区分
///
class TemperatureInfo {
  final double value;
  final double feelsLike;
  final String category;

  const TemperatureInfo({
    required this.value,
    required this.feelsLike,
    required this.category,
  });

  factory TemperatureInfo.fromJson(Map<String, dynamic> json) {
    return TemperatureInfo(
      value: (json['value'] as num?)?.toDouble() ?? 0,
      feelsLike: (json['feelsLike'] as num?)?.toDouble() ?? 0,
      category: json['category'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'feelsLike': feelsLike, 'category': category};
  }

  TemperatureInfo copyWith({
    double? value,
    double? feelsLike,
    String? category,
  }) {
    return TemperatureInfo(
      value: value ?? this.value,
      feelsLike: feelsLike ?? this.feelsLike,
      category: category ?? this.category,
    );
  }
}
