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
    final visualDensity = compact
        ? const VisualDensity(horizontal: -1, vertical: -2)
        : VisualDensity.standard;
    final labelPadding = compact
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
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
                  label: Text(label),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: visualDensity,
                  labelPadding: labelPadding,
                  selected: isActive,
                  onSelected: (_) => onChanged(i),
                  selectedColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.15),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
