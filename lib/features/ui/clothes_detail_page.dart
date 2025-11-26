import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

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

            // ---------------------------------------------------------
            // 📌 参考リンク（カードUIに統一）
            // ---------------------------------------------------------
            if (c.references.isNotEmpty) ...[
              const SectionHeader(icon: Icons.link_outlined, title: '参考リンク'),
              const SizedBox(height: 12),
              ...c.references.map(
                (url) => Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text(
                      url,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () async {
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // ---------------------------------------------------------
            // 📌 楽天商品
            // ---------------------------------------------------------
            const SectionHeader(
              icon: Icons.shopping_bag_outlined,
              title: '楽天の商品',
            ),
            const SizedBox(height: 12),

            ...c.products.map(
              (p) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () async {
                    final uri = Uri.parse(p.url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: p.image,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.image_not_supported, size: 40),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // 商品名・店名・価格
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                p.shop,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${p.price} 円',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('エラー: $e')),
      ),
    );
  }
}
