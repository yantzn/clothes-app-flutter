import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../components/product_card.dart';

class ClothesDetailSheet extends StatelessWidget {
  final dynamic clothes;

  const ClothesDetailSheet({super.key, required this.clothes});

  @override
  Widget build(BuildContext context) {
    final layers = List<String>.from(clothes.layers ?? []);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            children: [
              // ハンドル
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // ヘッダー
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '今日の服装',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 今日のひとこと
                      Text(
                        clothes.summary,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),

                      // 服装チップ
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: layers
                            .map(
                              (l) => Chip(
                                label: Text(l),
                                backgroundColor: AppTheme.primaryBlue
                                    .withOpacity(0.1),
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        '気温 ${clothes.temperature.value}° / 体感 ${clothes.temperature.feelsLike}°',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 24),

                      if ((clothes.products ?? []).isNotEmpty) ...[
                        Text(
                          'おすすめアイテム',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: clothes.products.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, i) =>
                                ProductCard(product: clothes.products[i]),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
