import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF6DB4F5);
    const inactiveColor = Color(0xFF9AA6B2);
    const bgColor = Colors.white;

    final items = [
      const _NavItemData(icon: Icons.home_outlined, label: "服装"),
      const _NavItemData(icon: Icons.checkroom_outlined, label: "おすすめ"),
      const _NavItemData(icon: Icons.settings_outlined, label: "設定"),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          items.length,
          (i) => Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => onTap(i),
              child: _BottomNavItem(
                data: items[i],
                isActive: i == currentIndex,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final _NavItemData data;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;

  const _BottomNavItem({
    required this.data,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            data.icon,
            size: 22,
            color: isActive ? activeColor : inactiveColor,
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;

  const _NavItemData({required this.icon, required this.label});
}
