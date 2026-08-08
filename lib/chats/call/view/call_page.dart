import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/bloc/app_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/chats/call/widgets/call_screen.dart';

class CallPage extends StatelessWidget {
  const CallPage({
    required this.chatId,
    this.isVideo = true,
    super.key,
  });

  final String chatId;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppBloc>().state.user;

    return Scaffold(
      body: CallScreen(
        chatId: chatId,
        currentUserId: user.id,
        currentUserName: user.displayFullName,
        isVideo: isVideo,
      ),
    );
  }
}
