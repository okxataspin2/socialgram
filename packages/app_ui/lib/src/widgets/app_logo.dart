import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template app_logo}
/// The application logo: camera glyph and the "SocialGram" wordmark.
/// {@endtemplate}
class AppLogo extends StatelessWidget {
  /// {@macro app_logo}
  const AppLogo({
    this.fit = BoxFit.contain,
    super.key,
    this.width,
    this.height,
    this.color,
  });

  /// The fit of the logo.
  final BoxFit fit;

  /// The width of the logo.
  final double? width;

  /// The height of the logo.
  final double? height;

  /// The color of the logo.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? context.adaptiveColor;
    final resolvedHeight = height ?? 50;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.camera_alt_rounded,
          color: resolvedColor,
          size: resolvedHeight * 0.62,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'SocialGram',
          style: context.titleLarge?.copyWith(
            color: resolvedColor,
            fontWeight: AppFontWeight.bold,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}