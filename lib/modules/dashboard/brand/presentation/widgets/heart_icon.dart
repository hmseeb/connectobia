import 'package:connectobia/theme/bloc/theme_bloc.dart';
import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FeatureHeartIcon extends StatelessWidget {
  const FeatureHeartIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      right: 20,
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return CircleAvatar(
            backgroundColor:
                state is DarkTheme ? ShadColors.dark : ShadColors.light,
            child: IconButton(
              icon: Icon(
                LucideIcons.heart,
                color: state is DarkTheme ? ShadColors.light : ShadColors.dark,
              ),
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }
}
