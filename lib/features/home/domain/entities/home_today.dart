class TodayWeather {
  final String region;
  final double value;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String category;
  final String condition;

  const TodayWeather({
    required this.region,
    required this.value,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.category,
    required this.condition,
  });
}

class LayerSpec {
  final String slot;
  final String category;
  final String displayName;

  const LayerSpec({
    required this.slot,
    required this.category,
    required this.displayName,
  });
}

class SuggestionDetails {
  final String summary;
  final List<String> layers;
  final List<LayerSpec>? layersDetailed;
  final List<String> notes;

  const SuggestionDetails({
    required this.summary,
    required this.layers,
    this.layersDetailed,
    required this.notes,
  });
}

class MemberClothesCard {
  final String name;
  final String ageGroup;
  final SuggestionDetails suggestion;

  const MemberClothesCard({
    required this.name,
    required this.ageGroup,
    required this.suggestion,
  });
}

class HomeToday {
  final String summary;
  final TodayWeather weather;
  final List<MemberClothesCard> members;

  const HomeToday({
    required this.summary,
    required this.weather,
    required this.members,
  });
}
