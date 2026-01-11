import '../../domain/entities/home_today.dart';

class HomeTodayDto {
  final String summary;
  final Map<String, dynamic> weather;
  final List<Map<String, dynamic>> members;

  const HomeTodayDto({
    required this.summary,
    required this.weather,
    required this.members,
  });

  factory HomeTodayDto.fromJson(Map<String, dynamic> json) {
    final members = (json['members'] as List<dynamic>? ?? const [])
        .map((e) => (e as Map<String, dynamic>))
        .toList();
    return HomeTodayDto(
      summary: json['summary'] as String? ?? '',
      weather: (json['weather'] as Map<String, dynamic>? ?? const {}),
      members: members,
    );
  }

  HomeToday toEntity() {
    final w = weather;
    final todayWeather = TodayWeather(
      region: w['region'] as String? ?? '',
      value: (w['value'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (w['feelsLike'] as num?)?.toDouble() ?? 0.0,
      humidity: (w['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (w['windSpeed'] as num?)?.toDouble() ?? 0.0,
      category: w['category'] as String? ?? '',
      condition: w['condition'] as String? ?? '',
    );

    final memberEntities = members.map((m) {
      final s = (m['suggestion'] as Map<String, dynamic>? ?? const {});
      final layers = (s['layers'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList();
      final notes = (s['notes'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList();
      final ld = (s['layersDetailed'] as List<dynamic>?);
      final layersDetailed = ld == null
          ? null
          : ld
                .map((e) => e as Map<String, dynamic>)
                .map(
                  (mm) => LayerSpec(
                    slot: mm['slot'] as String? ?? '',
                    category: mm['category'] as String? ?? '',
                    displayName: mm['displayName'] as String? ?? '',
                  ),
                )
                .toList();

      return MemberClothesCard(
        name: m['name'] as String? ?? '',
        ageGroup: m['ageGroup'] as String? ?? '',
        suggestion: SuggestionDetails(
          summary: s['summary'] as String? ?? '',
          layers: layers,
          layersDetailed: layersDetailed,
          notes: notes,
        ),
      );
    }).toList();

    return HomeToday(
      summary: summary,
      weather: todayWeather,
      members: memberEntities,
    );
  }
}
