import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../theme/bloc/theme_bloc.dart';
import '../../../../../theme/colors.dart';

BottomNavigationBar buildBottomNavigationBar({
  required int selectedIndex,
  required Function(int) onItemTapped,
  required ThemeState state,
}) {
  return BottomNavigationBar(
    currentIndex: selectedIndex,
    onTap: onItemTapped,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    unselectedItemColor:
        state is DarkTheme ? ShadColors.light : ShadColors.dark,
    selectedItemColor:
        state is LightTheme ? ShadColors.primary : ShadColors.primary,
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
