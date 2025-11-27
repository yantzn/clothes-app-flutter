import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme.dart';

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
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _bounce = TweenSequence([
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
    final c = widget.clothes;

    return Stack(
      children: [
        // --------------------------------
        // 背景ぼかし
        // --------------------------------
        GestureDetector(
          onTap: _close,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
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

        // --------------------------------
        // BottomSheet 本体
        // --------------------------------
        AnimatedBuilder(
          animation: _bounce,
          builder: (_, child) {
            return Transform.scale(
              scale: _bounce.value,
              alignment: Alignment.bottomCenter,
              child: child,
            );
          },
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.86,
              child: Material(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // ——— ハンドルバー ———
                      Container(
                        width: 44,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      // ——— ヘッダー ———
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

                      // ——— コンテンツ全体スクロール ———
                      Expanded(
                        child: ListView(
                          children: [
                            // ---------------------------------------------------
                            // 📌 サマリカード
                            // ---------------------------------------------------
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  c.summary,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDark,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ---------------------------------------------------
                            // 📌 レイヤー構成
                            // ---------------------------------------------------
                            _sectionHeader(Icons.layers_outlined, 'レイヤー構成'),
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
                                      .map<Widget>(
                                        (layer) => Chip(
                                          label: Text(layer),
                                          backgroundColor: AppTheme.chipBg,
                                          labelStyle: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ---------------------------------------------------
                            // 📌 メモ
                            // ---------------------------------------------------
                            _sectionHeader(Icons.info_outline, 'メモ'),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppTheme.textDark),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ---------------------------------------------------
                            // 📌 参考リンク
                            // ---------------------------------------------------
                            if (c.references.isNotEmpty) ...[
                              _sectionHeader(Icons.link_outlined, '参考リンク'),
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
                                      // open URL
                                    },
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),

                            // ---------------------------------------------------
                            // 📌 楽天商品
                            // ---------------------------------------------------
                            _sectionHeader(
                              Icons.shopping_bag_outlined,
                              '楽天の商品',
                            ),
                            const SizedBox(height: 12),

                            ...c.products.map(
                              (p) => Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: p.imageUrl,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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

                            const SizedBox(height: 40),
                          ],
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

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBlue),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
