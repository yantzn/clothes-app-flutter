import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../weather/presentation/weather_providers.dart';

class WeatherDetailPage extends ConsumerWidget {
  const WeatherDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(todayWeatherProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('今日の天気')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: weatherAsync.when(
          data: (w) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(w.region, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('気温: ${w.value.toStringAsFixed(1)}℃'),
              Text('体感温度: ${w.feelsLike.toStringAsFixed(1)}℃'),
              Text('湿度: ${w.humidity}%'),
              Text('風速: ${w.windSpeed} m/s'),
              const SizedBox(height: 16),
              Chip(label: Text('カテゴリ: ${w.category}')),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('エラー: $e')),
        ),
      ),
    );
  }
}
