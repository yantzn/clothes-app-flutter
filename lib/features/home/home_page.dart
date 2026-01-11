import 'package:clothes_app/features/clothes/domain/entities/clothes_suggestion.dart';
import 'package:clothes_app/features/clothes/presentation/scene_clothes_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clothes_app/app/router.dart';

// ドメイン側プロバイダ
import 'package:clothes_app/features/weather/presentation/weather_providers.dart';
import 'package:clothes_app/features/clothes/presentation/family_scene_clothes_provider.dart';
import 'package:clothes_app/features/clothes/presentation/mappers/family_scene_mapper.dart';
import 'package:clothes_app/features/onboarding/presentation/onboarding_providers.dart';

// 共通コンポーネント
import 'package:clothes_app/core/widgets/section_header.dart';
import 'package:clothes_app/core/widgets/section_container.dart';
import 'package:clothes_app/features/clothes/presentation/widgets/scene_section.dart';
import 'package:clothes_app/features/weather/presentation/widgets/weather_hero_async.dart';
import 'package:clothes_app/features/home/presentation/home_providers.dart';
import 'package:clothes_app/features/home/domain/entities/home_today.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedFamilyIndex = 0;

  @override
  void initState() {
    super.initState();
    // ガード: userId 未設定なら Onboarding（利用規約）へ誘導
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(userIdProvider);
      if (userId == null && mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.terms);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(homeWeatherProvider);
    final familySuggestionsMap = ref.watch(familySuggestionsProvider);
    final homeAsync = ref.watch(homeSnapshotProvider);
    // Home APIのsummaryをヒーローの「今日のひとこと」に反映するための置き換え
    final AsyncValue<ClothesSuggestion> summaryClothesAsync = homeAsync
        .whenData((HomeToday data) {
          return ClothesSuggestion(
            userId: '',
            ageGroup: '',
            temperature: const TemperatureInfo(
              value: 0,
              feelsLike: 0,
              category: '',
            ),
            summary: data.summary,
            layers: const [],
            notes: const [],
            references: const [],
          );
        });

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: '設定',
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRouter.settings),
          ),
        ],
      ),

      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            // 一時的なローディング表示を出さずに静かに再取得
            await ref.read(homeSnapshotProvider.notifier).refreshSilently();
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
                  clothesAsync: summaryClothesAsync,
                ),

                // ② 今日のひとこと（重複回避のため Hero フッターに集約）

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
      // 家族情報が未登録の場合はホーム画面に何も表示しない
      return const SizedBox.shrink();
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
