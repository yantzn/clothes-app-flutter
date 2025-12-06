import 'package:clothes_app/features/clothes/domain/entities/clothes_suggestion.dart';
import 'package:clothes_app/features/clothes/presentation/scene_clothes_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../app/router.dart';

// ドメイン側プロバイダ
import '../../features/weather/presentation/weather_providers.dart';
import '../../features/clothes/presentation/clothes_providers.dart';
import '../../features/clothes/presentation/family_scene_clothes_provider.dart';

// 共通コンポーネント
import '../onboarding/presentation/onboarding_providers.dart';
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
  int _selectedFamilyIndex = 0;

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(todayWeatherProvider);
    final clothesAsync = ref.watch(todayClothesProvider);
    final familySuggestionsMap = ref.watch(familySuggestionsProvider);
    final families = ref.watch(onboardingProvider.select((s) => s.families));

    return Scaffold(
      extendBodyBehindAppBar: true,

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
                // ① Hero セクション
                ////////////////////////////////////////////////////////////
                _HeroSection(
                  weatherAsync: weatherAsync,
                  clothesAsync: clothesAsync,
                ),

                ////////////////////////////////////////////////////////////
                // ② 今日の服装ナビ
                ////////////////////////////////////////////////////////////
                /*
                _MainClothesSection(clothesAsync: clothesAsync),
                */

                ////////////////////////////////////////////////////////////
                // ③ 家族別の服装提案（タブはニックネーム）
                ////////////////////////////////////////////////////////////
                Builder(
                  builder: (context) {
                    final nicknames = familySuggestionsMap.keys.toList();
                    // インデックスが範囲外にならないよう調整
                    final safeIndex = nicknames.isEmpty
                        ? 0
                        : (_selectedFamilyIndex.clamp(0, nicknames.length - 1));

                    return _FamilySection(
                      familiesNicknames: nicknames,
                      suggestionsMap: familySuggestionsMap,
                      selectedIndex: safeIndex,
                      onFamilyChanged: (i) {
                        setState(() => _selectedFamilyIndex = i);
                      },
                    );
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
// ① Hero セクション（既存そのまま）
///////////////////////////////////////////////////////////////////////////////
class _HeroSection extends StatelessWidget {
  final AsyncValue<dynamic> weatherAsync;
  final AsyncValue<dynamic> clothesAsync;

  const _HeroSection({required this.weatherAsync, required this.clothesAsync});

  LinearGradient _buildBackground(AsyncValue<dynamic> weatherAsync) {
    return weatherAsync.maybeWhen(
      data: (w) {
        final condition = (w.condition ?? '').toString().toLowerCase();

        if (condition.contains('rain') || condition.contains('雨')) {
          return const LinearGradient(
            colors: [Color(0xFF6C8DDC), Color(0xFFB3C9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        } else if (condition.contains('cloud') ||
            condition.contains('曇') ||
            condition.contains('くもり')) {
          return const LinearGradient(
            colors: [Color(0xFF9FB3D9), Color(0xFFD7E3F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        } else if (condition.contains('snow') || condition.contains('雪')) {
          return const LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFB3E5FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        } else {
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
      padding: const EdgeInsets.fromLTRB(20, 13, 20, 32),
      decoration: BoxDecoration(gradient: _buildBackground(weatherAsync)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          weatherAsync.when(
            data: (w) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  WeatherIcon(
                    condition: w.condition,
                    size: 96,
                    color: Colors.white,
                  ),
                  // タイトル直下の余白を最小化
                  const SizedBox.shrink(),
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
                  Text(
                    '体感 ${w.feelsLike.toStringAsFixed(0)}°',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

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

///////////////////////////////////////////////////////////////////////////////
// 今日の服装ナビ（既存のまま / 必要なら後で削除可能）
///////////////////////////////////////////////////////////////////////////////

class _MainClothesSection extends StatelessWidget {
  final AsyncValue<dynamic> clothesAsync;
  const _MainClothesSection({required this.clothesAsync});

  @override
  Widget build(BuildContext context) {
    return _Section(
      child: Column(
        children: [
          SectionHeader(icon: Icons.checkroom_outlined, title: '今日の服装ナビ'),
          const SizedBox(height: 16),
          clothesAsync.when(
            data: (c) => GestureDetector(
              onTap: () => _openClothesSheet(context, c),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: _MainClothesCard(c),
                ),
              ),
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
  final double leadingInset;
  final double extraLeftShift;

  const _SceneSection({
    required this.sceneList,
    required this.selectedIndex,
    required this.onSceneChanged,
    this.leadingInset = 0,
    this.extraLeftShift = 0,
  });

  @override
  Widget build(BuildContext context) {
    final scene = sceneList[selectedIndex];

    return _Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 先頭余白を詰めてタイトル直下とのギャップを最小化
          const SizedBox.shrink(),

          Transform.translate(
            offset: Offset(extraLeftShift, 0),
            child: Container(
              padding: EdgeInsets.only(left: leadingInset),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(sceneList.length, (i) {
                    final isActive = i == selectedIndex;

                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        avatar: Icon(
                          _sceneIcon(sceneList[i].scene),
                          size: 18,
                          color: isActive
                              ? AppTheme.primaryBlue
                              : Colors.grey[500],
                        ),
                        label: Text(sceneList[i].scene),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(
                          horizontal: -1,
                          vertical: -2,
                        ),
                        // 一文字ラベルでも見切れないように上下にも余白を付与
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        selected: isActive,
                        onSelected: (_) => onSceneChanged(i),
                        selectedColor: AppTheme.primaryBlue.withOpacity(0.15),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Transform.translate(
            offset: Offset(extraLeftShift, 0),
            child: Padding(
              padding: EdgeInsets.only(left: leadingInset),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _SceneDetailCard(scene: scene),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _sceneIcon(String name) {
    if (name.contains('室内')) return Icons.home_rounded;
    if (name.contains('おでかけ')) return Icons.directions_walk_rounded;
    return Icons.checkroom_outlined;
  }
}

///////////////////////////////////////////////////////////////////////////////
// シーン詳細カード
///////////////////////////////////////////////////////////////////////////////

class _SceneDetailCard extends StatelessWidget {
  final SceneClothes scene;
  const _SceneDetailCard({required this.scene});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0.8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _sceneIcon(scene.scene),
                  size: 24,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  scene.scene,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              scene.comment,
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),

            const SizedBox(height: 16),

            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFF7F9FB),
                border: Border.all(color: const Color(0xFFE0E6EE)),
              ),
              child: const Center(
                child: Text(
                  '服装イラスト（後で画像差し込み）',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              '今日のおすすめ',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: scene.items
                  .map(
                    (i) => Chip(
                      label: Text(i),
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.08),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 15),

            if (scene.medicalNote != null && scene.medicalNote!.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      scene.medicalNote!,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  IconData _sceneIcon(String name) {
    if (name == '今日') return Icons.today_rounded;
    if (name.contains('室内')) return Icons.home_rounded;
    if (name.contains('おでかけ')) return Icons.directions_walk_rounded;
    return Icons.school_rounded;
  }
}

///////////////////////////////////////////////////////////////////////////////
// 家族別提案セクション（ニックネームタブ）
///////////////////////////////////////////////////////////////////////////////
class _FamilySection extends StatelessWidget {
  final List<String> familiesNicknames;
  final Map<String, AsyncValue<ClothesSuggestion>> suggestionsMap;
  final int selectedIndex;
  final ValueChanged<int> onFamilyChanged;

  const _FamilySection({
    required this.familiesNicknames,
    required this.suggestionsMap,
    required this.selectedIndex,
    required this.onFamilyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (familiesNicknames.isEmpty) {
      return _Section(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SectionHeader(icon: Icons.group_outlined, title: '家族別の服装'),
            SizedBox(height: 12),
            Text('家族情報が未登録です。プロフィールから追加してください。'),
          ],
        ),
      );
    }

    // 家族ニックネームごとの提案を SceneClothes に変換して SceneSection を流用
    final List<SceneClothes> sceneList = familiesNicknames.map((label) {
      final async = suggestionsMap[label];
      String displayLabel = label;
      List<String> items = const [];
      String comment = '';

      if (async != null) {
        async.when(
          data: (c) {
            displayLabel = _canonicalNickname(c);
            items = List<String>.from(c.layers ?? const []);
            comment = c.summary ?? '';
          },
          loading: () {
            comment = '読み込み中…';
          },
          error: (_, __) {
            comment = '服装データを取得できませんでした';
          },
        );
      }

      return SceneClothes(
        scene: displayLabel,
        comment: comment,
        items: items,
        medicalNote: null,
      );
    }).toList();

    return _Section(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(icon: Icons.group_outlined, title: '本日の服装'),
          const SizedBox(height: 4),
          _SceneSection(
            sceneList: sceneList,
            selectedIndex: selectedIndex,
            onSceneChanged: onFamilyChanged,
            leadingInset: 0,
            extraLeftShift: -8,
          ),
        ],
      ),
    );
  }
}

String _canonicalNickname(ClothesSuggestion c) {
  final id = (c.userId ?? '').toLowerCase();
  if (id.contains('dad')) return 'パパ';
  if (id.contains('daughter')) return '娘';
  if (id.contains('son')) return '息子';
  if (id.contains('tarou') || id.contains('self')) return 'たろう';
  // Fallback: 年齢層からざっくり
  switch ((c.ageGroup ?? '').toLowerCase()) {
    case 'child':
      return 'こども';
    case 'adult':
      return 'おとな';
    default:
      return '家族';
  }
}

///////////////////////////////////////////////////////////////////////////////
// ④ 楽天おすすめ（既存）
///////////////////////////////////////////////////////////////////////////////

class _ProductsSection extends StatelessWidget {
  final AsyncValue<dynamic> clothesAsync;

  const _ProductsSection({required this.clothesAsync});

  @override
  Widget build(BuildContext context) {
    return _Section(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.shopping_bag_outlined,
            title: '今日のお天気アイテム',
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
// 商品カード（既存）
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
  final EdgeInsets? padding;
  const _Section({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF2F7FC),
      padding: padding ?? const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: child,
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
// ローディング / エラー（既存）
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
