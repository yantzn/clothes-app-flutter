import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/router.dart';
import '../../core/location/location_service.dart';
import 'presentation/onboarding_providers.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/date_picker_sheet.dart';

class RegisterUserInfoPage extends ConsumerStatefulWidget {
  const RegisterUserInfoPage({super.key});

  @override
  ConsumerState<RegisterUserInfoPage> createState() =>
      _RegisterUserInfoPageState();
}

class _RegisterUserInfoPageState extends ConsumerState<RegisterUserInfoPage> {
  late final TextEditingController _nickname;
  late final TextEditingController _region;
  late final TextEditingController _birthday;

  String _gender = "male";
  bool _loadingLocation = false;

  // 位置情報取得エラー表示用
  bool _permissionDenied = false;

  // ---- バリデーションエラー ----
  String? _nicknameError;
  String? _regionError;
  String? _birthdayError;

  bool get isValid =>
      _nicknameError == null &&
      _regionError == null &&
      _birthdayError == null &&
      _nickname.text.isNotEmpty &&
      _region.text.isNotEmpty &&
      _birthday.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _skipOnboardingIfRegistered();
    _nickname = TextEditingController()..addListener(_validate);
    _region = TextEditingController()..addListener(_validate);
    final today = DateTime.now();
    _birthday = TextEditingController(
      text:
          "${today.year}/${today.month.toString().padLeft(2, '0')}/${today.day.toString().padLeft(2, '0')}",
    );

    // 画面表示後に位置情報の許可・取得を促す（初回のみ）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setRegionFromGPS();
    });
  }

  Future<void> _skipOnboardingIfRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (!mounted) return;
    if (userId != null && userId.isNotEmpty) {
      // 既に登録済み → userId を復元してホームへ
      ref.read(userIdProvider.notifier).set(userId);
      await Navigator.pushReplacementNamed(context, AppRouter.home);
    }
  }

  void _validate() {
    setState(() {
      if (_nickname.text.isEmpty) {
        _nicknameError = "ニックネームを入力してください";
      } else if (_nickname.text.length > 30) {
        _nicknameError = "ニックネームは30文字以内で入力してください";
      } else {
        _nicknameError = null;
      }

      // 地域：UIのエラーメッセージは表示しない。空判定のみでボタン制御。
      _regionError = null;

      // 生年月日：ルールは別関数で
      _birthdayError = _validateBirthday(_birthday.text);
    });
  }

  // ---- 生年月日バリデーション（YYYY/MM/DD） ----
  String? _validateBirthday(String text) {
    if (text.isEmpty) return "生年月日を入力してください";

    final reg = RegExp(r'^\d{4}/\d{2}/\d{2}$');
    if (!reg.hasMatch(text)) {
      return "生年月日は YYYY/MM/DD の形式で入力してください";
    }

    try {
      final parts = text.split('/');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      if (year < 1900) {
        return "1900年以降の日付を入力してください";
      }

      final now = DateTime.now();
      final date = DateTime(year, month, day);

      // 存在しない日付を弾く（例: 2024/02/30）
      if (date.year != year || date.month != month || date.day != day) {
        return "存在しない日付です";
      }

      // 未来日を弾く
      if (date.isAfter(DateTime(now.year, now.month, now.day))) {
        return "未来の日付は入力できません";
      }
    } catch (_) {
      return "日付の形式が不正です";
    }

    return null;
  }

  // ---- カレンダーで日付選択 ----
  Future<void> _pickDate() async {
    // キーボードが開いている場合は閉じる
    FocusScope.of(context).unfocus();

    final now = DateTime.now();
    // 現在のテキストから初期値を決定（不正ならデフォルト）
    DateTime initial = DateTime(2010, 1, 1);
    final reg = RegExp(r'^\d{4}/\d{2}/\d{2}$');
    if (reg.hasMatch(_birthday.text)) {
      try {
        final parts = _birthday.text.split('/');
        initial = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      } catch (_) {}
    }

    final picked = await showDatePickerSheet(
      context,
      initial: initial,
      minimumDate: DateTime(1900),
      maximumDate: DateTime(now.year, now.month, now.day),
    );
    if (picked != null) {
      final formatted =
          "${picked.year.toString().padLeft(4, '0')}/"
          "${picked.month.toString().padLeft(2, '0')}/"
          "${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _birthday.text = formatted;
      });
      _validate();
    }
  }

  // ---- GPSから地域取得 ----
  Future<void> _setRegionFromGPS() async {
    setState(() => _loadingLocation = true);

    try {
      final city = await LocationService.getCurrentCity();
      setState(() {
        _region.text = city;
        _permissionDenied = false;
      });
    } catch (e) {
      final msg = e.toString();
      String err;
      if (msg.contains("恒久的に拒否")) {
        err = "位置情報が恒久的に拒否されています。設定から許可してください";
      } else if (msg.contains("許可が必要")) {
        err = "位置情報が許可されていません。許可後に再取得してください";
      } else if (msg.contains("無効")) {
        err = "位置情報サービスが無効です。設定から有効化してください";
      } else {
        err = "取得できませんでした。再取得をお試しください";
      }

      setState(() {
        _permissionDenied = msg.contains("恒久的に拒否") || msg.contains("許可が必要");
      });
      // 控えめな通知（赤い固定バナーは使わない）
      if (mounted) {
        _showInfoSnack(err);
      }
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
    _validate();
  }

  void _showInfoSnack(String message) => AppSnackBar.show(context, message);

  // ---- 次へ ----
  void _next() {
    // 最終バリデーション
    _validate();

    if (!isValid) return;

    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setNickname(_nickname.text);
    notifier.setRegion(_region.text);
    notifier.setBirthday(_birthday.text);
    notifier.setGender(_gender);

    Navigator.pushNamed(context, AppRouter.registerFamily);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFD),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7FAFD),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text("プロフィール"),
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
                Card(
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
                        _label("ニックネーム（30文字以内）"),
                        TextField(
                          controller: _nickname,
                          decoration: _inputDecoration(
                            "例：たろう",
                          ).copyWith(errorText: _nicknameError),
                        ),
                        const SizedBox(height: 20),

                        // ---- 地域（TextField以外の表示）----
                        _label("お住まいの地域（位置情報から取得）"),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE0E6EC)),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF6DB4F5),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _region.text.isEmpty
                                      ? "現在地から市区町村を取得します"
                                      : _region.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _region.text.isEmpty
                                        ? const Color(0xFF8A8A8A)
                                        : const Color(0xFF222222),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_loadingLocation)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                IconButton(
                                  tooltip: _permissionDenied
                                      ? "位置情報の設定を開く"
                                      : "現在地を再取得",
                                  icon: Icon(
                                    _permissionDenied
                                        ? Icons.location_disabled
                                        : Icons.my_location,
                                  ),
                                  onPressed: () async {
                                    // キーボードが開いている場合は閉じてトーストが見えるようにする
                                    FocusScope.of(context).unfocus();
                                    if (_permissionDenied) {
                                      _showInfoSnack(
                                        "位置情報が許可されていません。許可後に再取得してください",
                                      );
                                      await LocationService.openLocationSettings();
                                    } else {
                                      await _setRegionFromGPS();
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                        if (_permissionDenied) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () async {
                                await LocationService.openLocationSettings();
                              },
                              child: const Text("位置情報の設定を開く"),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),

                        // ---- 生年月日 ----
                        _label("生年月日 (YYYY/MM/DD)"),
                        TextField(
                          controller: _birthday,
                          // 手入力も可能
                          readOnly: false,
                          keyboardType: TextInputType.datetime,
                          decoration: _inputDecoration("例：2010/04/21").copyWith(
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_month),
                              onPressed: _pickDate,
                            ),
                            errorText: _birthdayError,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ---- 性別 ----
                        _label("性別"),
                        DropdownButtonFormField<String>(
                          initialValue: _gender,
                          decoration: _inputDecoration(""),
                          items: const [
                            DropdownMenuItem<String>(
                              value: "male",
                              child: Text("男性"),
                            ),
                            DropdownMenuItem<String>(
                              value: "female",
                              child: Text("女性"),
                            ),
                            DropdownMenuItem<String>(
                              value: "other",
                              child: Text("その他"),
                            ),
                          ],
                          onChanged: (String? v) =>
                              setState(() => _gender = v ?? "male"),
                        ),
                      ],
                    ),
                  ),
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
              child: ElevatedButton(
                onPressed: isValid ? _next : null,
                child: const Text("次へ"),
              ),
            ),
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

  Widget _label(String text) {
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
}
