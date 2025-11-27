import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../app/router.dart';

// ドメイン側プロバイダ
import '../../features/weather/presentation/weather_providers.dart';
import '../../features/clothes/presentation/clothes_providers.dart';
import '../../features/clothes/presentation/scene_clothes_provider.dart';

// 共通コンポーネント
import 'components/custom_bottom_nav.dart';
import 'components/section_header.dart';
import 'components/weather_icon.dart';
import 'components/bottom_sheets/clothes_detail_sheet.dart';
import 'components/product_card.dart';
import 'components/bottom_sheets/animated_clothes_bottom_sheet.dart';

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
    final sceneList = ref.watch(sceneClothesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,

      // Google Weather 風の透明ナビゲーション（不要なら削除可）
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            switch (index) {
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

      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(todayWeatherProvider.notifier).reload();
            await ref.read(todayClothesProvider.notifier).reload();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                ////////////////////////////////////////////////////////////
                // ① TOP：Google Weather 風 Hero（背景付き大エリア）
                ////////////////////////////////////////////////////////////
                _HeroSection(
                  weatherAsync: weatherAsync,
                  clothesAsync: clothesAsync,
                ),

                ////////////////////////////////////////////////////////////
                // ② 今日の服装ナビ
                ////////////////////////////////////////////////////////////
                _MainClothesSection(clothesAsync: clothesAsync),

                ////////////////////////////////////////////////////////////
                // ③ シーン別
                ////////////////////////////////////////////////////////////
                _SceneSection(
                  sceneList: sceneList,
                  selectedIndex: _selectedSceneIndex,
                  onSceneChanged: (i) {
                    setState(() => _selectedSceneIndex = i);
                  },
                ),

                ////////////////////////////////////////////////////////////
                // ④ 楽天おすすめ
                ////////////////////////////////////////////////////////////
                _ProductsSection(clothesAsync: clothesAsync),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
// ① Google Weather 風トップエリア（完成版）
///////////////////////////////////////////////////////////////////////////////
class _HeroSection extends StatelessWidget {
  final AsyncValue<dynamic> weatherAsync;
  final AsyncValue<dynamic> clothesAsync;

  const _HeroSection({required this.weatherAsync, required this.clothesAsync});

  // 天気に応じてグラデーションを変える（簡易版）
  LinearGradient _buildBackground(AsyncValue<dynamic> weatherAsync) {
    return weatherAsync.maybeWhen(
      data: (w) {
        final condition = (w.condition ?? '').toString().toLowerCase();

        if (condition.contains('rain') || condition.contains('雨')) {
          // 雨：少し落ち着いた青
          return const LinearGradient(
            colors: [Color(0xFF6C8DDC), Color(0xFFB3C9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        } else if (condition.contains('cloud') ||
            condition.contains('曇') ||
            condition.contains('くもり')) {
          // 曇り：グレー寄りの青
          return const LinearGradient(
            colors: [Color(0xFF9FB3D9), Color(0xFFD7E3F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        } else if (condition.contains('snow') || condition.contains('雪')) {
          // 雪：少し白っぽい寒色
          return const LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFB3E5FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        } else {
          // 晴れ・その他：Pixel Weather っぽい明るい空色
          return const LinearGradient(
            colors: [Color(0xFF7EC8FF), Color(0xFFE3F4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        }
      },
      orElse: () => const LinearGradient(
        colors: [Color(0xFF7EC8FF), Color(0xFFE3F4FF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 32),
      decoration: BoxDecoration(gradient: _buildBackground(weatherAsync)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --------------------------
          // 天気アイコン + 気温 + 地域表示
          // --------------------------
          weatherAsync.when(
            data: (w) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 大きな天気アイコン（Pixel Weather 風）
                  WeatherIcon(
                    condition: w.condition,
                    size: 96,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),

                  // 現在気温：画面中央にドンと表示
                  Text(
                    '${w.value.toStringAsFixed(0)}°',
                    style: textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 0.9,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),

                  // 体感温度
                  Text(
                    '体感 ${w.feelsLike.toStringAsFixed(0)}°',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // 場所（地域名）
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        w.region,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 160,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
            error: (_, __) => Text(
              '天気を取得できません',
              style: textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),

          const SizedBox(height: 24),

          // --------------------------
          // 今日のひとこと（Pixel の AQI カード風）
          // --------------------------
          clothesAsync.when(
            data: (c) {
              final summary = c.summary as String;
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '今日のひとこと',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        summary,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SizedBox(
              height: 48,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '服装データを取得できませんでした',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 今日のひとことカード（共通）
Widget _buildHintCard(BuildContext context, String summary) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(top: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日のひとこと',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppTheme.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(summary, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}

///////////////////////////////////////////////////////////////////////////////
// ② 今日の服装ナビ（カード）
///////////////////////////////////////////////////////////////////////////////
class _MainClothesSection extends StatelessWidget {
  final AsyncValue<dynamic> clothesAsync;

  const _MainClothesSection({required this.clothesAsync});

  @override
  Widget build(BuildContext context) {
    return _Section(
      child: Column(
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
            data: (c) => GestureDetector(
              onTap: () => _openClothesSheet(context, c),
              child: _MainClothesCard(c),
            ),
            loading: () => const _LoadingCard(),
            error: (_, __) => const _ErrorMessage('服装を取得できませんでした'),
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
    final layers = List<String>.from(c.layers ?? []);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.summary, style: Theme.of(context).textTheme.titleMedium),
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
                '気温 ${c.temperature.value}° / 体感 ${c.temperature.feelsLike}°',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
// ③ シーン別
///////////////////////////////////////////////////////////////////////////////
class _SceneSection extends StatelessWidget {
  final List<SceneClothes> sceneList;
  final int selectedIndex;
  final ValueChanged<int> onSceneChanged;

  const _SceneSection({
    required this.sceneList,
    required this.selectedIndex,
    required this.onSceneChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scene = sceneList[selectedIndex];

    return _Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.child_care_outlined,
            title: 'シーン別の服装',
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(sceneList.length, (i) {
                final isActive = i == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(sceneList[i].scene),
                    selected: isActive,
                    onSelected: (_) => onSceneChanged(i),
                    selectedColor: AppTheme.primaryBlue.withOpacity(0.15),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // シーンカード
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
                    scene.scene,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(scene.comment),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: scene.items
                        .map((i) => Chip(label: Text(i)))
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

///////////////////////////////////////////////////////////////////////////////
// ④ 楽天おすすめ
///////////////////////////////////////////////////////////////////////////////
class _ProductsSection extends StatelessWidget {
  final AsyncValue<dynamic> clothesAsync;

  const _ProductsSection({required this.clothesAsync});

  @override
  Widget build(BuildContext context) {
    return _Section(
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
                return const Text('おすすめ商品はありません');
              }

              return SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return _ProductCard(product: p);
                  },
                ),
              );
            },
            loading: () => const _LoadingCard(),
            error: (_, __) => const Text('商品情報を取得できませんでした'),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
// 商品カード
///////////////////////////////////////////////////////////////////////////////
class _ProductCard extends StatelessWidget {
  final dynamic product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl ?? '';
    final name = product.name ?? '';
    final price = product.price ?? '';
    final shop = product.shop ?? '';

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EDF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 100,
                    width: 160,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  '$price 円',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  shop,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
// 共通セクションコンテナ
///////////////////////////////////////////////////////////////////////////////
class _Section extends StatelessWidget {
  final Widget child;
  const _Section({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF2F7FC),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: child,
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
// 共通ローディング / エラー
///////////////////////////////////////////////////////////////////////////////
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 80,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;
  const _ErrorMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return Text(message, style: const TextStyle(color: Colors.red));
  }
}

void _openClothesSheet(BuildContext context, dynamic clothes) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      return AnimatedClothesBottomSheet(clothes: clothes);
    },
  );
}
