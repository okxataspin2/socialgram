import 'dart:ui';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Blur intensity presets for glass effects.
enum GlassBlur { light, medium, heavy, ultra }

/// Core glass container with frosted blur effect.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    this.blur = GlassBlur.heavy,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.border,
    this.gradient,
    this.color,
    this.boxShadow,
    this.clipBehavior = Clip.antiAlias,
    this.constraints,
    super.key,
  });

  final Widget child;
  final GlassBlur blur;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;
  final Gradient? gradient;
  final Color? color;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;
  final BoxConstraints? constraints;

  double get _sigma => switch (blur) {
    GlassBlur.light => 10,
    GlassBlur.medium => 15,
    GlassBlur.heavy => 20,
    GlassBlur.ultra => 25,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor =
        color ??
        (isDark
            ? AppColors.white.withOpacity(0.08)
            : AppColors.white.withOpacity(0.65));
    final borderColor =
        border ??
        Border.all(
          color: isDark
              ? AppColors.white.withOpacity(0.12)
              : AppColors.white.withOpacity(0.5),
          width: 0.5,
        );
    final grad =
        gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.white.withOpacity(0.12),
                  AppColors.white.withOpacity(0.04),
                ]
              : [
                  AppColors.white.withOpacity(0.7),
                  AppColors.white.withOpacity(0.3),
                ],
        );
    final shadows =
        boxShadow ??
        [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: clipBehavior,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma),
        child: Container(
          constraints: constraints,
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: borderColor,
            gradient: grad,
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Glass card — drop-in replacement for Material [Card].
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.blur = GlassBlur.medium,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color,
    this.border,
    this.onTap,
    super.key,
  });

  final Widget child;
  final GlassBlur blur;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Border? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          blur: blur,
          borderRadius: borderRadius,
          padding: padding,
          color: color,
          border: border,
          child: child,
        ),
      ),
    );
  }
}

/// Glass app bar — frosted transparent app bar.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    required this.title,
    this.actions,
    this.leading,
    this.blur = GlassBlur.heavy,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.centerTitle = true,
    this.elevation = 0,
    super.key,
  });

  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final GlassBlur blur;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final double elevation;

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        backgroundColor ??
        (isDark
            ? AppColors.black.withOpacity(0.6)
            : AppColors.white.withOpacity(0.6));
    final fgColor = foregroundColor ?? Theme.of(context).colorScheme.onSurface;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? AppColors.white.withOpacity(0.08)
                    : AppColors.black.withOpacity(0.06),
                width: 0.5,
              ),
            ),
          ),
          child: AppBar(
            title: title,
            actions: actions,
            leading: leading,
            centerTitle: centerTitle,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: fgColor,
            bottom: bottom,
          ),
        ),
      ),
    );
  }
}

/// Glass bottom navigation bar — frosted glass nav bar.
class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.blur = GlassBlur.ultra,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;
  final GlassBlur blur;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        backgroundColor ??
        (isDark
            ? AppColors.black.withOpacity(0.7)
            : AppColors.white.withOpacity(0.7));
    final selectedColor =
        selectedItemColor ?? (isDark ? AppColors.white : AppColors.black);
    final unselectedColor =
        unselectedItemColor ??
        (isDark ? AppColors.white.withOpacity(0.5) : AppColors.grey);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? AppColors.white.withOpacity(0.08)
                    : AppColors.black.withOpacity(0.06),
                width: 0.5,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            items: items,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: selectedColor,
            unselectedItemColor: unselectedColor,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

/// Glass search bar — frosted search input.
class GlassSearchBar extends StatelessWidget {
  const GlassSearchBar({
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.blur = GlassBlur.light,
    this.borderRadius = 16,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final GlassBlur blur;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      blur: blur,
      borderRadius: borderRadius,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: isDark ? AppColors.white : AppColors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark
                ? AppColors.white.withOpacity(0.4)
                : AppColors.black.withOpacity(0.4),
          ),
          prefixIcon:
              prefixIcon ??
              Icon(
                Icons.search,
                color: isDark
                    ? AppColors.white.withOpacity(0.5)
                    : AppColors.black.withOpacity(0.5),
              ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: isDark
                  ? AppColors.white.withOpacity(0.08)
                  : AppColors.black.withOpacity(0.06),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: AppColors.blue.withOpacity(0.5),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass button — frosted glass action button.
class GlassButton extends StatelessWidget {
  const GlassButton({
    required this.onPressed,
    required this.child,
    this.blur = GlassBlur.light,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.gradient,
    this.color,
    this.height,
    this.width,
    this.border,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final GlassBlur blur;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? color;
  final double? height;
  final double? width;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onPressed,
      child: GlassContainer(
        blur: blur,
        borderRadius: borderRadius,
        padding: padding,
        color: color,
        gradient:
            gradient ??
            LinearGradient(
              colors: isDark
                  ? [
                      AppColors.white.withOpacity(0.15),
                      AppColors.white.withOpacity(0.05),
                    ]
                  : [
                      AppColors.white.withOpacity(0.8),
                      AppColors.white.withOpacity(0.4),
                    ],
            ),
        border:
            border ??
            Border.all(
              color: isDark
                  ? AppColors.white.withOpacity(0.15)
                  : AppColors.white.withOpacity(0.6),
              width: 0.5,
            ),
        child: Container(
          height: height,
          width: width,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

/// Glass chip — frosted filter chip.
class GlassChip extends StatelessWidget {
  const GlassChip({
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.selectedColor,
    this.blur = GlassBlur.light,
    this.borderRadius = 12,
    super.key,
  });

  final Widget label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? icon;
  final Color? selectedColor;
  final GlassBlur blur;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = selectedColor ?? AppColors.blue;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        child: GlassContainer(
          blur: blur,
          borderRadius: borderRadius,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: selected
              ? accent.withOpacity(isDark ? 0.25 : 0.15)
              : null,
          border: Border.all(
            color: selected
                ? accent.withOpacity(isDark ? 0.5 : 0.4)
                : isDark
                    ? AppColors.white.withOpacity(0.1)
                    : AppColors.black.withOpacity(0.08),
            width: selected ? 1 : 0.5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 6)],
              DefaultTextStyle(
                style: TextStyle(
                  color: selected
                      ? accent
                      : isDark
                          ? AppColors.white.withOpacity(0.7)
                          : AppColors.black.withOpacity(0.6),
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
                child: label,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Glass dialog — frosted glass modal dialog.
class GlassDialog extends StatelessWidget {
  const GlassDialog({
    required this.title,
    required this.content,
    this.actions,
    this.blur = GlassBlur.heavy,
    this.borderRadius = 24,
    super.key,
  });

  final Widget title;
  final Widget content;
  final List<Widget>? actions;
  final GlassBlur blur;
  final double borderRadius;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget title,
    required Widget content,
    List<Widget>? actions,
    GlassBlur blur = GlassBlur.heavy,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: anim,
            child: GlassDialog(
              title: title,
              content: content,
              actions: actions,
              blur: blur,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: GlassContainer(
        blur: blur,
        borderRadius: borderRadius,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTextStyle(
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.black,
              ),
              child: title,
            ),
            const SizedBox(height: 16),
            DefaultTextStyle(
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.white.withOpacity(0.7)
                    : AppColors.black.withOpacity(0.7),
              ),
              child: content,
            ),
            if (actions != null) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Glass switch — custom toggle with glass track.
class GlassSwitch extends StatelessWidget {
  const GlassSwitch({
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.trackColor,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = activeColor ?? AppColors.blue;
    final inactive = inactiveColor ?? (isDark ? Colors.grey[700]! : Colors.grey[300]!);
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 52,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: value
              ? active.withOpacity(isDark ? 0.4 : 0.3)
              : inactive.withOpacity(0.5),
          border: Border.all(
            color: value
                ? active.withOpacity(0.6)
                : isDark
                    ? AppColors.white.withOpacity(0.1)
                    : AppColors.black.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? active : Colors.grey,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass stat card — dashboard stat card with glass background + gradient icon.
class GlassStatCard extends StatelessWidget {
  const GlassStatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.gradient,
    this.subtitle,
    this.blur = GlassBlur.medium,
    this.borderRadius = 20,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;
  final Gradient? gradient;
  final String? subtitle;
  final GlassBlur blur;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grad =
        gradient ??
        LinearGradient(
          colors: [AppColors.blue, AppColors.blue.withOpacity(0.6)],
        );

    return GlassContainer(
      blur: blur,
      borderRadius: borderRadius,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: grad,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (grad as LinearGradient).colors.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.white, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.white.withOpacity(0.5)
                  : AppColors.black.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.white : AppColors.black,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.white.withOpacity(0.4)
                    : AppColors.black.withOpacity(0.4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Glass divider — translucent separator line.
class GlassDivider extends StatelessWidget {
  const GlassDivider({this.height = 1, this.indent, this.endIndent, super.key});

  final double height;
  final double? indent;
  final double? endIndent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: height,
      indent: indent,
      endIndent: endIndent,
      color: isDark
          ? AppColors.white.withOpacity(0.08)
          : AppColors.black.withOpacity(0.06),
    );
  }
}

/// Glass shimmer loading placeholder.
class GlassShimmer extends StatefulWidget {
  const GlassShimmer({
    this.width,
    this.height = 16,
    this.borderRadius = 8,
    super.key,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<GlassShimmer> createState() => _GlassShimmerState();
}

class _GlassShimmerState extends State<GlassShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * _controller.value, 0),
              end: Alignment(-0.5 + 2 * _controller.value, 0),
              colors: [
                (isDark
                        ? AppColors.white.withOpacity(0.05)
                        : AppColors.white.withOpacity(0.3))
                    .withOpacity(0.3),
                (isDark
                        ? AppColors.white.withOpacity(0.1)
                        : AppColors.white.withOpacity(0.6))
                    .withOpacity(0.5),
                (isDark
                        ? AppColors.white.withOpacity(0.05)
                        : AppColors.white.withOpacity(0.3))
                    .withOpacity(0.3),
              ],
            ),
          ),
        );
      },
    );
  }
}
