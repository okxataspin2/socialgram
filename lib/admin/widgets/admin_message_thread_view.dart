import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/admin/admin.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:intl/intl.dart';

class AdminMessageThreadView extends StatelessWidget {
  const AdminMessageThreadView({
    required this.messageId,
    super.key,
  });

  final String messageId;

  static Route<void> route(BuildContext context, {required String messageId}) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: context.read<AdminBloc>(),
        child: AdminMessageThreadView(messageId: messageId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = context.read<AppBloc>().state.user.id;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Message Detail',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              context.read<AdminBloc>().add(
                AdminDeleteMessage(messageId),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.black, AppColors.black.withOpacity(0.95)]
                : [
                    AppColors.blue.withOpacity(0.03),
                    AppColors.white.withOpacity(0.5),
                    AppColors.white,
                  ],
          ),
        ),
        child: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            final message = state.messages
                .where((m) => m.id == messageId)
                .toList();

            if (message.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: isDark
                          ? AppColors.white.withOpacity(0.15)
                          : AppColors.black.withOpacity(0.15),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Message not found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.white.withOpacity(0.5)
                            : AppColors.black.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              );
            }

            final msg = message.first;
            final isMe = msg.sender?.id == currentUserId;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              children: [
                Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: GlassContainer(
                      blur: GlassBlur.light,
                      borderRadius: 16,
                      padding: const EdgeInsets.all(12),
                      color: isMe
                          ? AppColors.blue
                              .withValues(alpha: isDark ? 0.2 : 0.1)
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (msg.sender != null)
                            Text(
                              msg.sender!.username,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: isMe
                                    ? (isDark
                                        ? AppColors.blue.withValues(alpha: 0.8)
                                        : AppColors.blue)
                                    : (isDark
                                        ? AppColors.white.withValues(alpha: 0.6)
                                        : AppColors.black.withValues(
                                            alpha: 0.6)),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            msg.message,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.yMd()
                                .add_jm()
                                .format(msg.createdAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.white.withValues(alpha: 0.3)
                                  : AppColors.black.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
