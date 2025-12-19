import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clothes_app/features/profile/domain/profile.dart';
import 'package:clothes_app/features/profile/presentation/profile_providers.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  late TextEditingController _regionController;
  late TextEditingController _birthdayController;
  late String _gender;
  late bool _notificationsEnabled;

  UserProfile? _baseProfile;

  @override
  void initState() {
    super.initState();
    final p = ref.read(editingProfileProvider);
    _baseProfile = p;

    _regionController = TextEditingController(text: p?.region ?? '');
    _birthdayController = TextEditingController(text: _formatDate(p?.birthday));
    _gender = p?.gender ?? 'male';
    _notificationsEnabled = p?.notificationsEnabled ?? true;
  }

  @override
  void dispose() {
    _regionController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      appBar: AppBar(
        title: const Text('プロファイル編集'),
        elevation: 0,
        backgroundColor: const Color(0xFFF7FAFD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---- 入力フォームを白カードにまとめる ----
            _ProfileFormCard(
              regionController: _regionController,
              birthdayController: _birthdayController,
              gender: _gender,
              onGenderChanged: (v) => setState(() => _gender = v),
              notificationsEnabled: _notificationsEnabled,
              onNotificationChanged: (v) =>
                  setState(() => _notificationsEnabled = v),
            ),

            const Spacer(),

            // ---- 保存ボタン ----
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('保存する'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    try {
      final parts = _birthdayController.text.split('-');
      final birthday = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      final base =
          _baseProfile ??
          UserProfile(
            userId: 'test-user-3',
            region: '',
            birthday: birthday,
            gender: _gender,
            notificationsEnabled: _notificationsEnabled,
          );

      final updated = base.copyWith(
        region: _regionController.text,
        birthday: birthday,
        gender: _gender,
        notificationsEnabled: _notificationsEnabled,
      );

      await ref.read(profileProvider.notifier).save(updated);
      ref.read(editingProfileProvider.notifier).setProfile(updated);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('保存しました（モック）')));
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('生年月日の形式が不正です')));
      }
    }
  }
}

// ======================================================
// 📦 入力フォームカード（白カード＋丸角 24px）
// ======================================================
class _ProfileFormCard extends StatelessWidget {
  final TextEditingController regionController;
  final TextEditingController birthdayController;
  final String gender;
  final Function(String) onGenderChanged;
  final bool notificationsEnabled;
  final Function(bool) onNotificationChanged;

  const _ProfileFormCard({
    required this.regionController,
    required this.birthdayController,
    required this.gender,
    required this.onGenderChanged,
    required this.notificationsEnabled,
    required this.onNotificationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE7EDF3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- 地域 ---
            _inputLabel('お住まいの地域'),
            TextField(
              controller: regionController,
              decoration: _inputDecoration('例：船橋市'),
            ),
            const SizedBox(height: 20),

            // --- 生年月日 ---
            _inputLabel('生年月日 (YYYY-MM-DD)'),
            TextField(
              controller: birthdayController,
              decoration: _inputDecoration('例：2015-09-20'),
            ),
            const SizedBox(height: 20),

            // --- 性別 ---
            _inputLabel('性別'),
            DropdownButtonFormField<String>(
              decoration: _dropdownDecoration(),
              initialValue: gender,
              items: const [
                DropdownMenuItem(value: 'male', child: Text('男性')),
                DropdownMenuItem(value: 'female', child: Text('女性')),
                DropdownMenuItem(value: 'other', child: Text('その他')),
              ],
              onChanged: (v) {
                if (v != null) onGenderChanged(v);
              },
            ),
            const SizedBox(height: 12),

            // --- 通知 ---
            SwitchListTile(
              contentPadding: const EdgeInsets.only(left: 4),
              title: const Text('通知を受け取る'),
              value: notificationsEnabled,
              onChanged: onNotificationChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF444444),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E6EC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E6EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6DB4F5), width: 1.4),
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E6EC)),
      ),
    );
  }
}
