import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WeatherIcon extends StatelessWidget {
  final String condition;
  final double size;
  final Color color;

  const WeatherIcon({
    super.key,
    required this.condition,
    this.size = 48,
    this.color = const Color(0xFF6DB4F5), // あなたのテーマに合う優しい青
  });

  String _mapToAsset(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return 'assets/svg/weather/sunny.svg';
      case 'cloudy':
      case 'clouds':
        return 'assets/svg/weather/cloudy.svg';
      case 'rain':
      case 'rainy':
        return 'assets/svg/weather/rain.svg';
      case 'snow':
        return 'assets/svg/weather/snow.svg';
      default:
        return 'assets/svg/weather/unknown.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _mapToAsset(condition);

    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
