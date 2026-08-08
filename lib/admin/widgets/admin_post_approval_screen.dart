import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AdminPostApprovalScreen extends StatefulWidget {
  const AdminPostApprovalScreen({super.key});

  @override
  State<AdminPostApprovalScreen> createState() =>
      _AdminPostApprovalScreenState();
}

class _AdminPostApprovalScreenState extends State<AdminPostApprovalScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const AdminPendingPostsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header with auto-approve toggle
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 92, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Review',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.white : AppColors.black,
                      ),
                    ),
                    Text(
                      'Approve or reject posts before they go live',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.white.withOpacity(0.4)
                            : AppColors.black.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<AdminBloc, AdminState>(
                buildWhen: (p, c) => p.autoApprove != c.autoApprove,
                builder: (context, state) {
                  return GlassChip(
                    label: Text(
                      state.autoApprove ? 'Auto: ON' : 'Auto: OFF',
                    ),
                    selected: state.autoApprove,
                    selectedColor: Colors.green,
                    onTap: () {
                      context.read<AdminBloc>().add(
                        AdminSetAutoApprove(!state.autoApprove),
                      );
                    },
                    icon: Icon(
                      state.autoApprove
                          ? Icons.check_circle
                          : Icons.cancel_outlined,
                      size: 14,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // Posts list
        Expanded(
          child: BlocBuilder<AdminBloc, AdminState>(
            buildWhen: (p, c) =>
                p.pendingPosts != c.pendingPosts ||
                p.pendingPostsStatus != c.pendingPostsStatus,
            builder: (context, state) {
              if (state.pendingPostsStatus == AdminStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.pendingPosts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: isDark
                            ? AppColors.white.withOpacity(0.15)
                            : AppColors.black.withOpacity(0.15),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'All caught up!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.white.withOpacity(0.5)
                              : AppColors.black.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No posts awaiting review',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.white.withOpacity(0.3)
                              : AppColors.black.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.pendingPosts.length,
                itemBuilder: (context, index) {
                  final post = state.pendingPosts[index];
                  return _ApprovalCard(post: post);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bloc = context.read<AdminBloc>();

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isDark
                    ? AppColors.white.withOpacity(0.1)
                    : AppColors.black.withOpacity(0.05),
                child: Text(
                  (post.author.username?[0] ?? '').toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author.fullName ?? post.author.username ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? AppColors.white : AppColors.black,
                      ),
                    ),
                    Text(
                      '@${post.author.username ?? ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.white.withOpacity(0.4)
                            : AppColors.black.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Caption
          Text(
            post.caption,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.white.withOpacity(0.7)
                  : AppColors.black.withOpacity(0.7),
            ),
          ),
          // Media preview
          if (post.media.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                post.media.first.url,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.glassPinkGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.image, color: AppColors.white),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  onPressed: () => bloc.add(AdminApprovePost(post.id)),
                  gradient: AppColors.glassGreenGradient,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, size: 16, color: AppColors.white),
                      SizedBox(width: 6),
                      Text(
                        'Approve',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GlassButton(
                  onPressed: () => _showRejectDialog(context, bloc),
                  color: Colors.red.withOpacity(0.15),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.red.withOpacity(0.8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Reject',
                        style: TextStyle(
                          color: Colors.red.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, AdminBloc bloc) {
    final controller = TextEditingController();
    GlassDialog.show<void>(
      context: context,
      title: const Text('Reject Post'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassContainer(
            blur: GlassBlur.light,
            borderRadius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Reason (optional)',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        GlassButton(
          onPressed: () => Navigator.pop(context),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Text('Cancel'),
        ),
        GlassButton(
          onPressed: () {
            bloc.add(AdminRejectPost(
              id: post.id,
              reason: controller.text.isNotEmpty ? controller.text : null,
            ));
            Navigator.pop(context);
          },
          color: Colors.red.withOpacity(0.15),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Reject',
            style: TextStyle(color: Colors.red.withOpacity(0.8)),
          ),
        ),
      ],
    );
  }
}
