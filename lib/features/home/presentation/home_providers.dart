import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/domain/entities/home_today.dart';
import '../../home/domain/repositories/home_repository.dart';
import '../../home/data/datasources/home_remote_data_source.dart';
import '../../home/data/repositories/home_repository_impl.dart';
import '../../../core/network/api_client.dart';
import '../../onboarding/presentation/onboarding_providers.dart';
import 'package:clothes_app/features/home/domain/entities/home_today.dart'
    as hd;
import 'package:clothes_app/features/weather/domain/entities/weather.dart'
    as wd;

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final client = ApiClient();
  final ds = HomeRemoteDataSource(client);
  return HomeRepositoryImpl(ds);
});

// アプリ全体のホーム用スナップショット（天気・サマリー・家族提案を包含）
final homeSnapshotProvider =
    AsyncNotifierProvider.autoDispose<HomeSnapshotNotifier, hd.HomeToday>(
      HomeSnapshotNotifier.new,
    );

class HomeSnapshotNotifier extends AsyncNotifier<hd.HomeToday> {
  @override
  Future<hd.HomeToday> build() async {
    return _fetch();
  }

  Future<hd.HomeToday> _fetch() async {
    final repo = ref.read(homeRepositoryProvider);
    var userId = ref.read(userIdProvider);
    if (userId == null || userId.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? '';
    }
    if (userId.isEmpty) {
      throw StateError('userId is not set');
    }
    return repo.loadHomeToday(userId);
  }

  /// 画面のローディング表示を出さずに静かに再取得する
  Future<void> refreshSilently() async {
    try {
      final next = await _fetch();
      if (ref.mounted) {
        state = AsyncData(next);
      }
    } catch (e, st) {
      // 失敗時は既存表示を維持（必要ならログのみ）
      // print('home refresh failed: $e');
    }
  }
}

/// Homeスナップショットから TodayWeather（weather feature）へマッピング
final homeWeatherProvider = FutureProvider<wd.TodayWeather>((ref) async {
  final home = await ref.watch(homeSnapshotProvider.future);
  final w = home.weather;
  return wd.TodayWeather(
    region: w.region,
    value: w.value,
    feelsLike: w.feelsLike,
    humidity: w.humidity,
    windSpeed: w.windSpeed,
    category: w.category,
    condition: w.condition,
  );
});
