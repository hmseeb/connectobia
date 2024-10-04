import 'package:flutter/material.dart';

AppBar transparentAppBar(String? title, {List<Widget>? actions}) {
  return AppBar(
    title: Text(title ?? ''),
    backgroundColor: Colors.transparent,
    actions: actions,
  );
}
