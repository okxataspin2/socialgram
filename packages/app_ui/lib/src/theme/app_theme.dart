import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template app_theme}
/// The Default App [ThemeData].
/// {@endtemplate}
class AppTheme {
  /// {@macro app_theme}
  const AppTheme();

  /// Defines the brightness of theme.
  Brightness get brightness => Brightness.light;

  /// Defines the background color of theme.
  Color get backgroundColor => AppColors.white;

  /// Defines the primary color of theme.
  Color get primary => AppColors.black;

  /// Defines light [ThemeData].
  ThemeData get theme =>
      FlexThemeData.light(
        scheme: FlexScheme.custom,
        colors: FlexSchemeColor.from(
          brightness: brightness,
          primary: primary,
          swapOnMaterial3: true,
        ),
        useMaterial3: true,
        useMaterial3ErrorColors: true,
      ).copyWith(
        textTheme: const AppTheme().textTheme,
        iconTheme: const IconThemeData(color: AppColors.black),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          filled: true,
          fillColor: AppColors.white.withOpacity(0.5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.black.withOpacity(0.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.blue.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          hintStyle: TextStyle(
            color: AppColors.black.withOpacity(0.4),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white.withOpacity(0.7),
          selectedItemColor: AppColors.black,
          unselectedItemColor: AppColors.grey,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          showDragHandle: true,
          surfaceTintColor: Colors.transparent,
          backgroundColor: AppColors.white.withOpacity(0.8),
          modalBackgroundColor: AppColors.white.withOpacity(0.8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.white.withOpacity(0.6),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.white.withOpacity(0.8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        tabBarTheme: TabBarThemeData(
          indicatorColor: AppColors.black,
          labelColor: AppColors.black,
          unselectedLabelColor: AppColors.grey,
          dividerColor: Colors.transparent,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.white.withOpacity(0.8),
          foregroundColor: AppColors.black,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.white.withOpacity(0.9),
          contentTextStyle: const TextStyle(color: AppColors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

  /// Defines iOS dart SystemUiOverlayStyle.
  static const SystemUiOverlayStyle iOSDarkSystemBarTheme =
      SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      );

  /// Text theme of the App theme.
  TextTheme get textTheme => contentTextTheme;

  /// The Content text theme based on [ContentTextStyle].
  static final contentTextTheme =
      TextTheme(
        displayLarge: ContentTextStyle.headline1,
        displayMedium: ContentTextStyle.headline2,
        displaySmall: ContentTextStyle.headline3,
        headlineLarge: ContentTextStyle.headline4,
        headlineMedium: ContentTextStyle.headline5,
        headlineSmall: ContentTextStyle.headline6,
        titleLarge: ContentTextStyle.headline7,
        titleMedium: ContentTextStyle.subtitle1,
        titleSmall: ContentTextStyle.subtitle2,
        bodyLarge: ContentTextStyle.bodyText1,
        bodyMedium: ContentTextStyle.bodyText2,
        labelLarge: ContentTextStyle.button,
        bodySmall: ContentTextStyle.caption,
        labelSmall: ContentTextStyle.overline,
      ).apply(
        bodyColor: AppColors.black,
        displayColor: AppColors.black,
        decorationColor: AppColors.black,
      );

  /// The UI text theme based on [UITextStyle].
  static final uiTextTheme =
      TextTheme(
        displayLarge: UITextStyle.headline1,
        displayMedium: UITextStyle.headline2,
        displaySmall: UITextStyle.headline3,
        headlineMedium: UITextStyle.headline4,
        headlineSmall: UITextStyle.headline5,
        titleLarge: UITextStyle.headline6,
        titleMedium: UITextStyle.subtitle1,
        titleSmall: UITextStyle.subtitle2,
        bodyLarge: UITextStyle.bodyText1,
        bodyMedium: UITextStyle.bodyText2,
        labelLarge: UITextStyle.button,
        bodySmall: UITextStyle.caption,
        labelSmall: UITextStyle.overline,
      ).apply(
        bodyColor: AppColors.black,
        displayColor: AppColors.black,
        decorationColor: AppColors.black,
      );
}

/// {@template app_dark_theme}
/// Dark Mode App [ThemeData].
/// {@endtemplate}
class AppDarkTheme extends AppTheme {
  /// {@macro app_dark_theme}
  const AppDarkTheme();

  @override
  Brightness get brightness => Brightness.dark;

  @override
  Color get backgroundColor => AppColors.black;

  @override
  Color get primary => AppColors.white;

  @override
  TextTheme get textTheme {
    return AppTheme.contentTextTheme.apply(
      bodyColor: AppColors.white,
      displayColor: AppColors.white,
      decorationColor: AppColors.white,
    );
  }

  @override
  ThemeData get theme =>
      FlexThemeData.dark(
        scheme: FlexScheme.custom,
        darkIsTrueBlack: true,
        colors: FlexSchemeColor.from(
          brightness: brightness,
          primary: primary,
          appBarColor: AppColors.transparent,
          swapOnMaterial3: true,
        ),
        useMaterial3: true,
        useMaterial3ErrorColors: true,
      ).copyWith(
        textTheme: const AppDarkTheme().textTheme,
        iconTheme: const IconThemeData(color: AppColors.white),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          filled: true,
          fillColor: AppColors.white.withOpacity(0.06),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.white.withOpacity(0.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.blue.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          hintStyle: TextStyle(
            color: AppColors.white.withOpacity(0.4),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.black.withOpacity(0.7),
          selectedItemColor: AppColors.white,
          unselectedItemColor: AppColors.white.withOpacity(0.5),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          surfaceTintColor: Colors.transparent,
          backgroundColor: AppColors.black.withOpacity(0.8),
          modalBackgroundColor: AppColors.black.withOpacity(0.8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.white.withOpacity(0.06),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.black.withOpacity(0.8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        tabBarTheme: TabBarThemeData(
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.5),
          dividerColor: Colors.transparent,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.white.withOpacity(0.1),
          foregroundColor: AppColors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.black.withOpacity(0.9),
          contentTextStyle: const TextStyle(color: AppColors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
}

/// Theme for the [SystemUiOverlayStyle]
class SystemUiOverlayTheme {
  /// {@macro system_ui_overlay_theme}
  const SystemUiOverlayTheme();

  /// Defines iOS light SystemUiOverlayStyle.
  static const SystemUiOverlayStyle iOSLightSystemBarTheme =
      SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.dark,
      );

  /// Defines iOS dark SystemUiOverlayStyle.
  static const SystemUiOverlayStyle iOSDarkSystemBarTheme =
      SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      );

  /// Defines Android light SystemUiOverlayStyle.
  static const SystemUiOverlayStyle androidLightSystemBarTheme =
      SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarColor: AppColors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      );

  /// Defines light SystemUiOverlayStyle.
  static const SystemUiOverlayStyle androidDarkSystemBarTheme =
      SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarColor: AppColors.black,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      );

  /// Defines a portrait only orientation for any device.
  static void setPortraitOrientation() {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );
  }
}
