import 'package:connectobia/src/modules/chatting/application/chats/chats_bloc.dart';
import 'package:connectobia/src/modules/chatting/presentation/widgets/chats_list.dart';
import 'package:connectobia/src/shared/application/theme/theme_bloc.dart';
import 'package:connectobia/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  late final ScrollController _scrollController;
  final TextEditingController textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return SliverAppBar(
                  backgroundColor:
                      state is DarkTheme ? ShadColors.dark : ShadColors.light,
                  elevation: 0,
                  floating: true,
                  pinned: true,
                  scrolledUnderElevation: 0,
                  centerTitle: false,
                  title: Text('Chats'),
                  snap: true,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(69),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: BlocBuilder<ChatsBloc, ChatsState>(
                        builder: (context, state) {
                          return ShadInputFormField(
                            controller: textController,
                            placeholder: Text('Search for a chat'),
                            prefix: const Icon(LucideIcons.search),
                            onChanged: (value) {
                              BlocProvider.of<ChatsBloc>(context)
                                  .add(FilterChats(filter: value));
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ];
        },
        body: ChatsList(scrollController: _scrollController),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }
}
