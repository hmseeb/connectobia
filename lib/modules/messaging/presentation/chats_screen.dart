import 'package:connectobia/shared/presentation/widgets/transparent_appbar.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  late final ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

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
      body: ListView.separated(
        controller: _scrollController,
        itemBuilder: (context, index) {
          return ListTile(
            title: const Text('User Name'),
            subtitle: const Text('Last message'),
            leading: const CircleAvatar(
              child: Text('U'),
            ),
            onTap: () {
              Navigator.of(context, rootNavigator: true)
                  .pushNamed('/singleChatScreen');
            },
            // add trailing icon to show unread messages
            trailing: const Text('8 min ago'),
          );
        },
        separatorBuilder: (context, index) => Divider(
          height: 0,
        ),
        itemCount: 10,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
