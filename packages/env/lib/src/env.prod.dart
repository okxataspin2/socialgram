import 'package:envied/envied.dart';

part 'env.prod.g.dart';

/// {@template env}
/// Prod Environment variables. Used to access environment variables in the app.
/// {@endtemplate}
@Envied(path: '.env.prod', obfuscate: true)
abstract class EnvProd {
  /// Supabase url secret.
  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static String supabaseUrl = _EnvProd.supabaseUrl;

  /// Supabase anon key secret.
  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static String supabaseAnonKey = _EnvProd.supabaseAnonKey;

  /// PowerSync ulr secret.
  @EnviedField(varName: 'POWERSYNC_URL', obfuscate: true)
  static String powersyncUrl = _EnvProd.powersyncUrl;

  /// iOS client id key secret.
  @EnviedField(varName: 'IOS_CLIENT_ID', obfuscate: true)
  static String iOSClientId = _EnvProd.iOSClientId;

  /// Web client id key secret.
  @EnviedField(varName: 'WEB_CLIENT_ID', obfuscate: true)
  static String webClientId = _EnvProd.webClientId;

  /// Firebase cloud messaging project id secret.
  @EnviedField(varName: 'FCM_PROJECT_ID', obfuscate: true)
  static String fcmProjectId = _EnvProd.fcmProjectId;

  @EnviedField(varName: 'CLOUDINARY_CLOUD_NAME', obfuscate: true)
  static String cloudinaryCloudName = _EnvProd.cloudinaryCloudName;

  @EnviedField(varName: 'CLOUDINARY_UPLOAD_PRESET', obfuscate: true)
  static String cloudinaryUploadPreset = _EnvProd.cloudinaryUploadPreset;

  /// ZEGOCLOUD app ID secret.
  @EnviedField(varName: 'ZEGO_APP_ID', obfuscate: true)
  static String zegoAppId = _EnvProd.zegoAppId;

  /// ZEGOCLOUD app sign secret.
  @EnviedField(varName: 'ZEGO_APP_SIGN', obfuscate: true)
  static String zegoAppSign = _EnvProd.zegoAppSign;
}
