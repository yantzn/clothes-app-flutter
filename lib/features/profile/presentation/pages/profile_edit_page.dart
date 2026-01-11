import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clothes_app/features/profile/domain/profile.dart';
import 'package:clothes_app/features/profile/presentation/profile_providers.dart';
import 'package:clothes_app/core/location/location_service.dart';
import 'package:clothes_app/core/theme.dart';
import 'package:clothes_app/features/onboarding/presentation/onboarding_providers.dart';
import 'package:clothes_app/core/widgets/app_snackbar.dart';
import 'package:clothes_app/core/widgets/date_picker_sheet.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  late TextEditingController _regionController;
  late TextEditingController _birthdayController;
  late TextEditingController _nicknameController;
  late String _gender;

  UserProfile? _baseProfile;
  bool _loadingLocation = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    final p = ref.read(editingProfileProvider);
    final ob = ref.read(onboardingProvider);
    _baseProfile = p;

    final initialRegion = (p?.region.isNotEmpty == true)
        ? p!.region
        : (ob.region.isNotEmpty ? ob.region : '');
    final initialBirthdayText = (p?.birthday != null)
        ? _formatDateSlash(p!.birthday)
        : (ob.birthday.isNotEmpty ? ob.birthday : '');
    final initialGender =
        p?.gender ?? (ob.gender.isNotEmpty ? ob.gender : 'male');

    final initialNickname = (p?.nickname.isNotEmpty == true)
        ? p!.nickname
        : (ob.nickname.isNotEmpty ? ob.nickname : '');
    _regionController = TextEditingController(text: initialRegion);
    _birthdayController = TextEditingController(text: initialBirthdayText);
    _nicknameController = TextEditingController(text: initialNickname);
    _gender = initialGender;

    // 実効プロフィールでの初期値上書き（API成功時はサーバ値を優先）
    _prefillFromEffective();
  }

  @override
  void dispose() {
    _regionController.dispose();
    _birthdayController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  String _formatDateSlash(DateTime? d) {
    if (d == null) return '';
    return '${d.year.toString().padLeft(4, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.day.toString().padLeft(2, '0')}';
  }

  void _showInfoSnack(String message) => AppSnackBar.show(context, message);

  Future<void> _prefillFromEffective() async {
    try {
      final effective = await ref.read(effectiveProfileProvider.future);
      if (!mounted) return;
      setState(() {
        _baseProfile = effective;
        _regionController.text = effective.region;
        _birthdayController.text = _formatDateSlash(effective.birthday);
        _gender = effective.gender;
        _nicknameController.text = effective.nickname;
      });
      // 編集用の保持にも反映
      ref.read(editingProfileProvider.notifier).setProfile(effective);
    } catch (_) {
      // フォールバック（オンボーディング初期値のまま）
    }
  }

  Future<void> _setRegionFromGPS() async {
    setState(() => _loadingLocation = true);
    try {
      final city = await LocationService.getCurrentCity();
      setState(() {
        _regionController.text = city;
        _permissionDenied = false;
      });
    } catch (e) {
      final msg = e.toString();
      String err;
      if (msg.contains('恒久的に拒否')) {
        err = '位置情報が恒久的に拒否されています。設定から許可してください';
      } else if (msg.contains('許可が必要')) {
        err = '位置情報が許可されていません。許可後に再取得してください';
      } else if (msg.contains('無効')) {
        err = '位置情報サービスが無効です。設定から有効化してください';
      } else {
        err = '取得できませんでした。再取得をお試しください';
      }
      setState(() {
        _permissionDenied = msg.contains('恒久的に拒否') || msg.contains('許可が必要');
      });
      if (mounted) _showInfoSnack(err);
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();

    final now = DateTime.now();
    DateTime initial = DateTime(2010, 1, 1);
    final reg = RegExp(r'^\d{4}/\d{2}/\d{2}$');
    if (reg.hasMatch(_birthdayController.text)) {
      try {
        final parts = _birthdayController.text.split('/');
        initial = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      } catch (_) {}
    } else if (_baseProfile?.birthday != null) {
      initial = _baseProfile!.birthday;
    }

    // selected は未使用のため削除

    final picked = await showDatePickerSheet(
      context,
      initial: initial,
      minimumDate: DateTime(1900),
      maximumDate: DateTime(now.year, now.month, now.day),
    );
    if (picked != null) {
      final formatted =
          '${picked.year.toString().padLeft(4, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _birthdayController.text = formatted;
      });
    }
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            children: [
              // ---- 入力フォームを白カードにまとめる ----
              _ProfileFormCard(
                nicknameController: _nicknameController,
                regionController: _regionController,
                birthdayController: _birthdayController,
                gender: _gender,
                onGenderChanged: (v) => setState(() => _gender = v),
                loadingLocation: _loadingLocation,
                permissionDenied: _permissionDenied,
                onTapLocation: () async {
                  FocusScope.of(context).unfocus();
                  if (_permissionDenied) {
                    _showInfoSnack('位置情報が許可されていません。許可後に再取得してください');
                    await LocationService.openLocationSettings();
                  } else {
                    await _setRegionFromGPS();
                  }
                },
                onTapBirthdayPicker: _pickDate,
              ),
            ],
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
            child: ElevatedButton(onPressed: _save, child: const Text('保存する')),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    // 1) 生年月日のパース（失敗時は形式エラーのSnackBar）
    DateTime birthday;
    try {
      final parts = _birthdayController.text.split('/');
      birthday = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '生年月日の形式が不正です',
              style: TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            backgroundColor: AppTheme.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      }
      return;
    }

    // 2) 更新データ生成
    // ユーザーID未設定の保存は禁止（フォールバックの test-user は使用しない）
    final base = _baseProfile;
    if (base == null || base.userId.isEmpty) {
      if (mounted) {
        AppSnackBar.showError(context, 'ユーザー情報が取得できていません。やり直してください');
      }
      return;
    }

    final updated = base.copyWith(
      region: _regionController.text,
      birthday: birthday,
      gender: _gender,
      notificationsEnabled: base.notificationsEnabled,
      nickname: _nicknameController.text,
    );

    // 3) API保存（通信エラーや登録失敗時のSnackBar表示）
    try {
      await ref.read(profileProvider.notifier).save(updated);
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, '保存に失敗しました。再度お試しください');
      }
      return;
    }

    // 4) 状態更新と成功通知
    ref.read(editingProfileProvider.notifier).setProfile(updated);
    ref.read(onboardingProvider.notifier).setNickname(_nicknameController.text);

    if (mounted) {
      AppSnackBar.showSuccess(context, '保存しました');
      Navigator.pop(context);
    }
  }
}

// ======================================================
// 📦 入力フォームカード（白カード＋丸角 24px）
// ======================================================
class _ProfileFormCard extends StatelessWidget {
  final TextEditingController nicknameController;
  final TextEditingController regionController;
  final TextEditingController birthdayController;
  final String gender;
  final Function(String) onGenderChanged;
  final bool loadingLocation;
  final bool permissionDenied;
  final VoidCallback onTapLocation;
  final VoidCallback onTapBirthdayPicker;

  const _ProfileFormCard({
    required this.nicknameController,
    required this.regionController,
    required this.birthdayController,
    required this.gender,
    required this.onGenderChanged,
    required this.loadingLocation,
    required this.permissionDenied,
    required this.onTapLocation,
    required this.onTapBirthdayPicker,
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
            // ---- ニックネーム ----
            _inputLabel('ニックネーム（30文字以内）'),
            TextField(
              controller: nicknameController,
              decoration: _inputDecoration('例：たろう'),
            ),
            const SizedBox(height: 20),

            // --- 地域（オンボーディングと同様のUI） ---
            _inputLabel('お住まいの地域（位置情報から取得）'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE0E6EC)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF6DB4F5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      regionController.text.isEmpty
                          ? '現在地から市区町村を取得します'
                          : regionController.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: regionController.text.isEmpty
                            ? const Color(0xFF8A8A8A)
                            : const Color(0xFF222222),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (loadingLocation)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      tooltip: permissionDenied ? '位置情報の設定を開く' : '現在地を再取得',
                      icon: Icon(
                        permissionDenied
                            ? Icons.location_disabled
                            : Icons.my_location,
                      ),
                      onPressed: onTapLocation,
                    ),
                ],
              ),
            ),
            if (permissionDenied) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onTapLocation,
                  child: const Text('位置情報の設定を開く'),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // --- 生年月日 ---
            _inputLabel('生年月日 (YYYY/MM/DD)'),
            TextField(
              controller: birthdayController,
              readOnly: false,
              keyboardType: TextInputType.datetime,
              decoration: _inputDecoration('例：2010/04/21').copyWith(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: onTapBirthdayPicker,
                ),
              ),
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
