import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../core/location/location_service.dart';
import 'presentation/onboarding_providers.dart';

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
    _nickname = TextEditingController()..addListener(_validate);
    _region = TextEditingController()..addListener(_validate);
    final today = DateTime.now();
    _birthday = TextEditingController(
      text:
          "${today.year}/${today.month.toString().padLeft(2, '0')}/${today.day.toString().padLeft(2, '0')}",
    );
  }

  @override
  void dispose() {
    _nickname.dispose();
    _region.dispose();
    _birthday.dispose();
    super.dispose();
  }

  // ---- 全体バリデーション ----
  void _validate() {
    setState(() {
      // ニックネーム：必須 & 30文字以内
      if (_nickname.text.isEmpty) {
        _nicknameError = "ニックネームを入力してください";
      } else if (_nickname.text.length > 30) {
        _nicknameError = "ニックネームは30文字以内で入力してください";
      } else {
        _nicknameError = null;
      }

      // 地域：必須 & 20文字以内
      if (_region.text.isEmpty) {
        _regionError = "お住まいの地域を入力してください";
      } else if (_region.text.length > 20) {
        _regionError = "お住まいの地域は20文字以内で入力してください";
      } else {
        _regionError = null;
      }

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
      final year = int.parse(text.substring(0, 4));
      final month = int.parse(text.substring(5, 7));
      final day = int.parse(text.substring(8, 10));
      final date = DateTime(year, month, day);

      // 存在しない日付
      if (date.year != year || date.month != month || date.day != day) {
        return "存在しない日付です";
      }

      if (date.isAfter(DateTime.now())) {
        return "未来の日付は指定できません";
      }

      if (year < 1900) {
        return "1900年以降の日付を入力してください";
      }
    } catch (_) {
      return "日付の形式が不正です";
    }

    return null;
  }

  // ---- カレンダーで日付選択 ----
  Future<void> _pickDate() async {
    final now = DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(2010, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: "生年月日を選択",
    );

    if (date == null) return;

    final formatted =
        "${date.year.toString().padLeft(4, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.day.toString().padLeft(2, '0')}";

    setState(() {
      _birthday.text = formatted;
    });

    _validate();
  }

  // ---- GPSから地域取得 ----
  Future<void> _setRegionFromGPS() async {
    setState(() => _loadingLocation = true);

    try {
      final city = await LocationService.getCurrentCity();
      setState(() => _region.text = city);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("位置情報取得に失敗：$e")));
      }
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
    _validate();
  }

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
    final isButtonEnabled = isValid;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FAFD),
        elevation: 0,
        title: const Text("ユーザ基本情報"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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

                    // ---- 地域 ----
                    _label("お住まいの地域（20文字以内）"),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _region,
                            decoration: _inputDecoration(
                              "例：船橋市",
                            ).copyWith(errorText: _regionError),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: _loadingLocation
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.my_location),
                          onPressed: _loadingLocation
                              ? null
                              : _setRegionFromGPS,
                        ),
                      ],
                    ),
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
                    DropdownButtonFormField(
                      value: _gender,
                      decoration: _inputDecoration(""),
                      items: const [
                        DropdownMenuItem(value: "male", child: Text("男性")),
                        DropdownMenuItem(value: "female", child: Text("女性")),
                        DropdownMenuItem(value: "other", child: Text("その他")),
                      ],
                      onChanged: (v) => setState(() => _gender = v ?? "male"),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isButtonEnabled ? _next : null,
                child: const Text("次へ"),
              ),
            ),
          ],
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
