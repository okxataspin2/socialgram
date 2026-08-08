import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Guards admin-only routes by checking the JWT app_metadata role.
///
/// TODO(architecture): This is a client-side check only. A malicious user
/// could craft a JWT with `role: 'admin'` in appMetadata. You MUST add
/// Supabase Row Level Security (RLS) policies to restrict admin-only
/// operations server-side. The admin client methods (getAllUsers, deleteUser,
/// updateUserRole, etc.) should be protected by RLS.
class AdminGuard extends StatelessWidget {
  const AdminGuard({super.key});

  static bool isAdmin(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;
    final role = user.appMetadata['role'] as String?;
    return role == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      context.go('/auth');
      return const SizedBox.shrink();
    }

    final role = user.appMetadata['role'] as String?;
    if (role != 'admin') {
      context.go('/feed');
      return const SizedBox.shrink();
    }

    return Container();
  }
}
