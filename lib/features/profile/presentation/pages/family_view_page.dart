import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clothes_app/features/profile/presentation/profile_providers.dart';
import 'package:clothes_app/core/theme.dart';

class FamilyViewPage extends ConsumerWidget {
  const FamilyViewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(effectiveProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      appBar: AppBar(
        title: const Text('家族情報'),
        backgroundColor: const Color(0xFFF7FAFD),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: profileAsync.when(
          data: (p) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ユーザーの簡易情報（ヘッダー）
              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: Color(0xFFE7EDF3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.badge_outlined,
                        color: Color(0xFF6DB4F5),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'ID: ${p.userId}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 家族一覧
              Expanded(
                child: p.families.isEmpty
                    ? const _EmptyCard()
                    : ListView.builder(
                        itemCount: p.families.length,
                        itemBuilder: (context, index) {
                          final f = p.families[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                radius: 22,
                                backgroundColor: AppTheme.lightBlue.withValues(
                                  alpha: 0.3,
                                ),
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
                                  '${f.gender} / ${f.birthday.year.toString().padLeft(4, '0')}/${f.birthday.month.toString().padLeft(2, '0')}/${f.birthday.day.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
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
}
