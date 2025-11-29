import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import 'presentation/onboarding_providers.dart';
import 'domain/entities/family_member_request.dart';
import '../../core/theme.dart';

class RegisterFamilyPage extends ConsumerWidget {
  const RegisterFamilyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final families = state.families;
    final canAddMore = families.length < 10;

    return Scaffold(
      appBar: AppBar(title: const Text("家族情報の登録")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: families.isEmpty
                  ? _emptyCard()
                  : ListView.builder(
                      itemCount: families.length,
                      itemBuilder: (context, index) {
                        final f = families[index];
                        return _familyCard(context, ref, f, index);
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // ---- 家族追加ボタン ----
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canAddMore
                    ? () => _openAddModal(context, ref)
                    : null, // 10件以上は完全に非活性
                icon: const Icon(Icons.add),
                label: Text(canAddMore ? "家族を追加する" : "登録上限（10件）です"),
              ),
            ),

            const SizedBox(height: 20),

            // ---- 次へ（確認） 家族0件でも押せる ----
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRouter.confirmRegister),
                child: const Text("次へ（確認）"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =================================================================
  // 家族カード
  // =================================================================
  Widget _familyCard(
    BuildContext context,
    WidgetRef ref,
    FamilyMemberRequest f,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: AppTheme.lightBlue.withOpacity(0.3),
          child: Text(
            f.name.isNotEmpty ? f.name[0] : "?",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
        title: Text(
          f.name,
          style: const TextStyle(
            fontSize: 17,
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "${f.gender} / ${f.birthday}",
            style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _confirmDelete(context, () {
            ref.read(onboardingProvider.notifier).removeFamily(index);
          }),
        ),
      ),
    );
  }

  // =================================================================
  // 家族ゼロの場合のカード
  // =================================================================
  Widget _emptyCard() {
    return Card(
      child: SizedBox(
        height: 160,
        child: Center(
          child: Text(
            "登録された家族はいません",
            style: const TextStyle(fontSize: 15, color: AppTheme.textLight),
          ),
        ),
      ),
    );
  }

  // =================================================================
  // 削除確認
  // =================================================================
  void _confirmDelete(BuildContext context, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("削除確認"),
          content: const Text("この家族情報を削除しますか？"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("キャンセル"),
            ),
            ElevatedButton(
              onPressed: () {
                onDelete();
                Navigator.pop(context);
              },
              child: const Text("削除する"),
            ),
          ],
        );
      },
    );
  }

  // =================================================================
  // 家族追加モーダル（前回のバリデーション付き実装をそのまま使用）
  // =================================================================
  void _openAddModal(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final birthdayCtrl = TextEditingController();
    String gender = "男性";

    String? nameError;
    String? birthdayError;
    bool isValid = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void validate() {
              nameError = null;
              birthdayError = null;

              if (nameCtrl.text.isEmpty) {
                nameError = "名前は必須です";
              } else if (nameCtrl.text.length > 30) {
                nameError = "30文字以内で入力してください";
              }

              final reg = RegExp(r'^\d{4}/\d{2}/\d{2}$');
              if (birthdayCtrl.text.isEmpty) {
                birthdayError = "生年月日は必須です";
              } else if (!reg.hasMatch(birthdayCtrl.text)) {
                birthdayError = "YYYY/MM/DD の形式で入力してください";
              }

              isValid = (nameError == null && birthdayError == null);
              setState(() {});
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final dialogWidth = (maxWidth < 500 ? maxWidth * 0.95 : 450)
                      .toDouble();

                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: dialogWidth),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "家族を追加",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            TextField(
                              controller: nameCtrl,
                              decoration: InputDecoration(
                                labelText: "名前",
                                errorText: nameError,
                              ),
                              onChanged: (_) => validate(),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: birthdayCtrl,
                              decoration: InputDecoration(
                                labelText: "生年月日（YYYY/MM/DD）",
                                errorText: birthdayError,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_month),
                                  onPressed: () async {
                                    final now = DateTime.now();
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: now,
                                      firstDate: DateTime(1900),
                                      lastDate: now,
                                    );
                                    if (picked != null) {
                                      birthdayCtrl.text =
                                          "${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}";
                                      validate();
                                    }
                                  },
                                ),
                              ),
                              onChanged: (_) => validate(),
                            ),

                            const SizedBox(height: 16),

                            DropdownButtonFormField<String>(
                              value: gender,
                              decoration: const InputDecoration(
                                labelText: "性別",
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: "男性",
                                  child: Text("男性"),
                                ),
                                DropdownMenuItem(
                                  value: "女性",
                                  child: Text("女性"),
                                ),
                                DropdownMenuItem(
                                  value: "その他",
                                  child: Text("その他"),
                                ),
                              ],
                              onChanged: (v) {
                                gender = v ?? "男性";
                                setState(() {});
                              },
                            ),

                            const SizedBox(height: 24),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("キャンセル"),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: isValid
                                      ? () {
                                          ref
                                              .read(onboardingProvider.notifier)
                                              .addFamily(
                                                FamilyMemberRequest(
                                                  name: nameCtrl.text,
                                                  birthday: birthdayCtrl.text,
                                                  gender: gender,
                                                ),
                                              );
                                          Navigator.pop(context);
                                        }
                                      : null,
                                  child: const Text("追加"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
