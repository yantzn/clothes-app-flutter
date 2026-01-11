import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clothes_app/features/onboarding/presentation/onboarding_providers.dart';
import 'package:clothes_app/features/onboarding/domain/entities/family_member_request.dart';
import 'package:clothes_app/core/theme.dart';
import 'package:clothes_app/core/widgets/date_picker_sheet.dart';
import 'package:clothes_app/core/widgets/app_snackbar.dart';
import '../../presentation/profile_providers.dart';
import 'package:clothes_app/features/profile/domain/entities/family_member.dart';

class FamilyEditPage extends ConsumerStatefulWidget {
  const FamilyEditPage({super.key});

  @override
  ConsumerState<FamilyEditPage> createState() => _FamilyEditPageState();
}

class _FamilyEditPageState extends ConsumerState<FamilyEditPage> {
  @override
  void initState() {
    super.initState();
    // 画面初期表示時にサーバーの家族情報でOnboardingを初期化（空の場合のみ）
    // これにより編集画面に既存の家族情報が表示される
    Future.microtask(() async {
      final current = ref.read(onboardingProvider);
      if (current.families.isEmpty) {
        try {
          final profile = await ref.read(effectiveProfileProvider.future);
          final list = profile.families.map((f) {
            return FamilyMemberRequest(
              name: f.name,
              birthday: _formatYmd(f.birthday),
              gender: _toUiGender(f.gender),
            );
          }).toList();
          ref.read(onboardingProvider.notifier).setFamilies(list);
        } catch (_) {
          // プロフィール取得に失敗した場合は何もしない（UIは空表示）
        }
      }
    });
  }

  String _formatYmd(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }

  String _toUiGender(String apiGender) {
    switch (apiGender) {
      case 'male':
        return '男性';
      case 'female':
        return '女性';
      case 'other':
        return 'その他';
      default:
        return 'その他';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final families = state.families;
    final canAddMore = families.length < 10;

    return Scaffold(
      appBar: AppBar(title: const Text('家族情報の編集')),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canAddMore
                    ? () => _openAddModal(context, ref)
                    : null,
                icon: const Icon(Icons.add),
                label: Text(canAddMore ? '家族を追加する' : '登録上限（10件）です'),
              ),
            ),
          ],
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
              onPressed: () async {
                final families = ref.read(onboardingProvider).families;
                final userId = ref.read(userIdProvider);
                if (userId == null || userId.isEmpty) {
                  if (context.mounted) {
                    AppSnackBar.showError(
                      context,
                      'ユーザー情報が取得できていません。やり直してください',
                    );
                  }
                  return;
                }
                try {
                  // 現在のプロフィールを取得し、familiesのみ差し替えてPATCH
                  final current = await ref.read(
                    effectiveProfileProvider.future,
                  );
                  final nextProfile = current.copyWith(
                    families: families.map((f) {
                      // Onboardingの文字列日付(YYYY/MM/DD)をDateTimeへ
                      try {
                        final parts = f.birthday.split('/');
                        final dt = DateTime(
                          int.parse(parts[0]),
                          int.parse(parts[1]),
                          int.parse(parts[2]),
                        );
                        return FamilyMember(
                          name: f.name,
                          birthday: dt,
                          gender: f.gender,
                        );
                      } catch (_) {
                        return FamilyMember(
                          name: f.name,
                          birthday: DateTime(2010, 1, 1),
                          gender: f.gender,
                        );
                      }
                    }).toList(),
                  );
                  // Provider経由で保存し、状態更新を伝播
                  await ref.read(profileProvider.notifier).save(nextProfile);
                  if (context.mounted) {
                    AppSnackBar.showSuccess(context, '保存しました');
                    Navigator.pop(context);
                  }
                } catch (_) {
                  if (context.mounted) {
                    AppSnackBar.showError(context, '保存に失敗しました。再度お試しください');
                  }
                }
              },
              child: const Text('保存する'),
            ),
          ),
        ),
      ),
    );
  }

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
          backgroundColor: AppTheme.lightBlue.withValues(alpha: 0.3),
          child: Text(
            f.name.isNotEmpty ? f.name[0] : '?',
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
            '${f.gender} / ${f.birthday}',
            style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
          ),
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              tooltip: '編集',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _openEditModal(context, ref, f, index),
            ),
            IconButton(
              tooltip: '削除',
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _confirmDelete(context, () {
                ref.read(onboardingProvider.notifier).removeFamily(index);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard() {
    return const Card(
      child: SizedBox(
        height: 160,
        child: Center(
          child: Text(
            '登録された家族はいません',
            style: TextStyle(fontSize: 15, color: AppTheme.textLight),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('削除確認'),
          content: const Text('この家族情報を削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  onDelete();
                  Navigator.pop(context);
                } catch (_) {
                  Navigator.pop(context);
                  AppSnackBar.showError(context, '保存に失敗しました。再度お試しください');
                }
              },
              child: const Text('削除する'),
            ),
          ],
        );
      },
    );
  }

  void _openAddModal(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final birthdayCtrl = TextEditingController();
    String gender = '男性';

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
                nameError = '名前は必須です';
              } else if (nameCtrl.text.length > 30) {
                nameError = '30文字以内で入力してください';
              }

              final reg = RegExp(r'^\d{4}/\d{2}/\d{2}$');
              if (birthdayCtrl.text.isEmpty) {
                birthdayError = '生年月日は必須です';
              } else if (!reg.hasMatch(birthdayCtrl.text)) {
                birthdayError = 'YYYY/MM/DD の形式で入力してください';
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
                              '家族を追加',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: nameCtrl,
                              decoration: InputDecoration(
                                labelText: '名前',
                                errorText: nameError,
                              ),
                              onChanged: (_) => validate(),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: birthdayCtrl,
                              decoration: InputDecoration(
                                labelText: '生年月日（YYYY/MM/DD）',
                                errorText: birthdayError,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_month),
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();
                                    final now = DateTime.now();
                                    DateTime initial = DateTime(2010, 1, 1);
                                    final reg = RegExp(r'^\d{4}/\d{2}/\d{2}$');
                                    if (reg.hasMatch(birthdayCtrl.text)) {
                                      try {
                                        final parts = birthdayCtrl.text.split(
                                          '/',
                                        );
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
                                      maximumDate: DateTime(
                                        now.year,
                                        now.month,
                                        now.day,
                                      ),
                                    );
                                    if (picked != null) {
                                      final formatted =
                                          '${picked.year.toString().padLeft(4, '0')}/'
                                          '${picked.month.toString().padLeft(2, '0')}/'
                                          '${picked.day.toString().padLeft(2, '0')}';
                                      birthdayCtrl.text = formatted;
                                      validate();
                                    }
                                  },
                                ),
                              ),
                              onChanged: (_) => validate(),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: gender,
                              decoration: const InputDecoration(
                                labelText: '性別',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: '男性',
                                  child: Text('男性'),
                                ),
                                DropdownMenuItem(
                                  value: '女性',
                                  child: Text('女性'),
                                ),
                                DropdownMenuItem(
                                  value: 'その他',
                                  child: Text('その他'),
                                ),
                              ],
                              onChanged: (v) {
                                gender = v ?? '男性';
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('キャンセル'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: isValid
                                      ? () {
                                          try {
                                            ref
                                                .read(
                                                  onboardingProvider.notifier,
                                                )
                                                .addFamily(
                                                  FamilyMemberRequest(
                                                    name: nameCtrl.text,
                                                    birthday: birthdayCtrl.text,
                                                    gender: gender,
                                                  ),
                                                );
                                            Navigator.pop(context);
                                          } catch (_) {
                                            AppSnackBar.showError(
                                              context,
                                              '保存に失敗しました。再度お試しください',
                                            );
                                          }
                                        }
                                      : null,
                                  child: const Text('追加'),
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

  void _openEditModal(
    BuildContext context,
    WidgetRef ref,
    FamilyMemberRequest f,
    int index,
  ) {
    final nameCtrl = TextEditingController(text: f.name);
    final birthdayCtrl = TextEditingController(text: f.birthday);
    String gender = f.gender;

    String? nameError;
    String? birthdayError;
    bool isValid = true; // 初期値は既存データがあるため true

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void validate() {
              nameError = null;
              birthdayError = null;
              if (nameCtrl.text.isEmpty) {
                nameError = '名前は必須です';
              } else if (nameCtrl.text.length > 30) {
                nameError = '30文字以内で入力してください';
              }
              final reg = RegExp(r'^\d{4}/\d{2}/\d{2}$');
              if (birthdayCtrl.text.isEmpty) {
                birthdayError = '生年月日は必須です';
              } else if (!reg.hasMatch(birthdayCtrl.text)) {
                birthdayError = 'YYYY/MM/DD の形式で入力してください';
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
                              '家族を編集',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: nameCtrl,
                              decoration: InputDecoration(
                                labelText: '名前',
                                errorText: nameError,
                              ),
                              onChanged: (_) => validate(),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: birthdayCtrl,
                              decoration: InputDecoration(
                                labelText: '生年月日（YYYY/MM/DD）',
                                errorText: birthdayError,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_month),
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();
                                    final now = DateTime.now();
                                    DateTime initial = DateTime(2010, 1, 1);
                                    final reg = RegExp(r'^\d{4}/\d{2}/\d{2}$');
                                    if (reg.hasMatch(birthdayCtrl.text)) {
                                      try {
                                        final parts = birthdayCtrl.text.split(
                                          '/',
                                        );
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
                                      maximumDate: DateTime(
                                        now.year,
                                        now.month,
                                        now.day,
                                      ),
                                    );
                                    if (picked != null) {
                                      final formatted =
                                          '${picked.year.toString().padLeft(4, '0')}/'
                                          '${picked.month.toString().padLeft(2, '0')}/'
                                          '${picked.day.toString().padLeft(2, '0')}';
                                      birthdayCtrl.text = formatted;
                                      validate();
                                    }
                                  },
                                ),
                              ),
                              onChanged: (_) => validate(),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: gender,
                              decoration: const InputDecoration(
                                labelText: '性別',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: '男性',
                                  child: Text('男性'),
                                ),
                                DropdownMenuItem(
                                  value: '女性',
                                  child: Text('女性'),
                                ),
                                DropdownMenuItem(
                                  value: 'その他',
                                  child: Text('その他'),
                                ),
                              ],
                              onChanged: (v) {
                                gender = v ?? '男性';
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('キャンセル'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: isValid
                                      ? () {
                                          try {
                                            ref
                                                .read(
                                                  onboardingProvider.notifier,
                                                )
                                                .updateFamily(
                                                  index,
                                                  FamilyMemberRequest(
                                                    name: nameCtrl.text,
                                                    birthday: birthdayCtrl.text,
                                                    gender: gender,
                                                  ),
                                                );
                                            Navigator.pop(context);
                                          } catch (_) {
                                            AppSnackBar.showError(
                                              context,
                                              '保存に失敗しました。再度お試しください',
                                            );
                                          }
                                        }
                                      : null,
                                  child: const Text('更新'),
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
