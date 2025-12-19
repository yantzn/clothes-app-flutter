import 'package:flutter/material.dart';

class ChoiceChipRow extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final IconData Function(String label)? iconBuilder;
  final double leadingInset;
  final double extraLeftShift;
  final bool compact;

  const ChoiceChipRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.iconBuilder,
    this.leadingInset = 0,
    this.extraLeftShift = 0,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    // コンパクト表示のデフォルト密度（単一文字は個別に上書き）
    final visualDensity = compact
        ? const VisualDensity(horizontal: -1, vertical: -1)
        : VisualDensity.standard;
    final baseLabelPadding = compact
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    return Transform.translate(
      offset: Offset(extraLeftShift, 0),
      child: Container(
        padding: EdgeInsets.only(left: leadingInset),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(labels.length, (i) {
              final isActive = i == selectedIndex;
              final label = labels[i];
              // 一文字の場合は高さを確保（余白・行間・密度・タップターゲットを調整）
              final bool isSingleChar = label.trim().length == 1;
              final EdgeInsets labelPadding = isSingleChar
                  ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
                  : baseLabelPadding;
              final TextStyle? labelStyle = isSingleChar
                  ? Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontSize: 13,
                      height: 1.25,
                    )
                  : null;
              final VisualDensity chipDensity = isSingleChar
                  ? const VisualDensity(horizontal: -0.5, vertical: 0)
                  : visualDensity;
              final MaterialTapTargetSize tapTarget = isSingleChar
                  ? MaterialTapTargetSize.padded
                  : MaterialTapTargetSize.shrinkWrap;
              final icon = iconBuilder?.call(label);

              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  avatar: icon == null
                      ? null
                      : Icon(
                          icon,
                          size: 18,
                          color: isActive
                              ? Theme.of(context).primaryColor
                              : Colors.grey[500],
                        ),
                  label: Text(label, style: labelStyle),
                  materialTapTargetSize: tapTarget,
                  visualDensity: chipDensity,
                  labelPadding: labelPadding,
                  selected: isActive,
                  onSelected: (_) => onChanged(i),
                  selectedColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.15),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
