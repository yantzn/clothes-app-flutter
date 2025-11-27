import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../components/product_card.dart';

class AnimatedClothesBottomSheet extends StatefulWidget {
  final dynamic clothes;

  const AnimatedClothesBottomSheet({super.key, required this.clothes});

  @override
  State<AnimatedClothesBottomSheet> createState() =>
      _AnimatedClothesBottomSheetState();
}

class _AnimatedClothesBottomSheetState extends State<AnimatedClothesBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );

    // 0.88 → 1.08 → 1.0 のバウンス
    _bounceAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.88,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.08,
          end: 1.00,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    _controller.reverse().then((_) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    final clothes = widget.clothes;
    final layers = List<String>.from(clothes.layers ?? []);

    return Stack(
      children: [
        // ------------------------------
        // ① 背景ぼかし + フェード
        // ------------------------------
        GestureDetector(
          onTap: _close,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: (_controller.value * 0.6).clamp(0, 0.6),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 12 * _controller.value,
                    sigmaY: 12 * _controller.value,
                  ),
                  child: Container(color: Colors.black.withOpacity(0.2)),
                ),
              );
            },
          ),
        ),

        // ------------------------------
        // ② バウンスする BottomSheet 本体
        // ------------------------------
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _bounceAnimation.value,
              alignment: Alignment.bottomCenter,
              child: child,
            );
          },
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.78,

              child: Material(
                // ← ★ ここを追加！
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent, // ← Material が背景になるため透明に
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      // ハンドルバー
                      Container(
                        width: 44,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '今日の服装',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _close,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clothes.summary,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),

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
                                '気温 ${clothes.temperature.value}° / '
                                '体感 ${clothes.temperature.feelsLike}°',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),

                              const SizedBox(height: 28),

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
                                    itemBuilder: (_, i) => ProductCard(
                                      product: clothes.products[i],
                                    ),
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
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
