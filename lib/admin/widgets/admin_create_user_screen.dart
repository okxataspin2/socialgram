import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

const _purple = Colors.purple;

class AdminCreateUserScreen extends StatefulWidget {
  const AdminCreateUserScreen({super.key});

  @override
  State<AdminCreateUserScreen> createState() => _AdminCreateUserScreenState();
}

class _AdminCreateUserScreenState extends State<AdminCreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _followerCountController = TextEditingController(text: '0');
  final _followingCountController = TextEditingController(text: '0');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController
      ..clear()
      ..dispose();
    _displayNameController.dispose();
    _followerCountController.dispose();
    _followingCountController.dispose();
    super.dispose();
  }

  void _createUser() {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<AdminBloc>();
    bloc.add(
      AdminCreateUser(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim(),
        followerCount: int.tryParse(_followerCountController.text) ?? 0,
        followingCount: int.tryParse(_followingCountController.text) ?? 0,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Create User',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.black, AppColors.black.withOpacity(0.95)]
                : [
                    _purple.withOpacity(0.05),
                    AppColors.white.withOpacity(0.3),
                    AppColors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.glassPurpleGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person_add_rounded,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New Account',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.black,
                              ),
                            ),
                            Text(
                              'Fill in the details below',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.white.withOpacity(0.4)
                                    : AppColors.black.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Username
                    _GlassFormField(
                      controller: _usernameController,
                      label: 'Username',
                      prefixIcon: Icons.alternate_email,
                      validator: (v) =>
                          v != null && v.isNotEmpty ? null : 'Required',
                    ),
                    const SizedBox(height: 16),

                    // Display Name
                    _GlassFormField(
                      controller: _displayNameController,
                      label: 'Display Name',
                      prefixIcon: Icons.person_outline,
                      validator: (v) =>
                          v != null && v.isNotEmpty ? null : 'Required',
                    ),
                    const SizedBox(height: 16),

                    // Password
                    _GlassFormField(
                      controller: _passwordController,
                      label: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (v) => v != null && v.length >= 6
                          ? null
                          : 'Min 6 characters',
                    ),
                    const SizedBox(height: 20),

                    // Counts section
                    Text(
                      'Social Stats',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.white.withOpacity(0.6)
                            : AppColors.black.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _GlassFormField(
                            controller: _followerCountController,
                            label: 'Followers',
                            prefixIcon: Icons.people_outline,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v != null && int.tryParse(v) != null
                                ? null
                                : 'Number',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GlassFormField(
                            controller: _followingCountController,
                            label: 'Following',
                            prefixIcon: Icons.person_add_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v != null && int.tryParse(v) != null
                                ? null
                                : 'Number',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Submit
                    BlocBuilder<AdminBloc, AdminState>(
                      builder: (context, state) {
                        final loading = state.status == AdminStatus.loading;
                        return GlassButton(
                          onPressed: loading ? null : _createUser,
                          gradient: AppColors.glassPurpleGradient,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          width: double.infinity,
                          child: loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: AppColors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Create Account',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassFormField extends StatelessWidget {
  const _GlassFormField({
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDark ? AppColors.white : AppColors.black,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark
            ? AppColors.white.withOpacity(0.05)
            : AppColors.black.withOpacity(0.03),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.white.withOpacity(0.08)
                : AppColors.black.withOpacity(0.06),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.white.withOpacity(0.08)
                : AppColors.black.withOpacity(0.06),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _purple.withOpacity(0.5), width: 1.5),
        ),
        labelStyle: TextStyle(
          color: isDark
              ? AppColors.white.withOpacity(0.5)
              : AppColors.black.withOpacity(0.5),
        ),
      ),
    );
  }
}
