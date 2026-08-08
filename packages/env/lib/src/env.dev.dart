import 'package:envied/envied.dart';

part 'env.dev.g.dart';

/// {@template env}
/// Dev Environment variables. Used to access environment variables in the app.
/// {@endtemplate}
@Envied(path: '.env.dev', obfuscate: true)
abstract class EnvDev {
  /// Supabase url secret.
  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static String supabaseUrl = _EnvDev.supabaseUrl;

  /// Supabase anon key secret.
  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static String supabaseAnonKey = _EnvDev.supabaseAnonKey;

  /// PowerSync ulr secret.
  @EnviedField(varName: 'POWERSYNC_URL', obfuscate: true)
  static String powersyncUrl = _EnvDev.powersyncUrl;

  /// iOS client id key secret.
  @EnviedField(varName: 'IOS_CLIENT_ID', obfuscate: true)
  static String iOSClientId = _EnvDev.iOSClientId;

  /// Web client id key secret.
  @EnviedField(varName: 'WEB_CLIENT_ID', obfuscate: true)
  static String webClientId = _EnvDev.webClientId;

  /// Firebase cloud messaging project id secret.
  @EnviedField(varName: 'FCM_PROJECT_ID', obfuscate: true)
  static String fcmProjectId = _EnvDev.fcmProjectId;

  @EnviedField(varName: 'CLOUDINARY_CLOUD_NAME', obfuscate: true)
  static String cloudinaryCloudName = _EnvDev.cloudinaryCloudName;

  @EnviedField(varName: 'CLOUDINARY_UPLOAD_PRESET', obfuscate: true)
  static String cloudinaryUploadPreset = _EnvDev.cloudinaryUploadPreset;

  /// ZEGOCLOUD app ID.
  @EnviedField(varName: 'ZEGO_APP_ID', obfuscate: true)
  static String zegoAppId = _EnvDev.zegoAppId;

  /// ZEGOCLOUD app sign.
  @EnviedField(varName: 'ZEGO_APP_SIGN', obfuscate: true)
  static String zegoAppSign = _EnvDev.zegoAppSign;
}
