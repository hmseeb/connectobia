import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/presentation/widgets/transparent_app_bar.dart';
import '../widgets/chats_list.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  late final ScrollController _scrollController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: transparentAppBar(
        'Chats',
        context: context,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search),
            onPressed: () {},
          ),
          IconButton(onPressed: () {}, icon: const Icon(LucideIcons.plus)),
        ],
      ),
      body: ChatsList(scrollController: _scrollController),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }
}
