import 'package:flutter/material.dart';

import '../../../../common/widgets/logo.dart';
import 'app_title.dart';

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
        AppTitle('nnectobia'),
      ],
    );
  }
}
