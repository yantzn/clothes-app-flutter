import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clothes_app/app/router.dart';
import 'package:clothes_app/features/profile/presentation/profile_providers.dart';
import 'package:clothes_app/features/profile/domain/profile.dart';

class ProfileViewPage extends ConsumerWidget {
  const ProfileViewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(effectiveProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      appBar: AppBar(
        title: const Text('プロファイル'),
        backgroundColor: const Color(0xFFF7FAFD),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: profileAsync.when(
          data: (p) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- プロフィールカード ----
              _ProfileCard(p: p),

              const Spacer(),

              // ---- 編集ボタン ----
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(editingProfileProvider.notifier).setProfile(p);
                    Navigator.pushNamed(context, AppRouter.profileEdit);
                  },
                  child: const Text('編集する'),
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('エラー: $e')),
        ),
      ),
    );
  }
}

// ================================
// プロフィール情報カード（白カード + 薄境界 + 丸み）
// ================================
class _ProfileCard extends StatelessWidget {
  final UserProfile p;

  const _ProfileCard({required this.p});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE7EDF3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            _row('ID', p.userId, icon: Icons.badge_outlined),
            const Divider(height: 24, thickness: 1, color: Color(0xFFE8EEF4)),
            _row('お住まいの地域', p.region, icon: Icons.place_outlined),
            const Divider(height: 24, thickness: 1, color: Color(0xFFE8EEF4)),
            _row(
              '生年月日',
              '${p.birthday.year}年${p.birthday.month}月${p.birthday.day}日',
              icon: Icons.cake_outlined,
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFE8EEF4)),
            _row(
              '通知',
              p.notificationsEnabled ? 'オン' : 'オフ',
              icon: Icons.notifications_none_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF6DB4F5)),
        const SizedBox(width: 16),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, color: Color(0xFF444444)),
          ),
        ),
      ],
    );
  }
}
