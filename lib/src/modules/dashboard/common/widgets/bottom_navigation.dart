import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

BottomNavigationBar buildBottomNavigationBar({
  required int selectedIndex,
  required Function(int) onItemTapped,
}) {
  return BottomNavigationBar(
    currentIndex: selectedIndex,
    onTap: onItemTapped,
    showUnselectedLabels: true,
    selectedFontSize: 12,
    unselectedFontSize: 12,
    type: BottomNavigationBarType.fixed,
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
        label: 'Chats',
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
