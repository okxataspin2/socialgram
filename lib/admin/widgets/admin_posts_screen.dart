import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/admin/admin.dart';
import 'package:intl/intl.dart';

class AdminPostsScreen extends StatefulWidget {
  const AdminPostsScreen({super.key});

  @override
  State<AdminPostsScreen> createState() => _AdminPostsScreenState();
}

class _AdminPostsScreenState extends State<AdminPostsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const AdminPostsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state.postsStatus == AdminStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.postsStatus == AdminStatus.failure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load posts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
                ),
                const SizedBox(height: 12),
                GlassButton(
                  onPressed: () {
                    context.read<AdminBloc>().add(const AdminPostsRequested());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 64,
                  color: isDark
                      ? AppColors.white.withOpacity(0.15)
                      : AppColors.black.withOpacity(0.15),
                ),
                const SizedBox(height: 16),
                Text(
                  'No posts yet',
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
          itemCount: state.posts.length,
          itemBuilder: (context, index) {
            final post = state.posts[index];
            final createdAt = DateFormat.yMMMd().format(post.createdAt);

            return GlassCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: post.media.isNotEmpty
                        ? Image.network(
                            post.media[0].url,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: AppColors.glassPinkGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.image,
                                color: AppColors.white,
                              ),
                            ),
                          )
                        : Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: AppColors.glassPinkGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.image,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author.fullName ??
                              post.author.username ??
                              'Unknown',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isDark ? AppColors.white : AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          post.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
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
                            context.read<AdminBloc>().add(
                              AdminDeletePost(post.id),
                            );
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
