import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class CustomBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 20),
              blurRadius: 20,
            ),
          ],
        ),
        child: SalomonBottomBar(
          margin: EdgeInsets.zero,
          itemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          currentIndex: selectedIndex,
          onTap: onTap,
          items: [
            _buildBottomBarItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              title: "Home",
              color: const Color(0xFF7553F6),
            ),
            _buildBottomBarItem(
              icon: Icons.space_dashboard_outlined,
              activeIcon: Icons.space_dashboard,
              title: "Manage",
              color: Colors.orange,
            ),
            _buildBottomBarItem(
              icon: Icons.notifications_outlined,
              activeIcon: Icons.notifications,
              title: "Alerts",
              color: Colors.pink,
            ),
            _buildBottomBarItem(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              title: "Settings",
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  SalomonBottomBarItem _buildBottomBarItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required Color color,
  }) {
    return SalomonBottomBarItem(
      icon: Icon(icon, size: 22),
      activeIcon: Icon(activeIcon, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      selectedColor: color,
      unselectedColor: Colors.grey,
    );
  }
}
