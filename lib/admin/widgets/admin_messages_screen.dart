import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/admin/admin.dart';
import 'package:intl/intl.dart';

class AdminMessagesScreen extends StatefulWidget {
  const AdminMessagesScreen({super.key});

  @override
  State<AdminMessagesScreen> createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const AdminMessagesRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state.messagesStatus == AdminStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.messagesStatus == AdminStatus.failure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load messages',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
                ),
                const SizedBox(height: 12),
                GlassButton(
                  onPressed: () {
                    context
                        .read<AdminBloc>()
                        .add(const AdminMessagesRequested());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.messages.isEmpty) {
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
                  'No messages yet',
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

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 92, 16, 16),
          itemCount: state.messages.length,
          itemBuilder: (context, index) {
            final message = state.messages[index];
            final createdAt =
                DateFormat.yMd().add_jm().format(message.createdAt);

            return GlassCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              onTap: () {
                Navigator.of(context).push(
                  AdminMessageThreadView.route(
                    context,
                    messageId: message.id,
                  ),
                );
              },
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.glassGreenGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.message_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.sender?.username ?? 'Unknown',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isDark
                                ? AppColors.white
                                : AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          message.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.white.withOpacity(0.5)
                                : AppColors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Time + menu
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        createdAt,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.white.withOpacity(0.3)
                              : AppColors.black.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'delete') {
                            context
                                .read<AdminBloc>()
                                .add(AdminDeleteMessage(message.id));
                          }
                        },
                        icon: Icon(
                          Icons.more_vert,
                          size: 18,
                          color: isDark
                              ? AppColors.white.withOpacity(0.3)
                              : AppColors.black.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
