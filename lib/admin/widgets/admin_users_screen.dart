import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/admin/admin.dart';
import 'package:user_repository/user_repository.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchController = TextEditingController();
  String? _selectedRole;
  bool? _suspendedFilter;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    context.read<AdminBloc>().add(AdminSearchUsers(_searchController.text));
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        var users = _searchController.text.isEmpty
            ? state.users
            : state.searchResults;

        if (_selectedRole != null) {
          users = users
              .where((u) => u.role == _selectedRole)
              .toList();
        }
        if (_suspendedFilter != null) {
          users = users
              .where((u) => u.isSuspended == _suspendedFilter)
              .toList();
        }

        return Column(
          children: [
            // Glass search + filters
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 12),
              child: GlassSearchBar(
                controller: _searchController,
                hintText: 'Search users...',
              ),
            ),
            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GlassChip(
                    label: Text(
                      _selectedRole == null ? 'All Roles' : _selectedRole!.toUpperCase(),
                    ),
                    selected: _selectedRole != null,
                    onTap: () => _showRoleFilterDialog(),
                    icon: const Icon(Icons.filter_list, size: 14),
                  ),
                  const SizedBox(width: 8),
                  GlassChip(
                    label: Text(
                      _suspendedFilter == null
                          ? 'All Status'
                          : _suspendedFilter!
                              ? 'Suspended'
                              : 'Active',
                    ),
                    selected: _suspendedFilter != null,
                    onTap: () => _showStatusFilterDialog(),
                    icon: const Icon(Icons.circle, size: 8),
                  ),
                  const Spacer(),
                  Text(
                    '${users.length} users',
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
            const SizedBox(height: 8),
            // User list
            Expanded(
              child: state.status == AdminStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : state.status == AdminStatus.failure
                      ? _buildFailureState(isDark)
                      : users.isEmpty
                          ? _buildEmptyState(isDark)
                          : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return _UserTile(user: user);
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: isDark
                ? AppColors.white.withOpacity(0.15)
                : AppColors.black.withOpacity(0.15),
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
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

  Widget _buildFailureState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDark
                ? AppColors.white.withOpacity(0.3)
                : AppColors.black.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load users',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.white : AppColors.black,
            ),
          ),
          const SizedBox(height: 16),
          GlassButton(
            onPressed: () {
              context.read<AdminBloc>().add(const AdminUsersRequested());
            },
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showRoleFilterDialog() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => GlassContainer(
        blur: GlassBlur.ultra,
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...[
              (null, 'All Roles'),
              ('admin', 'Admin'),
              ('user', 'User'),
            ].map((entry) {
              final (value, label) = entry;
              return ListTile(
                title: Text(label),
                trailing: _selectedRole == value
                    ? const Icon(Icons.check, color: AppColors.blue)
                    : null,
                onTap: () {
                  setState(() => _selectedRole = value);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showStatusFilterDialog() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => GlassContainer(
        blur: GlassBlur.ultra,
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...[
              (null, 'All'),
              (false, 'Active'),
              (true, 'Suspended'),
            ].map((entry) {
              final (value, label) = entry;
              return ListTile(
                title: Text(label),
                trailing: _suspendedFilter == value
                    ? const Icon(Icons.check, color: AppColors.blue)
                    : null,
                onTap: () {
                  setState(() => _suspendedFilter = value);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatefulWidget {
  const _UserTile({required this.user});
  final User user;

  @override
  State<_UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<_UserTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = widget.user;
    final userId = user.id;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Avatar with gradient ring
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.glassBlueGradient.colors.first,
                          AppColors.glassPurpleGradient.colors.first,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      backgroundColor: isDark
                          ? AppColors.black
                          : AppColors.white,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? Text(
                              (user.displayUsername).substring(0, 1),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.black,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayUsername,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isDark
                                ? AppColors.white
                                : AppColors.black,
                          ),
                        ),
                        Text(
                          user.email ?? 'No email',
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
                  // Expand arrow
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.expand_more,
                      color: isDark
                          ? AppColors.white.withOpacity(0.3)
                          : AppColors.black.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded actions
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  const GlassDivider(),
                  const SizedBox(height: 8),
                  _ActionRow(
                    icon: Icons.admin_panel_settings,
                    label: 'Change Role',
                    onTap: () => _showRoleDialog(userId),
                  ),
                  _ActionRow(
                    icon: Icons.lock_outline,
                    label: 'Suspend',
                    iconColor: Colors.orange,
                    onTap: () => _suspendUser(userId, true),
                  ),
                  _ActionRow(
                    icon: Icons.visibility_outlined,
                    label: 'View as User',
                    iconColor: AppColors.blue,
                    onTap: () => _impersonateUser(userId),
                  ),
                  _ActionRow(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    iconColor: Colors.red,
                    onTap: () => _deleteUser(userId),
                  ),
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  void _showRoleDialog(String userId) {
    GlassDialog.show<void>(
      context: context,
      title: const Text('Change Role'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Admin'),
            onTap: () {
              context.read<AdminBloc>().add(
                AdminUpdateUserRole(userId: userId, role: 'admin'),
              );
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('User'),
            onTap: () {
              context.read<AdminBloc>().add(
                AdminUpdateUserRole(userId: userId, role: 'user'),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _suspendUser(String userId, bool suspend) {
    context.read<AdminBloc>().add(
      AdminSuspendUser(userId: userId, suspended: suspend),
    );
  }

  void _deleteUser(String userId) {
    final displayName = widget.user.displayUsername;
    GlassDialog.show<void>(
      context: context,
      title: const Text('Delete User'),
      content: Text('Delete $displayName? This cannot be undone.'),
      actions: [
        GlassButton(
          onPressed: () => Navigator.pop(context),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Text('Cancel'),
        ),
        GlassButton(
          onPressed: () {
            context.read<AdminBloc>().add(AdminDeleteUser(userId));
            Navigator.pop(context);
          },
          color: Colors.red.withOpacity(0.2),
          border: Border.all(color: Colors.red.withOpacity(0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  void _impersonateUser(String userId) {
    context.read<AdminBloc>().add(AdminStartImpersonation(userId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Now viewing as ${widget.user.displayUsername}'),
        action: SnackBarAction(
          label: 'Stop',
          onPressed: () {
            context.read<AdminBloc>().add(AdminStopImpersonation());
          },
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ??
                  (isDark
                      ? AppColors.white.withOpacity(0.6)
                      : AppColors.black.withOpacity(0.6)),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: iconColor ??
                    (isDark
                        ? AppColors.white.withOpacity(0.8)
                        : AppColors.black.withOpacity(0.8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
