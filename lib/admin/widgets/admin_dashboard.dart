import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/admin/admin.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({this.onNavigateToTab, super.key});

  final ValueChanged<int>? onNavigateToTab;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>()
      ..add(const AdminUsersRequested())
      ..add(const AdminPostsStatsRequested())
      ..add(const AdminConversationsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        final userCount = state.users.length;
        final messageCount = state.messages.length;
        final postCount = state.posts.length;
        final conversationCount = state.conversations.length;
        final avgLikes = state.postsStats['average_likes'] ?? 0;
        final reelsCount = state.postsStats['reels_count'] ?? 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.white : AppColors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your platform at a glance',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.white.withOpacity(0.4)
                      : AppColors.black.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 24),

              // Primary stats row
              Row(
                children: [
                  Expanded(
                    child: GlassStatCard(
                      title: 'Users',
                      value: '$userCount',
                      icon: Icons.people_rounded,
                      gradient: AppColors.glassPurpleGradient,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassStatCard(
                      title: 'Posts',
                      value: '$postCount',
                      icon: Icons.article_rounded,
                      gradient: AppColors.glassBlueGradient,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GlassStatCard(
                      title: 'Messages',
                      value: '$messageCount',
                      icon: Icons.chat_rounded,
                      gradient: AppColors.glassGreenGradient,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassStatCard(
                      title: 'Chats',
                      value: '$conversationCount',
                      icon: Icons.forum_rounded,
                      gradient: AppColors.glassOrangeGradient,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GlassStatCard(
                      title: 'Reels',
                      value: '$reelsCount',
                      icon: Icons.videocam_rounded,
                      gradient: AppColors.glassPinkGradient,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassStatCard(
                      title: 'Avg Likes',
                      value: '$avgLikes',
                      icon: Icons.favorite_rounded,
                      gradient: AppColors.glassTealGradient,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Quick actions
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.black,
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _QuickAction(
                      icon: Icons.person_add_rounded,
                      label: 'Create User',
                      gradient: AppColors.glassPurpleGradient,
                      onTap: () => widget.onNavigateToTab?.call(1),
                    ),
                    const GlassDivider(indent: 48),
                    _QuickAction(
                      icon: Icons.approval_rounded,
                      label: 'Review Posts',
                      gradient: AppColors.glassBlueGradient,
                      onTap: () => widget.onNavigateToTab?.call(4),
                    ),
                    const GlassDivider(indent: 48),
                    _QuickAction(
                      icon: Icons.shield_rounded,
                      label: 'Manage Users',
                      gradient: AppColors.glassGreenGradient,
                      onTap: () => widget.onNavigateToTab?.call(1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Insights
              Text(
                'Insights',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.black,
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.glassGreenGradient,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Analytics',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.white
                                : AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Charts and analytics will be rendered here. '
                      'Connect your analytics provider for real-time data.',
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
            ],
          ),
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.white : AppColors.black,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.white.withOpacity(0.3)
                  : AppColors.black.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
