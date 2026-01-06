import 'package:flutter/material.dart';
import 'package:clothes_app/app/router.dart';
import 'package:clothes_app/core/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clothes_app/features/onboarding/presentation/onboarding_providers.dart';
import 'package:clothes_app/features/profile/presentation/profile_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  String _genderLabel(String code) {
    switch (code) {
      case 'male':
        return '男性';
      case 'female':
        return '女性';
      default:
        return 'その他';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: '閉じる',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ユーザ情報表示
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ユーザ情報はプロフィールプロバイダ優先で表示（戻り後も最新が反映）
                  profileAsync.when(
                    loading: () => const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.info_outline,
                            color: AppTheme.lightBlue,
                          ),
                          title: Text(
                            'ユーザ情報',
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            '読み込み中…',
                            style: TextStyle(color: AppTheme.textLight),
                          ),
                        ),
                      ],
                    ),
                    error: (error, stackTrace) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.info_outline,
                            color: AppTheme.lightBlue,
                          ),
                          title: const Text(
                            'ユーザ情報',
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: IconButton(
                            tooltip: '編集',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () async {
                              // API取得に失敗していても effectiveProfileProvider 経由でフォールバック生成
                              final ep = await ref.read(
                                effectiveProfileProvider.future,
                              );
                              ref
                                  .read(editingProfileProvider.notifier)
                                  .setProfile(ep);
                              if (context.mounted) {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.profileEdit,
                                );
                              }
                            },
                          ),
                        ),
                        // フォールバックとしてオンボーディングの値を表示
                        ListTile(
                          dense: true,
                          title: const Text(
                            'ニックネーム',
                            style: TextStyle(color: AppTheme.textLight),
                          ),
                          subtitle: Text(
                            onboarding.nickname.isEmpty
                                ? '未設定'
                                : onboarding.nickname,
                            style: const TextStyle(color: AppTheme.textDark),
                          ),
                        ),
                        ListTile(
                          dense: true,
                          title: const Text(
                            '地域',
                            style: TextStyle(color: AppTheme.textLight),
                          ),
                          subtitle: Text(
                            onboarding.region.isEmpty
                                ? '未設定'
                                : onboarding.region,
                            style: const TextStyle(color: AppTheme.textDark),
                          ),
                        ),
                        ListTile(
                          dense: true,
                          title: const Text(
                            '生年月日',
                            style: TextStyle(color: AppTheme.textLight),
                          ),
                          subtitle: Text(
                            onboarding.birthday.isEmpty
                                ? '未設定'
                                : onboarding.birthday,
                            style: const TextStyle(color: AppTheme.textDark),
                          ),
                        ),
                        ListTile(
                          dense: true,
                          title: const Text(
                            '性別',
                            style: TextStyle(color: AppTheme.textLight),
                          ),
                          subtitle: Text(
                            _genderLabel(onboarding.gender),
                            style: const TextStyle(color: AppTheme.textDark),
                          ),
                        ),
                      ],
                    ),
                    data: (p) => Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.info_outline,
                            color: AppTheme.lightBlue,
                          ),
                          title: const Text(
                            'ユーザ情報',
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: IconButton(
                            tooltip: '編集',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              // 編集用に現在のプロフィールをセットしてから遷移
                              ref
                                  .read(editingProfileProvider.notifier)
                                  .setProfile(p);
                              Navigator.pushNamed(
                                context,
                                AppRouter.profileEdit,
                              );
                            },
                          ),
                        ),
                        // ニックネームはオンボーディングにのみ保持されている想定のため補助表示
                        ListTile(
                          dense: true,
                          title: const Text(
                            'ニックネーム',
                            style: TextStyle(color: AppTheme.textLight),
                          ),
                          subtitle: Text(
                            onboarding.nickname.isEmpty
                                ? '未設定'
                                : onboarding.nickname,
                            style: const TextStyle(color: AppTheme.textDark),
                          ),
                        ),
                        // プロファイル優先、未設定はオンボーディング値にフォールバック
                        ListTile(
                          dense: true,
                          title: const Text(
                            '地域',
                            style: TextStyle(color: AppTheme.textLight),
                          ),
                          subtitle: Text(
                            (p.region.isNotEmpty
                                ? p.region
                                : (onboarding.region.isNotEmpty
                                      ? onboarding.region
                                      : '未設定')),
                            style: const TextStyle(color: AppTheme.textDark),
                          ),
                        ),
                        ListTile(
                          dense: true,
                          title: const Text(
                            '生年月日',
                            style: TextStyle(color: AppTheme.textLight),
                          ),
                          subtitle: Text(
                            '${p.birthday.year.toString().padLeft(4, '0')}/${p.birthday.month.toString().padLeft(2, '0')}/${p.birthday.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: AppTheme.textDark),
                          ),
                        ),
                        ListTile(
                          dense: true,
                          title: const Text(
                            '性別',
                            style: TextStyle(color: AppTheme.textLight),
                          ),
                          subtitle: Text(
                            _genderLabel(
                              (p.gender.isNotEmpty
                                  ? p.gender
                                  : onboarding.gender),
                            ),
                            style: const TextStyle(color: AppTheme.textDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 家族情報表示
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.group_outlined,
                      color: AppTheme.lightBlue,
                    ),
                    title: const Text(
                      '家族情報',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: IconButton(
                      tooltip: '編集',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.profileFamilyEdit,
                        );
                      },
                    ),
                  ),
                  if (onboarding.families.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        '未登録',
                        style: TextStyle(color: AppTheme.textLight),
                      ),
                    )
                  else
                    ...onboarding.families.map(
                      (f) => ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.person_outline,
                          color: AppTheme.lightBlue,
                        ),
                        title: Text(
                          f.name,
                          style: const TextStyle(color: AppTheme.textDark),
                        ),
                        subtitle: Text(
                          '生年月日: ${f.birthday} / 性別: ${_genderLabel(f.gender)}',
                          style: const TextStyle(color: AppTheme.textLight),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 通知設定（プロフィールの通知設定を反映・更新）
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: profileAsync.when(
              loading: () => const SwitchListTile(
                title: Text('通知設定', style: TextStyle(color: AppTheme.textDark)),
                subtitle: Text(
                  '天気や服装の更新を受け取る',
                  style: TextStyle(color: AppTheme.textLight),
                ),
                value: false,
                onChanged: null,
                secondary: Icon(Icons.notifications_none),
              ),
              error: (error, stackTrace) => ListTile(
                leading: const Icon(
                  Icons.notifications_off_outlined,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  '通知設定を取得できませんでした',
                  style: TextStyle(color: AppTheme.textDark),
                ),
                subtitle: const Text(
                  '時間をおいて再度お試しください',
                  style: TextStyle(color: AppTheme.textLight),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.refresh(profileProvider.future),
                ),
              ),
              data: (p) => SwitchListTile(
                title: const Text(
                  '通知設定',
                  style: TextStyle(color: AppTheme.textDark),
                ),
                subtitle: const Text(
                  '天気や服装の更新を受け取る',
                  style: TextStyle(color: AppTheme.textLight),
                ),
                value: p.notificationsEnabled,
                onChanged: (v) async {
                  await ref
                      .read(profileProvider.notifier)
                      .save(p.copyWith(notificationsEnabled: v));
                },
                secondary: const Icon(Icons.notifications_none),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // プライバシーポリシー
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const ListTile(
              leading: Icon(Icons.privacy_tip_outlined),
              title: Text(
                'プライバシーポリシー',
                style: TextStyle(color: AppTheme.textDark),
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
          ),

          // 利用規約
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const ListTile(
              leading: Icon(Icons.description_outlined),
              title: Text('利用規約', style: TextStyle(color: AppTheme.textDark)),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
          ),

          const SizedBox(height: 40),

          Center(
            child: Text(
              'バージョン 1.0.0',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
