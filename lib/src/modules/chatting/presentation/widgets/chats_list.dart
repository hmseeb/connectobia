import 'package:flutter/material.dart';

class ChatsList extends StatelessWidget {
  const ChatsList({
    super.key,
    required ScrollController scrollController,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
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
    );
  }
}
