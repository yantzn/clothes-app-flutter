import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class WeatherIcon extends StatelessWidget {
  final String condition;
  final double size;
  final Color? color;

  const WeatherIcon({
    super.key,
    required this.condition,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      _mapToIcon(condition),
      size: size,
      color: color ?? Colors.blueGrey,
    );
  }

  /// OpenWeather の condition を Google Material 天気アイコンに変換
  IconData _mapToIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return MdiIcons.weatherSunny;

      case 'clouds':
      case 'cloudy':
        return MdiIcons.weatherCloudy;

      case 'rain':
      case 'drizzle':
        return MdiIcons.weatherRainy;

      case 'thunderstorm':
        return MdiIcons.weatherLightning;

      case 'snow':
        return MdiIcons.weatherSnowy;

      case 'fog':
      case 'mist':
      case 'haze':
        return MdiIcons.weatherFog;

      default:
        return MdiIcons.weatherPartlyCloudy;
    }
  }
}
