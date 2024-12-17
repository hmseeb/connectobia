import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../theme/bloc/theme_bloc.dart';
import '../../../../theme/colors.dart';

class PopularCategories extends StatelessWidget {
  final List<String> _industries;

  const PopularCategories({
    super.key,
    required List<String> industries,
  }) : _industries = industries;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _industries.length,
        itemBuilder: (context, index) {
          return ShadTooltip(
            builder: (context) => Text(_industries[index]),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, state) {
                      return CircleAvatar(
                        radius: 36,
                        backgroundColor: state is DarkTheme
                            ? ShadColors.darkForeground.withValues(alpha: 0.5)
                            : ShadColors.lightForeground,
                        child: Icon(
                          LucideIcons.briefcase,
                          color: state is DarkTheme
                              ? ShadColors.light
                              : ShadColors.dark,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _industries[index].length > 15
                        ? '${_industries[index].substring(0, 15)}...'
                        : _industries[index],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
