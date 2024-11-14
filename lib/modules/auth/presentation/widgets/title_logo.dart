import 'package:connectobia/common/widgets/logo.dart';
import 'package:connectobia/modules/auth/presentation/widgets/app_title.dart';
import 'package:flutter/material.dart';

class AppTitleLogo extends StatelessWidget {
  const AppTitleLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Logo(size: 50),
        AppTitle('onnectobia'),
      ],
    );
  }
}
