import 'package:flutter/material.dart';
import 'package:clothes_app/features/weather/presentation/widgets/weather_icon.dart';

class WeatherHero extends StatelessWidget {
  final String condition;
  final num temperature;
  final num feelsLike;
  final String region;
  final Widget? footer; // 下部に任意のコンテンツ（例: 今日のひとこと or ローディングなど）
  final LinearGradient Function(String condition)? gradientBuilder;
  final int humidity;
  final num windSpeed;
  final String category;

  const WeatherHero({
    super.key,
    required this.condition,
    required this.temperature,
    required this.feelsLike,
    required this.region,
    required this.humidity,
    required this.windSpeed,
    required this.category,
    this.footer,
    this.gradientBuilder,
  });

  LinearGradient _defaultGradient(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('rain') || c.contains('雨')) {
      return const LinearGradient(
        colors: [Color(0xFF6C8DDC), Color(0xFFB3C9FF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (c.contains('cloud') || c.contains('曇') || c.contains('くもり')) {
      return const LinearGradient(
        colors: [Color(0xFF9FB3D9), Color(0xFFD7E3F5)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (c.contains('snow') || c.contains('雪')) {
      return const LinearGradient(
        colors: [Color(0xFFE3F2FD), Color(0xFFB3E5FC)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF7EC8FF), Color(0xFFE3F4FF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final gradient = (gradientBuilder ?? _defaultGradient).call(condition);

    final safeTop = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      // ステータスバー/ヘッダー分の余白を付与して干渉回避
      padding: EdgeInsets.fromLTRB(20, safeTop + 16, 20, 32),
      decoration: BoxDecoration(gradient: gradient),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 上段: 天気アイコン（大）の右隣に 気温・体感
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              WeatherIcon(condition: condition, size: 96, color: Colors.white),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${temperature.toStringAsFixed(0)}°',
                    style: textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 0.9,
                      shadows: const [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '体感 ${feelsLike.toStringAsFixed(0)}°',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.place_outlined, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                region,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _MiniStatsRow(
            humidity: humidity,
            windSpeed: windSpeed.toDouble(),
            category: category,
            textTheme: textTheme,
          ),
          if (footer != null) ...[const SizedBox(height: 24), footer!],
        ],
      ),
    );
  }

  String _categoryLabel(String c) {
    switch (c.toLowerCase()) {
      case 'very_cold':
        return 'とても寒い';
      case 'cold':
        return '寒い';
      case 'cool':
        return '肌寒い';
      case 'mild':
        return '適温';
      case 'warm':
        return '暖かい';
      case 'hot':
        return '暑い';
      default:
        return c;
    }
  }
}

class _MiniStatsRow extends StatelessWidget {
  final int humidity;
  final double windSpeed;
  final String category;
  final TextTheme textTheme;

  const _MiniStatsRow({
    required this.humidity,
    required this.windSpeed,
    required this.category,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      if (category.isNotEmpty)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _categoryLabel(category),
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.water_drop_outlined, size: 18, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '$humidity%',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.air, size: 18, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '${windSpeed.toStringAsFixed(1)} m/s',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ];

    return Wrap(
      spacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: items,
    );
  }

  String _categoryLabel(String c) {
    switch (c.toLowerCase()) {
      case 'very_cold':
        return 'とても寒い';
      case 'cold':
        return '寒い';
      case 'cool':
        return '肌寒い';
      case 'mild':
        return '適温';
      case 'warm':
        return '暖かい';
      case 'hot':
        return '暑い';
      default:
        return c;
    }
  }
}
