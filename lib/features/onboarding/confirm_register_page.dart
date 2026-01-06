import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/router.dart';
import 'presentation/onboarding_providers.dart';
import 'domain/entities/register_request.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_snackbar.dart';

class ConfirmRegisterPage extends ConsumerStatefulWidget {
  const ConfirmRegisterPage({super.key});

  @override
  ConsumerState<ConfirmRegisterPage> createState() =>
      _ConfirmRegisterPageState();
}

class _ConfirmRegisterPageState extends ConsumerState<ConfirmRegisterPage> {
  bool _requested = false;

  @override
  void initState() {
    super.initState();
    _skipOnboardingIfRegisteredElseRequestNotification();
  }

  Future<void> _skipOnboardingIfRegisteredElseRequestNotification() async {
    // 既に登録済みならホームへ遷移
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (!mounted) return;
    if (userId != null && userId.isNotEmpty) {
      ref.read(userIdProvider.notifier).set(userId);
      await Navigator.pushReplacementNamed(context, AppRouter.home);
      return;
    }
    // 画面表示直後に一度だけ通知許可をリクエスト
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_requested) return;
      _requested = true;
      final current = ref.read(onboardingProvider);
      if (!current.notificationsEnabled) {
        final status = await Permission.notification.request();
        ref
            .read(onboardingProvider.notifier)
            .setNotificationsEnabled(status.isGranted);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("入力内容の確認")),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionCard(
                  context,
                  title: "基本情報",
                  children: [
                    _infoItem("ニックネーム", state.nickname),
                    _infoItem("地域", state.region),
                    _infoItem("生年月日", state.birthday),
                    _infoItem("性別", _genderLabel(state.gender)),
                  ],
                ),
                const SizedBox(height: 20),

                _sectionCard(
                  context,
                  title: "家族情報",
                  children: state.families.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              "登録された家族はいません",
                              style: TextStyle(
                                color: AppTheme.textLight,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ]
                      : state.families
                            .map(
                              (f) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _familyItem(
                                  name: f.name,
                                  gender: f.gender,
                                  birthday: f.birthday,
                                ),
                              ),
                            )
                            .toList(),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _submit(context),
              child: const Text("この内容で登録する"),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ■ 性別コード → 日本語ラベル
  // ------------------------------------------------------------
  String _genderLabel(String code) {
    switch (code) {
      case 'male':
        return '男性';
      case 'female':
        return '女性';
      case 'other':
        return 'その他';
      default:
        return code; // 想定外はそのまま表示
    }
  }

  // ------------------------------------------------------------
  // ■ カード
  // ------------------------------------------------------------
  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: AppTheme.textDark),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ■ 基本情報アイテム（ラベル＋値）
  // ------------------------------------------------------------
  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ■ 家族情報アイテム
  // ------------------------------------------------------------
  Widget _familyItem({
    required String name,
    required String gender,
    required String birthday,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$gender / $birthday",
          style: const TextStyle(fontSize: 14, color: AppTheme.textLight),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // ■ 登録処理
  // ------------------------------------------------------------
  Future<void> _submit(BuildContext context) async {
    try {
      final repo = ref.read(onboardingRepositoryProvider);
      final RegisterRequest req = ref
          .read(onboardingProvider.notifier)
          .toRequest();

      final userId = await repo.registerUser(req);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", userId);

      ref.read(userIdProvider.notifier).set(userId);

      if (context.mounted) {
        await Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.home,
          (_) => false,
        );
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.showError(context, '登録に失敗しました。再度お試しください');
      }
    }
  }
}
