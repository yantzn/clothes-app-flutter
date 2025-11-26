import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../app/router.dart';

// ドメイン側プロバイダ
import '../../features/weather/presentation/weather_providers.dart';
import '../../features/clothes/presentation/clothes_providers.dart';
import '../../features/clothes/presentation/scene_clothes_provider.dart';

// UI共通コンポーネント
import 'components/custom_bottom_nav.dart';
import 'components/section_header.dart';
import 'components/weather_icon.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  int _selectedSceneIndex = 0;

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(todayWeatherProvider);
    final clothesAsync = ref.watch(todayClothesProvider);
    final sceneMap = ref.watch(
      sceneClothesProvider,
    ); // Map<String, List<String>>

    final sceneNames = sceneMap.keys.toList();
    if (_selectedSceneIndex >= sceneNames.length) {
      _selectedSceneIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('子ども服装ナビ'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),

      // -----------------------------------------------------
      // Bottom Navigation（ホーム / おすすめ / 設定）
      // -----------------------------------------------------
      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);

            switch (index) {
              case 0:
                // ホーム（何もしない）
                break;
              case 1:
                Navigator.pushNamed(context, AppRouter.clothesDetail);
                break;
              case 2:
                Navigator.pushNamed(context, AppRouter.settings);
                break;
            }
          },
        ),
      ),

      // -----------------------------------------------------
      // Body
      // -----------------------------------------------------
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(todayWeatherProvider.notifier).reload();
            await ref.read(todayClothesProvider.notifier).reload();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ① ヒーローエリア（天気＋一言）
                _HeroSection(
                  weatherAsync: weatherAsync,
                  clothesAsync: clothesAsync,
                ),

                // ② 今日の服装ナビ（メインカード）
                _MainClothesSection(clothesAsync: clothesAsync),

                // ③ シーン別タブ＋カード
                _SceneSection(
                  sceneMap: sceneMap,
                  selectedIndex: _selectedSceneIndex,
                  onSceneChanged: (i) {
                    setState(() => _selectedSceneIndex = i);
                  },
                ),

                // ④ 今日の天気（詳細）
                _WeatherDetailSection(weatherAsync: weatherAsync),

                // ⑤ 楽天おすすめ商品（簡易版）
                _ProductsSection(clothesAsync: clothesAsync),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//
// ---------------------------------------------------------
// ① ヒーローエリア
// ---------------------------------------------------------
class _HeroSection extends StatelessWidget {
  final AsyncValue<dynamic> weatherAsync;
  final AsyncValue<dynamic> clothesAsync;

  const _HeroSection({required this.weatherAsync, required this.clothesAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE3F4FF), Color(0xFFF9FCFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Row(
        children: [
          // 左：アイコン＋温度
          Expanded(
            flex: 2,
            child: weatherAsync.when(
              data: (w) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WeatherIcon(
                      condition: w.condition,
                      size: 48,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${w.value.toStringAsFixed(1)}℃',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '体感 ${w.feelsLike.toStringAsFixed(1)}℃',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      w.region,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                );
              },
              loading: () => const _HeroSkeleton(),
              error: (_, __) => Text(
                '天気を取得できませんでした',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.red),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 右：ひとことメッセージ
          Expanded(
            flex: 3,
            child: clothesAsync.when(
              data: (c) {
                final summary = c.summary as String;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE0EDF5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '今日のひとこと',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        summary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
              loading: () => const _HeroSkeleton(),
              error: (_, __) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0EDF5)),
                ),
                child: Text(
                  '服装の情報を読み込み中です',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 80,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

//
// ---------------------------------------------------------
// ② 今日の服装ナビ（メインカード）
// ---------------------------------------------------------
class _MainClothesSection extends StatelessWidget {
  final AsyncValue<dynamic> clothesAsync;

  const _MainClothesSection({required this.clothesAsync});

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.checkroom_outlined,
            title: '今日の服装ナビ',
            action: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.clothesDetail);
              },
              child: const Text('くわしく見る'),
            ),
          ),
          const SizedBox(height: 16),
          clothesAsync.when(
            data: (c) => _MainClothesCard(c),
            loading: () => const _LoadingCard(),
            error: (_, __) => const _ErrorMessage('服装情報を取得できませんでした'),
          ),
        ],
      ),
    );
  }
}

class _MainClothesCard extends StatelessWidget {
  final dynamic c;

  const _MainClothesCard(this.c);

  @override
  Widget build(BuildContext context) {
    final List<String> layers = List<String>.from(c.layers ?? []);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ラベル
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4FF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '今日のおすすめ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              c.summary as String,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: layers.map((l) => Chip(label: Text(l))).toList(),
            ),

            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '気温 ${c.temperature.value.toStringAsFixed(1)}℃'
                ' / 体感 ${c.temperature.feelsLike.toStringAsFixed(1)}℃',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// ---------------------------------------------------------
// ③ シーン別タブ＋カード
// ---------------------------------------------------------
class _SceneSection extends StatelessWidget {
  final Map<String, List<String>> sceneMap;
  final int selectedIndex;
  final ValueChanged<int> onSceneChanged;

  const _SceneSection({
    required this.sceneMap,
    required this.selectedIndex,
    required this.onSceneChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (sceneMap.isEmpty) {
      return const SizedBox.shrink();
    }

    final sceneNames = sceneMap.keys.toList();
    final currentScene = sceneNames[selectedIndex];
    final suggestions = sceneMap[currentScene] ?? [];

    return _SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.child_care_outlined,
            title: 'シーン別の服装',
          ),
          const SizedBox(height: 12),

          // タブ（室内 / おでかけ / 公園 / 保育園）
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(sceneNames.length, (i) {
                final isActive = i == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(sceneNames[i]),
                    selected: isActive,
                    onSelected: (_) => onSceneChanged(i),
                    selectedColor: AppTheme.primaryBlue.withOpacity(0.15),
                    labelStyle: TextStyle(
                      color: isActive ? AppTheme.primaryBlue : Colors.grey[700],
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // 選択中シーンのカード
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentScene,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: suggestions
                        .map((s) => Chip(label: Text(s)))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
// ---------------------------------------------------------
// ④ 今日の天気（詳細）
// ---------------------------------------------------------
class _WeatherDetailSection extends StatelessWidget {
  final AsyncValue<dynamic> weatherAsync;

  const _WeatherDetailSection({required this.weatherAsync});

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.cloud_outlined,
            title: '今日の天気',
            action: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.weatherDetail);
              },
              child: const Text('詳細を見る'),
            ),
          ),
          const SizedBox(height: 16),
          weatherAsync.when(
            data: (w) => _WeatherCard(w),
            loading: () => const _LoadingCard(),
            error: (_, __) => const _ErrorMessage('天気を取得できませんでした'),
          ),
        ],
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final dynamic w;

  const _WeatherCard(this.w);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            WeatherIcon(
              condition: w.condition,
              size: 40,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${w.value.toStringAsFixed(1)}℃',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '体感 ${w.feelsLike.toStringAsFixed(1)}℃',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '湿度 ${w.humidity}%・風速 ${w.windSpeed}m/s',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// ---------------------------------------------------------
// ⑤ 楽天おすすめ商品（簡易版）
// ---------------------------------------------------------
class _ProductsSection extends StatelessWidget {
  final AsyncValue<dynamic> clothesAsync;

  const _ProductsSection({required this.clothesAsync});

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.shopping_bag_outlined,
            title: '楽天のおすすめ',
          ),
          const SizedBox(height: 12),
          clothesAsync.when(
            data: (c) {
              final products = c.products as List<dynamic>? ?? [];
              if (products.isEmpty) {
                return Text(
                  'おすすめ商品はありません',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              }

              return Column(
                children: products.take(3).map((p) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 0,
                    ),
                    leading: const Icon(Icons.image_outlined),
                    title: Text(
                      p.name as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${p.shop} / ${p.price}円',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      // 詳細画面・外部ブラウザに飛ばす処理は後で
                    },
                  );
                }).toList(),
              );
            },
            loading: () => const _LoadingCard(),
            error: (_, __) => Text(
              '商品情報を取得できませんでした',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

//
// ---------------------------------------------------------
// 共通セクションコンテナ
// ---------------------------------------------------------
class _SectionContainer extends StatelessWidget {
  final Widget child;

  const _SectionContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF3F9FD),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: child,
    );
  }
}

//
// ---------------------------------------------------------
// ローディング / エラー
// ---------------------------------------------------------
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),
    );
  }
}
