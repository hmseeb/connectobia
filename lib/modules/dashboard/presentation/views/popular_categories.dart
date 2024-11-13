import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xffEFF1F5),
                    child: Icon(
                      LucideIcons.briefcase,
                      color: ShadColors.dark,
                    ),
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
