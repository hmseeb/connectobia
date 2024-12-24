import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/src/modules/chatting/application/chats/chats_bloc.dart';
import 'package:connectobia/src/modules/chatting/presentation/widgets/first_message.dart';
import 'package:connectobia/src/shared/application/realtime/messaging/realtime_messaging_bloc.dart';
import 'package:connectobia/src/shared/data/constants/avatar.dart';
import 'package:connectobia/src/shared/data/constants/date_and_time.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:connectobia/src/shared/data/singletons/account_type.dart';
import 'package:connectobia/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatsList extends StatelessWidget {
  final ScrollController _scrollController;

  const ChatsList({
    super.key,
    required ScrollController scrollController,
  }) : _scrollController = scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatsBloc, ChatsState>(
      listener: (context, state) {
        if (state is ChatsLoadingError) {
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: Text(state.message),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ChatsLoaded) {
          if (state.chats.totalItems == 0) {
            return Column(
              children: [
                Spacer(),
                NoMatchWidget(
                  title: 'No chats yet',
                  subTitle: 'This is the very beginning of something great',
                ),
                Spacer(),
              ],
            );
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: state.chats.items.length,
            itemBuilder: (context, index) {
              bool isBrand = CollectionNameSingleton.instance == 'brands';
              final chat = state.chats.items[index];
              late bool isMe;
              if (isBrand) {
                isMe = chat.expand!.message.senderId == chat.expand!.brand.id;
              } else {
                isMe =
                    chat.expand!.message.senderId == chat.expand!.influencer.id;
              }
              return ListTile(
                onTap: () {
                  String userId = isBrand
                      ? chat.expand!.influencer.id
                      : chat.expand!.brand.id;
                  String name = isBrand
                      ? chat.expand!.influencer.fullName
                      : chat.expand!.brand.brandName;
                  String avatar = isBrand
                      ? chat.expand!.influencer.avatar
                      : chat.expand!.brand.avatar;
                  String collectionId = isBrand
                      ? chat.expand!.influencer.collectionId
                      : chat.expand!.brand.collectionId;
                  bool connectedSocial =
                      isBrand ? chat.expand!.influencer.connectedSocial : false;

                  BlocProvider.of<RealtimeMessagingBloc>(context)
                      .add(GetMessagesByUserId(userId));
                  Navigator.pushNamed(
                    context,
                    singleChatScreen,
                    arguments: {
                      'userId': userId,
                      'name': name,
                      'avatar': avatar,
                      'collectionId': collectionId,
                      'hasConnectedInstagram': connectedSocial,
                    },
                  );
                },
                leading: CircleAvatar(
                  backgroundImage: isBrand
                      ? CachedNetworkImageProvider(Avatar.getUserImage(
                          userId: chat.expand!.influencer.id,
                          collectionId: chat.expand!.influencer.collectionId,
                          image: chat.expand!.influencer.avatar,
                        ))
                      : CachedNetworkImageProvider(Avatar.getUserImage(
                          userId: chat.expand!.brand.id,
                          collectionId: chat.expand!.brand.collectionId,
                          image: chat.expand!.brand.avatar,
                        )),
                ),
                title: Text(isBrand
                    ? chat.expand!.influencer.fullName
                    : chat.expand!.brand.brandName),
                subtitle: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      isMe
                          ? 'You: ${chat.expand!.message.messageText.length > 20 ? '${chat.expand!.message.messageText.substring(0, 20)}...' : chat.expand!.message.messageText}'
                          : chat.expand!.message.messageText.length > 20
                              ? '${chat.expand!.message.messageText.substring(0, 20)}...'
                              : chat.expand!.message.messageText,
                    ),
                    if (!chat.isRead && !isMe)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: ShadColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
                trailing: Text(
                  DateAndTime.timeAgo(
                    DateTime.parse(chat.expand!.message.created),
                  ),
                ),
              );
            },
          );
        } else {
          return Skeletonizer(
            enabled: state is ChatsLoading,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: 20,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                        Avatar.getAvatarPlaceholder('HA')),
                  ),
                  title: Text('Full Name'),
                  subtitle: Text('This is the last message'),
                  trailing: Text('8 min ago'),
                );
              },
            ),
          );
        }
      },
    );
  }
}
