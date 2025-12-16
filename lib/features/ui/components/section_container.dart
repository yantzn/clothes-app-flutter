import 'package:flutter/material.dart';

/// 共通セクションの背景色・余白を統一するコンテナ
class SectionContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;

  const SectionContainer({
    super.key,
    required this.child,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // 画面幅が狭い場合は余白を少し詰める
    final EdgeInsets resolvedPadding =
        padding ??
        (width < 360
            ? const EdgeInsets.fromLTRB(16, 16, 16, 16)
            : const EdgeInsets.fromLTRB(20, 24, 20, 24));

    return Container(
      width: double.infinity,
      color: color ?? const Color(0xFFF2F7FC),
      padding: resolvedPadding,
      child: child,
    );
  }
}
