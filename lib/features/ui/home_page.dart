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
import 'components/custom_bottom_nav.dart';
import 'components/section_header.dart';
import 'components/weather_icon.dart';
import 'components/product_card.dart';
import 'components/scene_section.dart';
import 'components/bottom_sheets/animated_clothes_bottom_sheet.dart';
import 'package:clothes_app/features/clothes/presentation/mappers/family_scene_mapper.dart';
import 'components/section_container.dart';
import 'components/hero/weather_hero_async.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final weatherAsync = ref.watch(todayWeatherProvider);
    final clothesAsync = ref.watch(todayClothesProvider);
    final familySuggestionsMap = ref.watch(familySuggestionsProvider);

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
                WeatherHeroAsync(
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
// 今日の服装ナビ（既存のまま / 必要なら後で削除可能）
///////////////////////////////////////////////////////////////////////////////

class _MainClothesSection extends StatelessWidget {
  final AsyncValue<dynamic> clothesAsync;
  const _MainClothesSection({required this.clothesAsync});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
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
// _SceneSection は components/scene_section.dart に抽出

// _SceneDetailCard は共通化し components/scene_detail_card.dart に移動

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
      return SectionContainer(
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

    // 家族ニックネームごとの提案を SceneClothes に変換（UI外へ分離した純関数）
    final List<SceneClothes> sceneList = mapFamilySuggestionsToScenes(
      familiesNicknames,
      suggestionsMap,
    );

    return SectionContainer(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(icon: Icons.group_outlined, title: '本日の服装'),
          const SizedBox(height: 4),
          SceneSection(
            sceneList: sceneList,
            selectedIndex: selectedIndex,
            onSceneChanged: onFamilyChanged,
            leadingInset: SceneSection.indentToHeaderIcon(),
            extraLeftShift: SceneSection.nudgeLeftSmall(),
          ),
        ],
      ),
    );
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
    final screenWidth = MediaQuery.of(context).size.width;
    return SectionContainer(
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

              final bool isSmall = screenWidth < 360;
              return SizedBox(
                height: isSmall ? 170 : 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  // 大画面専用の余白拡張は削除
                  itemCount: products.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: isSmall ? 8 : 12),
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return ProductCard(product: p);
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

// ProductCard は components/product_card.dart を使用

// 共通セクションコンテナは components/section_container.dart へ抽出

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
