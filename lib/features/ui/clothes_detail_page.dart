import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme.dart';
import '../../features/clothes/presentation/clothes_providers.dart';
import 'components/section_header.dart';

class ClothesDetailPage extends ConsumerWidget {
  const ClothesDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clothesAsync = ref.watch(todayClothesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日の服装のヒント'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: clothesAsync.when(
        data: (c) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ---------------------------------------------------------
            // 📌 サマリカード
            // ---------------------------------------------------------
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  c.summary,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ---------------------------------------------------------
            // 📌 レイヤー構成
            // ---------------------------------------------------------
            const SectionHeader(icon: Icons.layers_outlined, title: 'レイヤー構成'),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: c.layers
                      .map(
                        (layer) => Chip(
                          label: Text(layer),
                          backgroundColor: AppTheme.chipBg,
                          labelStyle: const TextStyle(fontSize: 13),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ---------------------------------------------------------
            // 📌 メモ
            // ---------------------------------------------------------
            const SectionHeader(icon: Icons.info_outline, title: 'メモ'),
            const SizedBox(height: 12),
            ...c.notes.map(
              (note) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    note,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.textDark),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('エラー: $e')),
      ),
    );
  }
}
