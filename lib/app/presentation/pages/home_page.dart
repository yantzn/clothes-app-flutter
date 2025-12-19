import 'package:clothes_app/features/clothes/domain/entities/clothes_suggestion.dart';
import 'package:clothes_app/features/clothes/presentation/scene_clothes_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clothes_app/app/router.dart';

// ドメイン側プロバイダ
import 'package:clothes_app/features/weather/presentation/weather_providers.dart';
import 'package:clothes_app/features/clothes/presentation/clothes_providers.dart';
import 'package:clothes_app/features/clothes/presentation/family_scene_clothes_provider.dart';
import 'package:clothes_app/features/clothes/presentation/mappers/family_scene_mapper.dart';

// 共通コンポーネント
import 'package:clothes_app/core/widgets/section_header.dart';
import 'package:clothes_app/core/widgets/section_container.dart';
import 'package:clothes_app/features/clothes/presentation/widgets/scene_section.dart';
import 'package:clothes_app/features/weather/presentation/widgets/weather_hero_async.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedFamilyIndex = 0;

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(todayWeatherProvider);
    final clothesAsync = ref.watch(todayClothesProvider);
    final familySuggestionsMap = ref.watch(familySuggestionsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: '設定',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, AppRouter.settings),
          ),
        ],
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
              ],
            ),
          ),
        ),
      ),
    );
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
    if (familiesNicknames.isEmpty) {
      return const SectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
