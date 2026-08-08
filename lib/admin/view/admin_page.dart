import 'dart:ui';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/admin/admin.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:user_repository/user_repository.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AdminBloc(
            userRepository: context.read<UserRepository>(),
            chatsRepository: context.read(),
            postsRepository: context.read<PostsRepository>(),
          )..add(const AdminUsersRequested()),
        ),
      ],
      child: const AdminView(),
    );
  }
}

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _tabs = [
    'Dashboard',
    'Users',
    'Messages',
    'Posts',
    'Approval',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final bloc = context.read<AdminBloc>();
    switch (_tabController.index) {
      case 1:
        bloc.add(const AdminUsersRequested());
        break;
      case 2:
        bloc.add(const AdminMessagesRequested());
        break;
      case 3:
        bloc.add(const AdminPostsRequested());
        break;
      case 4:
        bloc.add(const AdminPendingPostsRequested());
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 56),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.black.withOpacity(0.6)
                    : AppColors.white.withOpacity(0.6),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.white.withOpacity(0.08)
                        : AppColors.black.withOpacity(0.06),
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Text(
                            context.l10n.adminPanelTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.black,
                            ),
                          ),
                          const Spacer(),
                          // Impersonation banner
                          BlocBuilder<AdminBloc, AdminState>(
                            buildWhen: (p, c) =>
                                p.isImpersonating != c.isImpersonating,
                            builder: (context, state) {
                              if (!state.isImpersonating) {
                                return const SizedBox.shrink();
                              }
                              return GlassChip(
                                label: const Text('Impersonating'),
                                selected: true,
                                selectedColor: Colors.orange,
                                onTap: () {
                                  context
                                      .read<AdminBloc>()
                                      .add(AdminStopImpersonation());
                                },
                                icon: const Icon(
                                  Icons.stop_circle,
                                  size: 14,
                                  color: Colors.orange,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.logout,
                              color: isDark
                                  ? AppColors.white
                                  : AppColors.black,
                            ),
                            onPressed: () => context
                                .read<AppBloc>()
                                .add(const AppLogoutRequested()),
                          ),
                        ],
                      ),
                    ),
                    // Glass TabBar
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      indicatorColor: isDark
                          ? AppColors.white
                          : AppColors.black,
                      labelColor: isDark
                          ? AppColors.white
                          : AppColors.black,
                      unselectedLabelColor: isDark
                          ? AppColors.white.withOpacity(0.4)
                          : AppColors.black.withOpacity(0.4),
                      dividerColor: Colors.transparent,
                      tabs: _tabs.map((t) => Tab(text: t)).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.black,
                    AppColors.black.withOpacity(0.95),
                  ]
                : [
                    AppColors.blue.withOpacity(0.05),
                    AppColors.white.withOpacity(0.3),
                    AppColors.white,
                  ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            AdminDashboard(
              onNavigateToTab: (index) {
                _tabController.animateTo(index);
              },
            ),
            const AdminUsersScreen(),
            const AdminMessagesScreen(),
            const AdminPostsScreen(),
            const AdminPostApprovalScreen(),
          ],
        ),
      ),
      floatingActionButton: _buildFab(isDark),
    );
  }

  Widget? _buildFab(bool isDark) {
    final index = _tabController.index;
    if (index == 1) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [AppColors.blue, Color(0xFF1565C0)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            final adminBloc = BlocProvider.of<AdminBloc>(context);
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: adminBloc,
                  child: const AdminCreateUserScreen(),
                ),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.white,
          elevation: 0,
          icon: const Icon(Icons.person_add),
          label: const Text(
            'Create User',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
    return null;
  }
}
