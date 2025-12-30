import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:clothes_app/app/router.dart';
import 'package:clothes_app/features/onboarding/presentation/onboarding_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _startAppFlow();
  }

  /// アプリ起動時の初回チェック & 遷移
  Future<void> _startAppFlow() async {
    // --- ロゴ表示演出（最低表示時間） ---
    const minSplashDuration = Duration(seconds: 2);
    await Future.delayed(minSplashDuration);

    // --- userId 読み取り ---
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (!mounted) return;

    if (userId == null) {
      // ===================================================
      //  初回アクセス → 利用規約へ
      // ===================================================
      await Navigator.pushReplacementNamed(context, AppRouter.terms);
      return;
    }

    // ===================================================
    //  2回目以降 → userId を Riverpod にセット → ホームへ
    // ===================================================
    ref.read(userIdProvider.notifier).set(userId);

    await Navigator.pushReplacementNamed(context, AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TODO: SvgPicture に差し替え予定
              SizedBox(height: 24),
              Text(
                'お天気服装',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'アドバイス',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
