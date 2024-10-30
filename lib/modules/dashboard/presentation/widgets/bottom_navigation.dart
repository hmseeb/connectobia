import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

BottomNavigationBar buildBottomNavigationBar({
  required int selectedIndex,
  required Function(int) onItemTapped,
  required Brightness brightness,
}) {
  return BottomNavigationBar(
    currentIndex: selectedIndex,
    onTap: onItemTapped,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    unselectedItemColor: brightness == Brightness.light
        ? ShadColors.kPrimary
        : ShadColors.kBackground,
    selectedItemColor: brightness == Brightness.light
        ? ShadColors.kSecondary
        : ShadColors.kSecondary,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(
          LucideIcons.house,
        ),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(LucideIcons.briefcase),
        label: 'Campaigns',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          LucideIcons.messageCircle,
        ),
        label: 'Chat',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          LucideIcons.bell,
        ),
        label: 'Notifications',
      ),
    ],
  );
}
